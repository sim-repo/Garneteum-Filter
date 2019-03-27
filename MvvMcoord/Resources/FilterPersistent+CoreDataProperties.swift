import Foundation
import CoreData


extension FilterPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FilterPersistent> {
        return NSFetchRequest<FilterPersistent>(entityName: "FilterPersistent")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var categoryId: Int32
    @NSManaged public var filterEnum: String
    @NSManaged public var cross: Bool

}
