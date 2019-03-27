import Foundation
import CoreData


extension SubfilterPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubfilterPersistent> {
        return NSFetchRequest<SubfilterPersistent>(entityName: "SubfilterPersistent")
    }

    @NSManaged public var id: Int32
    @NSManaged public var filterId: Int32
    @NSManaged public var categoryId: Int32
    @NSManaged public var title: String
    @NSManaged public var sectionHeader: String
    @NSManaged public var cross: Bool
    @NSManaged public var countItems: Int32

}
