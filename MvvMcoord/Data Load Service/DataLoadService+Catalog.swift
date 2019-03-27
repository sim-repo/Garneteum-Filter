import UIKit
import RxSwift
import CoreData

// MARK: - CATALOG 
extension DataLoadService {
    
    internal func clearOldCatalog() {
        let res = dbLoadLastUIDs(sql: "needRefresh == 1 && type == 'catalogIds' ")
        guard let _res = res,
            _res.count > 0
            else {
                return
        }

        for uid in _res {
            dbDeleteEntity(Int(uid.categoryId), clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", fetchBatchSize: 0)
            dbDeleteEntity(Int(uid.categoryId), clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", fetchBatchSize: 0)
            uid.needRefresh = false
        }
        self.appDelegate.saveContext()
    }
    
    
    internal func doEmitCatalogStart(_ categoryId: CategoryId){
        let res1_ = dbLoadEntity(categoryId, CategoriesPersistent.self, "CategoriesPersistent", 1)
        let res2_ = dbLoadEntity(categoryId, CategoryItemIdsPersistent.self, "CategoryItemIdsPersistent", 0)
        guard let res1 = res1_,
              let res2 = res2_,
              res1.count > 0,
              res2.count > 0
            else {
                let completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? = { [weak self] (categoryId, fetchLimit, itemIds, minPrice, maxPrice) in
                    self?.dbSaveCatalog(categoryId, fetchLimit, itemIds, minPrice, maxPrice)
                }
                networkService.reqCatalogStart(categoryId: categoryId, completion: completion)
                return
        }
        var itemIds: [Int] = []
        for element in res2 {
            itemIds.append(Int(element.itemId))
        }
        fireCatalogTotal(categoryId, itemIds, Int(res1[0].fetchLimit), CGFloat(res1[0].minPrice), CGFloat(res1[0].maxPrice))
    }
    
    
    internal func fireCatalogTotal(_ categoryId: CategoryId ,_ itemIds: ItemIds, _ fetchLimit: Int, _ minPrice: MinPrice, _ maxPrice: MaxPrice) {
        outCatalogTotal.onNext((categoryId, itemIds, fetchLimit, minPrice, maxPrice))
    }
    
    func getCatalogTotalEvent() -> BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)> {
        return outCatalogTotal
    }
    
//    
//    func reqCatalogStart(categoryId: CategoryId) {
//        let completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? = { [weak self] (categoryId, fetchLimit, itemIds, minPrice, maxPrice) in
//            self?.dbSaveCatalog(categoryId, fetchLimit, itemIds, minPrice, maxPrice )
//        }
//        networkService.reqCatalogStart(categoryId: categoryId, completion: completion)
//    }
//    
    
    
    internal func dbSaveCatalog(_ categoryId: CategoryId, _ fetchLimit: Int, _ itemIds: ItemIds, _ minPrice: Int, _ maxPrice: Int) {
        dbDeleteEntity(categoryId, clazz: CategoriesPersistent.self, entity: "CategoriesPersistent", fetchBatchSize: 1)
        dbDeleteEntity(categoryId, clazz: CategoryItemIdsPersistent.self, entity: "CategoryItemIdsPersistent", fetchBatchSize: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            self.viewContext.performAndWait {
                let row = CategoriesPersistent(entity: CategoriesPersistent.entity(), insertInto: self.viewContext)
                row.setup(categoryId, minPrice, maxPrice, fetchLimit)
                self.appDelegate.saveContext()
                
                var db2 = [CategoryItemIdsPersistent]()
                for itemId in itemIds {
                    let row = CategoryItemIdsPersistent(entity: CategoryItemIdsPersistent.entity(), insertInto: self.viewContext)
                    row.setup(categoryId, itemId)
                    db2.append(row)
                }
                self.appDelegate.saveContext()
                self.fireCatalogTotal(categoryId, itemIds, fetchLimit, CGFloat(minPrice), CGFloat(maxPrice))
            }
        }
    }
    
    
    internal func dbLoadEntity<T: NSManagedObject>(_ categoryId: CategoryId, _ clazz: T.Type, _ entity: String, _ fetchBatchSize: Int, sql: String = "") -> [T]?{
        var db: [T]?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if fetchBatchSize != 0 {
            request.fetchBatchSize = fetchBatchSize
        }
        if sql == "" {
            request.predicate = NSPredicate(format: "categoryId == \(categoryId)")
        } else {
            request.predicate = NSPredicate(format: sql)
        }
        do {
            db = try viewContext.fetch(request) as? [T]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    
    
    internal func dbDeleteEntity<T: NSManagedObject>(_ categoryId: CategoryId, clazz: T.Type, entity: String, fetchBatchSize: Int, sql: String = ""){
        let res_ = dbLoadEntity(categoryId, clazz, entity, fetchBatchSize, sql: sql)
        guard let res = res_ else { return }
        for element in res {
            viewContext.delete(element)
        }
        appDelegate.saveContext()
    }
}
