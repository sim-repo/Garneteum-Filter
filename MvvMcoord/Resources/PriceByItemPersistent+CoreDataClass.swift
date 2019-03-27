import UIKit
import CoreData


public class PriceByItemPersistent: NSManagedObject {
    
    public static func getPriceByItem(priceByItemPersistent: [PriceByItemPersistent]) -> PriceByItemId {
        var priceByItem: PriceByItemId = [:]
        for element in priceByItemPersistent {
            priceByItem[Int(element.itemId)] = CGFloat(element.price)
        }
        return priceByItem
    }
    
    public func setup(categoryId: Int, itemId: Int, price: CGFloat) {
        self.categoryId = Int32(categoryId)
        self.itemId = Int32(itemId)
        self.price = Double(price)
    }
}
