import Foundation
import CoreData


extension NewUidPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewUidPersistent> {
        return NSFetchRequest<NewUidPersistent>(entityName: "NewUidPersistent")
    }

    @NSManaged public var categoryId: Int32
    @NSManaged public var cross: Bool
    @NSManaged public var type: String
    @NSManaged public var filterId: Int32
    @NSManaged public var uid: String

}
