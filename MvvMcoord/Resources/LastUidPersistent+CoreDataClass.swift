import Foundation
import CoreData


public class LastUidPersistent: NSManagedObject {

    
    public func setup(newUID: NewUidPersistent) {
        self.uid = newUID.uid
        self.type = newUID.type
        self.categoryId = newUID.categoryId
        self.filterId = newUID.filterId
        self.cross = newUID.cross
        self.needRefresh = true
    }
}
