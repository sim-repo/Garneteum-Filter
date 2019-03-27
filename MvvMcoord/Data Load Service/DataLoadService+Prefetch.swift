import UIKit
import RxSwift
import CoreData

// MARK: - CATALOG
extension DataLoadService {
    
    internal func clearOldPrefetch() {
        let res = dbLoadLastUIDs(sql: "needRefresh == 1 && type == 'prefetch' ")
        guard let _res = res,
            _res.count > 0
            else {
                return
        }
        for uid in _res {
            dbDeleteEntity(0, clazz: PrefetchPersistent.self, entity: "PrefetchPersistent", fetchBatchSize: 0, sql: "categoryId == \(Int(uid.categoryId))")
            uid.needRefresh = false
        }
        self.appDelegate.saveContext()
    }
    
    
    internal func doEmitPrefetch(categoryId: CategoryId, itemIds: ItemIds){
        let res1_ = dbLoadPrefetch(itemIds: itemIds)
        guard let res1 = res1_,
            res1.count == itemIds.count
            else {
                let completion: (([CatalogModel1])->Void)? = { [weak self] catalogModels in
                    self?.dbSavePrefetch(categoryId, catalogModels)
                }
                networkService.reqPrefetch(itemIds: itemIds, completion: completion)
                return
        }
        let catalogModels: [CatalogModel] = PrefetchPersistent.getModels(prefetchPersistents: res1)
        firePrefetch(catalogModels)
    }
    
    
    
    internal func firePrefetch(_ models: [CatalogModel]) {
        outPrefetch.onNext(models)
    }
    
    func getPrefetchEvent() -> PublishSubject<[CatalogModel]> {
        return outPrefetch
    }
    
    
    internal func dbSavePrefetch(_ categoryId: CategoryId, _ catalogModels: [CatalogModel1]){
        
       // dbDeleteEntity(categoryId, clazz: PrefetchPersistent.self, entity: "PrefetchPersistent", fetchBatchSize: 0, sql: "categoryId == \(categoryId)")

        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            self.viewContext.performAndWait {
                var db = [PrefetchPersistent]()
                for model in catalogModels {
                    let row = PrefetchPersistent(entity: PrefetchPersistent.entity(), insertInto: self.viewContext)
                    row.setup(model: model)
                    db.append(row)
                }
                self.appDelegate.saveContext()
                let res = catalogModels.compactMap({CatalogModel(catalogModel1: $0)})
                self.firePrefetch(res)
            }
        }
    }
    
    
    internal func dbLoadPrefetch(itemIds: ItemIds) -> [PrefetchPersistent]?{
        var db: [PrefetchPersistent]?
        
        let request: NSFetchRequest<PrefetchPersistent> = PrefetchPersistent.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor.init(key: "itemId", ascending: true)
        ]
        request.predicate = NSPredicate(format: "ANY itemId IN %@", itemIds)
        do {
            db = try viewContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
}
