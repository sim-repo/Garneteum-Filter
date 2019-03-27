import Foundation
import CoreData


public class CategoriesPersistent: NSManagedObject {
    
    func setup(_ categoryId: Int, _ minPrice: Int, _ maxPrice: Int, _ fetchLimit: Int) {
        self.categoryId = Int32(categoryId)
        self.minPrice = Double(minPrice)
        self.maxPrice = Double(maxPrice)
        self.fetchLimit = Int32(fetchLimit)
    }
}
