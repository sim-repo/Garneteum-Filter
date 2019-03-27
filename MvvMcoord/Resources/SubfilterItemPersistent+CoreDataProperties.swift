import Foundation
import CoreData


extension SubfilterItemPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubfilterItemPersistent> {
        return NSFetchRequest<SubfilterItemPersistent>(entityName: "SubfilterItemPersistent")
    }

    @NSManaged public var itemId: Int32
    @NSManaged public var subfilterId: Int32
    @NSManaged public var categoryId: Int32

}
