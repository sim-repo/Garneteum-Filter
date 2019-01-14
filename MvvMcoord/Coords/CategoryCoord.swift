import UIKit
import RxSwift

class CategoryCoord: BaseCoord<Void> {
    
    private var rootViewController: UIViewController?
    private var parentBaseId: Int

    private var viewController: CategoryVC!
    
    init(rootViewController: UIViewController? = nil, parentBaseId: Int){
        self.rootViewController = rootViewController
        self.parentBaseId = parentBaseId
    }
    

    
    override func start() -> Observable<Void> {
        viewModel = CategoryVM(parentBaseId: parentBaseId)
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Category") as? CategoryVC
        
        guard let vm = viewModel as? CategoryVM
            else { fatalError("view model") }
        
        viewController.viewModel = vm
        
        vm.outShowSubcategory
            .flatMap{[weak self] baseId -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                return self.showSubcategory(on: self.viewController, parentBaseId: baseId)
            }
            .subscribe()
            .disposed(by: self.disposeBag)
        
        
        vm.outShowCatalog
            .flatMap{[weak self] baseId -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                return self.showCatalog(on: self.viewController, baseId: baseId)
            }
            .subscribe()
            .disposed(by: self.disposeBag)

        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .merge(back)
    }
    
    
    private func showSubcategory(on rootViewController: UIViewController, parentBaseId: Int) -> Observable<Void> {
        let nextCoord = CategoryCoord(rootViewController: rootViewController, parentBaseId: parentBaseId)
        return coordinate(coord: nextCoord)
    }
    
    private func showCatalog(on rootViewController: UIViewController, baseId: Int) -> Observable<Void> {
        let nextCoord = CatalogCoord(rootViewController: rootViewController, categoryId: baseId)
        return coordinate(coord: nextCoord)
    }
}