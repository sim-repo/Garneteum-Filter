import Foundation
import CoreData


public class FilterPersistent: NSManagedObject {
    
    public func getFilterModel() -> FilterModel {
        let _filterEnum = FilterEnum(rawValue: filterEnum) ?? .select
        return FilterModel(id: Int(id), categoryId: Int(categoryId), title: title, cross: cross, filterEnum: _filterEnum)
    }
    
    public func setup(filterModel: FilterModel) {
        self.id = Int32(filterModel.id)
        self.title = filterModel.title
        self.categoryId = Int32(filterModel.categoryId)
        self.filterEnum = filterModel.filterEnum.rawValue
        self.cross = filterModel.cross
    }
}
