import Foundation
import CoreData


public class CategoryItemIdsPersistent: NSManagedObject {

    
    static func getData(categoryItemIdsPersistent: [CategoryItemIdsPersistent]) -> ItemIds {
        var res: ItemIds = []
        for element in categoryItemIdsPersistent {
            res.append(Int(element.itemId))
        }
        return res
    }
    
    
    func setup(_ categoryId: Int, _ itemId: Int) {
        self.categoryId = Int32(categoryId)
        self.itemId = Int32(itemId)
    }
}
