import Foundation
import CoreData


extension LastUidPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastUidPersistent> {
        return NSFetchRequest<LastUidPersistent>(entityName: "LastUidPersistent")
    }

    @NSManaged public var categoryId: Int32
    @NSManaged public var cross: Bool
    @NSManaged public var type: String
    @NSManaged public var filterId: Int32
    @NSManaged public var uid: String?
    @NSManaged public var needRefresh: Bool

}
