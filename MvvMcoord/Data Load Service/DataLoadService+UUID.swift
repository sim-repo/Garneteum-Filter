import UIKit
import RxSwift
import CoreData

// MARK: - UUIDS
extension DataLoadService {
    
    internal func loadNewUIDs(){
        let completion: (([UidModel]) -> Void)? = { [weak self] (uids) in
            self?.saveNewUIDs(uids)
        }
        networkService.reqLoadUIDs(completion: completion)
    }
    
    
    internal func saveNewUIDs(_ uids: [UidModel]?) {
        guard let _uids = uids
            else { return }
        dbDeleteData("NewUidPersistent")
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            self.viewContext.performAndWait {
                var uidsDB = [NewUidPersistent]()
                for element in _uids {
                    let uidDB = NewUidPersistent(entity: NewUidPersistent.entity(), insertInto: self.viewContext)
                    uidDB.setup(uidModel: element)
                    uidsDB.append(uidDB)
                }
                self.appDelegate.saveContext()
                self.compare()
            }
        }
    }
    
    internal func saveLastUIDs(_ uids: [NewUidPersistent]) {
      //print("saveLastUIDs")
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            self.viewContext.performAndWait {
                var uidsDB = [LastUidPersistent]()
                for element in uids {
                    let uidDB = LastUidPersistent(entity: LastUidPersistent.entity(), insertInto: self.viewContext)
                    uidDB.setup(newUID: element)
                    uidsDB.append(uidDB)
                }
                self.appDelegate.saveContext()
            }
            self.checkCrossRefresh()
            self.clearOldPrefetch()
            self.clearOldCatalog()
        }
    }
    
    internal func toRefresh(last: LastUidPersistent, newUid: String){
        last.needRefresh = true
        last.uid = newUid
        self.appDelegate.saveContext()
    }
    
    
    internal func compare() {
        guard let newUids = dbLoadNewUIDs() else { return }
        guard let lastUids = dbLoadLastUIDs(),
            lastUids.count > 0
            else {
                saveLastUIDs(newUids)
                return
        }
        var absent = [NewUidPersistent]()
        
        for new in newUids {
            if new.cross {
                if let last = lastUids.first(where: {$0.filterId == new.filterId && $0.type == new.type}) {
                    if last.uid != new.uid {
                        toRefresh(last: last, newUid: new.uid)
                    }
                } else {
                    absent.append(new)
                }
                
            } else {
                if let last = lastUids.first(where: {$0.categoryId == new.categoryId && $0.type == new.type}) {
                    if last.uid != new.uid {
                        toRefresh(last: last, newUid: new.uid)
                    }
                } else {
                    absent.append(new)
                }
            }
        }
        saveLastUIDs(absent)
    }
    
    
    
    internal func dbLoadNewUIDs() -> [NewUidPersistent]?{
        var uidDB: [NewUidPersistent]?
        do {
            uidDB = try viewContext.fetch(NewUidPersistent.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
    
    
    internal func dbLoadLastUIDs() -> [LastUidPersistent]?{
        var uidDB: [LastUidPersistent]?
        do {
            uidDB = try viewContext.fetch(LastUidPersistent.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return uidDB
    }
}

