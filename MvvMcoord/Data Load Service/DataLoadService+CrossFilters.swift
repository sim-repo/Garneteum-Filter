import UIKit
import RxSwift
import CoreData
// MARK: - CROSS FILTERS
extension DataLoadService {
    
    internal func checkCrossRefresh(){
        //print("checkCrossRefresh")
        let res = dbLoadLastUIDs(sql: "cross == 1 && needRefresh == 1")
        guard let _res = res,
            _res.count > 0
            else {
                doEmitCrossSubfilters(sql: "cross == 1")
                emitCrossFilters(sql: "cross == 1")
                return
        }
        
        for uid in _res {
            crossDelete(filterId: Int(uid.filterId))
        }
        
        notifyCrossSubfilters
            .debug()
            .skip(_res.count-1)
            .take(1)
            .subscribe(onNext: {[weak self] cnt in
                print("CROSS SUBFILTERS EMIT")
                self?.doEmitCrossSubfilters(sql: "cross == 1")
                self?.emitCrossFilters(sql: "cross == 1")
            })
            .disposed(by: bag)
        
        for uid in _res {
            crossNetLoad(filterId: Int(uid.filterId))
        }
    }
    
    
    internal func crossRefreshDone(filterId: Int) {
        print("done: \(filterId)")
        let res = dbLoadLastUIDs(sql: "filterId == \(filterId)")
        guard let _res = res else { return }
        _res[0].needRefresh = false
        self.appDelegate.saveContext()
        notifyCrossSubfilters.onNext(Void())
    }
    
    
    internal func dbLoadLastUIDs(sql:String) -> [LastUidPersistent]?{
        var uidDB: [LastUidPersistent]?
        //let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request: NSFetchRequest<LastUidPersistent> = LastUidPersistent.fetchRequest()
        request.predicate = NSPredicate(format: sql)
        do {
            uidDB = try self.appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
    
    internal func dbLoadSubfilter(sql:String) -> [SubfilterPersistent]?{
        var db: [SubfilterPersistent]?
        //let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request: NSFetchRequest<SubfilterPersistent> = SubfilterPersistent.fetchRequest()
        if sql != "" {
            request.predicate = NSPredicate(format: sql)
        }
        do {
            db = try self.appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    internal func dbLoadCrossFilter(sql:String) -> [FilterPersistent]?{
        var db: [FilterPersistent]?
        //let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request: NSFetchRequest<FilterPersistent> = FilterPersistent.fetchRequest()
        request.predicate = NSPredicate(format: sql)
        do {
            db = try self.appDelegate.moc.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
    
    
    internal func crossNetLoad(filterId: FilterId){
       // print("load from NETWORK: \(filterId)")
        let completion: (([FilterModel]?, [SubfilterModel]?) -> Void)? = { [weak self] (filters, subfilters) in
            self?.crossSave(filterId: filterId, filters: filters, subfilters: subfilters)
        }
        networkService.reqLoadCrossFilters(filterId: filterId, completion: completion)
    }
    
    
    internal func crossSave(filterId: FilterId, filters: [FilterModel]?, subfilters: [SubfilterModel]?) {
        print("crossSave: \(filterId)")
        guard let _filters = filters,
            let _subfilters = subfilters
            else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            self.self.appDelegate.moc.performAndWait {
                var filtersDB = [FilterPersistent]()
                for element in _filters {
                    let filterDB = FilterPersistent(entity: FilterPersistent.entity(), insertInto: self.appDelegate.moc)
                    filterDB.setup(filterModel: element)
                    filtersDB.append(filterDB)
                }
                var subfiltersDB = [SubfilterPersistent]()
                for element in _subfilters {
                    let subfilterDB = SubfilterPersistent(entity: SubfilterPersistent.entity(), insertInto: self.appDelegate.moc)
                    subfilterDB.setup(subfilterModel: element)
                    subfiltersDB.append(subfilterDB)
                }
                self.appDelegate.saveContext()
                self.crossRefreshDone(filterId: filterId)
            }
        }
    }
    
    
    
    
    internal func crossDelete(filterId: FilterId) {
        let res1 = dbLoadSubfilter(sql: "filterId == \(filterId)")
        guard let _res1 = res1 else { return }
        for element in _res1 {
            self.appDelegate.moc.delete(element)
        }
        
        let res2 = dbLoadCrossFilter(sql: "id == \(filterId)")
        guard let _res2 = res2 else { return }
        for element in _res2 {
            self.appDelegate.moc.delete(element)
        }
        appDelegate.saveContext()
    }
}
