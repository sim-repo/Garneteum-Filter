import Foundation
import CoreData

extension CategoryItemIdsPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryItemIdsPersistent> {
        return NSFetchRequest<CategoryItemIdsPersistent>(entityName: "CategoryItemIdsPersistent")
    }

    @NSManaged public var categoryId: Int32
    @NSManaged public var itemId: Int32
}
