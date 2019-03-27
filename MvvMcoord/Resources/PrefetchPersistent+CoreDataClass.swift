import Foundation
import CoreData


public class PrefetchPersistent: NSManagedObject {
    
    static func getModels(prefetchPersistents: [PrefetchPersistent]) -> [CatalogModel] {
        var models = [CatalogModel]()
        for element in prefetchPersistents {
            let model = CatalogModel(id: Int(element.itemId),
                         categoryId: Int(element.categoryId),
                         name: element.name,
                         thumbnail: element.thumbnail,
                         stars: Int(element.stars),
                         newPrice: element.newPrice as NSNumber,
                         oldPrice: element.oldPrice as NSNumber,
                         votes: Int(element.votes),
                         discount: Int(element.discount))
            models.append(model)
        }
        return models
    }
    
    func setup(model: CatalogModel1) {
        self.itemId = Int32(model.id)
        self.name = model.name
        self.categoryId = Int32(model.categoryId)
        self.thumbnail = model.thumbnail
        self.newPrice = Double(model.newPrice)
        self.oldPrice = Double(model.oldPrice)
        self.discount = Int32(model.discount)
        self.votes = Int16(model.votes)
        self.stars = Int16(model.stars)
    }
}
