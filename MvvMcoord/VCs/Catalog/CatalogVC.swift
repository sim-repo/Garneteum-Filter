import UIKit
import RxCocoa
import RxSwift

class CatalogVC: UIViewController {
    
    var viewModel: CatalogVM!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var currPage: UILabel!
    
    var bag = DisposeBag()
    var collectionDisposable: Disposable?
    
    private var cellLayout: CellLayoutEnum = .list
    private var cellHeight: CGFloat = 100.0
    private var cellWidth: CGFloat = 100.0
    private var cellSpace: CGFloat = 0.0
    private var lineSpace: CGFloat = 0.0
    private var planButtonImage = ""
    private let waitContainer: UIView = UIView()
    private let waitActivityView = UIActivityIndicatorView(style: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        uitCurrMemVCs += 1 // uitest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFlowLayout()
        setTitle()
        collectionView.prefetchDataSource = self
        collectionView.isHidden = true
        
        indicatorView.startAnimating()
        
        handleReloadEvent()
        handleWaitEvent()

        handleFetchCompleteEvent()
        
        bindNavigation()
        bindingLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    
    deinit {
        uitCurrMemVCs -= 1 // uitest
    }
    
    private func setFlowLayout(){
        if let collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.minimumInteritemSpacing = 0
        }
    }
    
    
    private func setTitle(){
        var title = viewModel.outTitle.value
        if (title.isEmpty) {
            title = "Каталог"
        }
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: title, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        self.navigationItem.titleView?.accessibilityIdentifier = "My"+String(uitCurrMemVCs)
    }
    
    
    private func handleReloadEvent(){
        viewModel.outReloadVC
            .subscribe(onNext: {[weak self] in
                self?.indicatorView.stopAnimating()
                self?.indicatorView.isHidden = true
                self?.collectionView.isHidden = false
                self?.collectionView.reloadData()
            })
            .disposed(by: bag)
    }
    
    private func handleFetchCompleteEvent(){
        viewModel.outFetchComplete
            .subscribe(onNext: {[weak self] newIndexPathsToReload in
                guard let `self` = self else {return}
                self.indicatorView.stopAnimating()
                guard let newIndexPathsToReload = newIndexPathsToReload else { return }
                let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                self.collectionView.reloadItems(at: indexPathsToReload)
            })
            .disposed(by: bag)
    }
    
    
    private func bindingLayout(){
        planButton.rx.tap
            .bind{[weak self] _ -> Void in
                self?.viewModel.inPressLayout.value = Void()}
            .disposed(by: bag)
        
        
        filterButton.rx.tap
            .bind{[weak self] _ -> Void in
                self?.viewModel.inPressFilter.onNext(Void())
            }
            .disposed(by: bag)
        
        
        viewModel.outLayout
            .asObservable()
            .subscribe(onNext: {[weak self] cellLayout in
                guard let layout = cellLayout else { return }
                guard let `self` = self else {return}
                
                self.cellHeight = layout.cellScale.height  *  self.collectionView.frame.height
                self.cellWidth = layout.cellScale.width *  self.collectionView.frame.width - layout.cellSpace
                self.planButton.setImage(UIImage(named: layout.layoutImageName), for: .normal)
                self.cellLayout = layout.cellLayoutType
                
            })
            .disposed(by: bag)
    }
    
    
    public func bindNavigation() {
        viewModel.outCloseVC
            .take(1)
            .subscribe{[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
    }
    
    private func handleWaitEvent(){
        waitContainer.frame = CGRect(x: view.center.x, y: view.center.y, width: 80, height: 80)
        waitContainer.backgroundColor = .lightGray
        waitContainer.center = self.view.center
        waitActivityView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        waitContainer.isHidden = true
        waitContainer.addSubview(waitActivityView)
        view.addSubview(waitContainer)
        
        viewModel.wait()
            .filter({[.applyFilter].contains($0.0)})
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else {return}
                let runWait = res.1
                if runWait {
                    self.startWait()
                } else {
                    self.stopWait()
                }
            })
            .disposed(by: bag)
    }
    
    
    private func startWait() {
        print("wait in Catalog")
        collectionView.isHidden = true
        waitContainer.isHidden = false
        waitActivityView.startAnimating()
    }
    
    private func stopWait(){
        collectionView.isHidden = false
        waitContainer.isHidden = true
        waitActivityView.stopAnimating()
    }
}


extension CatalogVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell!
        
        switch cellLayout {
            case .list:
                let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCellList", for: indexPath) as! CatalogListCell
                if isLoadingCell(for: indexPath) {
                    cell1.configCell(model: nil)
                } else {
                    if let model = viewModel.catalog(at: indexPath.row) {
                        cell1.configCell(model: model)
                    } else {
                        cell1.configCell(model: nil)
                    }
                }
                cell = cell1
            case .square:
                let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCellSquare", for: indexPath) as! CatalogSquareCell
                if isLoadingCell(for: indexPath) {
                    cell1.configCell(model: nil)
                } else {
                    if let model = viewModel.catalog(at: indexPath.row) {
                        cell1.configCell(model: model)
                    }
                }
                cell = cell1
            case .squares:
                let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCellSquares", for: indexPath) as! CatalogSquaresCell
                if isLoadingCell(for: indexPath) {
                    cell1.configCell(model: nil)
                } else {
                    if let model = viewModel.catalog(at: indexPath.row) {
                        cell1.configCell(model: model)
                    }
                }
                cell = cell1
        }
        return cell
    }
}




extension CatalogVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return sectionInset
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
    
}


extension CatalogVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.emitPrefetchEvent()
            
            currPage.text = "\(viewModel.currentPage)/\(viewModel.totalPages)"
        }
    }
}



private extension CatalogVC {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currItemsCount()
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath])->[IndexPath]{
        let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems 
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

