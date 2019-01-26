import UIKit
import RxSwift

class FilterCoord : BaseCoord<CoordRetEnum>{
    
    private var rootViewController: UIViewController?
    private var viewController: FilterVC!
    private var categoryId: Int
    private weak var filterActionDelegate: FilterActionDelegate?
    
    
    init(rootViewController: UIViewController? = nil, categoryId: Int, filterActionDelegate: FilterActionDelegate?){
        self.rootViewController = rootViewController
        self.categoryId = categoryId
        self.filterActionDelegate = filterActionDelegate
    }

    private func reload(){
        print("reload filter")
        guard let vm = viewModel as? FilterVM
            else { fatalError("view model") }
        vm.bindData()
    }
    
    override func start() -> Observable<CoordRetEnum> {
        viewModel = FilterVM(categoryId: categoryId, filterActionDelegate: filterActionDelegate)
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as? FilterVC
        
        guard let vm = viewModel as? FilterVM
            else { fatalError("view model") }
        
        viewController.viewModel = vm
        
        
        vm.outShowSubFilters
            .asObserver()
            .do(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.showSubFilters(on: self.viewController, filterId: filterId, filterActionDelegate: self.filterActionDelegate)
                        .asObservable()
                        .subscribe(onNext: {event in
                            switch event {
                            case .reloadData: self.reload()
                            case .back: print("back")
                            }
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
    
        
        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .amb([vm.backEvent/*, vm.inApply*/])
            .take(1)
    }
    
    
    private func showSubFilters(on rootViewController: UIViewController, filterId: Int, filterActionDelegate: FilterActionDelegate?) -> Observable<CoordRetEnum> {
        let nextCoord = SubFilterCoord(rootViewController: rootViewController, filterId: filterId, filterActionDelegate: filterActionDelegate)
        return coordinate(coord: nextCoord)
    }
}
