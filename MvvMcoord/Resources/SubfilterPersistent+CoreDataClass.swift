import Foundation
import CoreData


public class SubfilterPersistent: NSManagedObject {
    public func getSubfilterModel() -> SubfilterModel {
        return SubfilterModel(id: Int(id), filterId: Int(filterId), categoryId: Int(categoryId), title: title, sectionHeader: sectionHeader, cross: cross, countItems: Int(countItems))
    }
    
    public func setup(subfilterModel: SubfilterModel) {
        self.id = Int32(subfilterModel.id)
        self.filterId = Int32(subfilterModel.filterId)
        self.categoryId = Int32(subfilterModel.categoryId)
        self.cross = subfilterModel.cross
        self.sectionHeader = subfilterModel.sectionHeader
        self.countItems = Int32(subfilterModel.countItems)
        self.title = subfilterModel.title
    }
}
