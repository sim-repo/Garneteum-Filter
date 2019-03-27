import Foundation
import CoreData


public class SubfilterItemPersistent: NSManagedObject {
    
    public static func getApplyData(subfiltersItemPersistent: [SubfilterItemPersistent]) -> (SubfiltersByItem, ItemsBySubfilter) {
        var subfilterByItem: SubfiltersByItem = [:]
        var itemsBySubfilter: ItemsBySubfilter = [:]
        for element in subfiltersItemPersistent {
            if subfilterByItem[Int(element.itemId)] == nil {
                subfilterByItem[Int(element.itemId)] = []
            }
            subfilterByItem[Int(element.itemId)]?.append(Int(element.subfilterId))
            
            if itemsBySubfilter[Int(element.subfilterId)] == nil {
                itemsBySubfilter[Int(element.subfilterId)] = []
            }
            itemsBySubfilter[Int(element.subfilterId)]?.append(Int(element.itemId))
        }
        return (subfilterByItem, itemsBySubfilter)
    }
    
    public func setup(categoryId: Int, subfilterId: Int, itemId: Int) {
        self.categoryId = Int32(categoryId)
        self.subfilterId = Int32(subfilterId)
        self.itemId = Int32(itemId)
    }
}
