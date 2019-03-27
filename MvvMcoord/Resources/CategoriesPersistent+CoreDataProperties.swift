import Foundation
import CoreData


extension CategoriesPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoriesPersistent> {
        return NSFetchRequest<CategoriesPersistent>(entityName: "CategoriesPersistent")
    }

    @NSManaged public var categoryId: Int32
    @NSManaged public var minPrice: Double
    @NSManaged public var maxPrice: Double
    @NSManaged public var totalItems: Int32
    @NSManaged public var fetchLimit: Int32

}
