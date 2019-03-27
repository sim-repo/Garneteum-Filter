import UIKit

var catalogTotals: [Int: CatalogTotal] = [:]
var filterEntities: [Int: FilterEntities] = [:]
var crossFilters: [Int:FilterModel] = [:]
var crossSubFilters: [Int:[SubfilterModel]] = [:]
var crossSubfiltersByFilter: [Int: SubfiltersByFilter?] = [:]
var crossSubfiltersByFilterFlat: SubfiltersByFilter = [:]
var crossUuidByFilter: [Int: String] = [:]


public class CatalogTotal {
    
    let categoryId: Int
    var itemIds: ItemIds
    var fetchLimit: Int
    let minPrice: MinPrice
    let maxPrice: MaxPrice
    
    init(_ categoryId: Int, _ fetchLimit: Int, _ itemIds: ItemIds, _ minPrice: MinPrice, _ maxPrice: MaxPrice) {
        self.categoryId = categoryId
        self.fetchLimit = fetchLimit
        self.itemIds = itemIds
        self.minPrice = minPrice
        self.maxPrice = maxPrice
    }
}


class FilterEntities {
    
    var categoryId: Int?
    var filters:[FilterModel]?
    var subFilters:[SubfilterModel]?
    var subfiltersByFilter: SubfiltersByFilter?
    var subfiltersByItem: SubfiltersByItem?
    var itemsBySubfilter: ItemsBySubfilter?
    var priceByItemId: PriceByItemId?
    
    public func setup(categoryId: Int? = nil,
                      filters: [FilterModel]? = nil,
                      subFilters: [SubfilterModel]? = nil,
                      subfiltersByFilter: SubfiltersByFilter? = nil,
                      subfiltersByItem: SubfiltersByItem? = nil,
                      itemsBySubfilter: ItemsBySubfilter? = nil,
                      priceByItemId: PriceByItemId? = nil){
        
        self.categoryId = categoryId
        
        if filters != nil && filters!.count > 0 {
            self.filters = filters
        }
        
        if subFilters != nil && subFilters!.count > 0 {
            self.subFilters = subFilters
        }
        
        if subfiltersByFilter != nil && subfiltersByFilter!.count > 0 {
            self.subfiltersByFilter = subfiltersByFilter
        }
        
        if subfiltersByItem != nil && subfiltersByItem!.count > 0 {
            self.subfiltersByItem = subfiltersByItem
        }
        
        if itemsBySubfilter != nil && itemsBySubfilter!.count > 0 {
            self.itemsBySubfilter = itemsBySubfilter
        }
        
        if priceByItemId != nil && priceByItemId!.count > 0 {
            self.priceByItemId = priceByItemId
        }
    }
}


public class GlobalCacheOperation {
    
    func getCatalogTotal(categoryId: Int) -> CatalogTotal?{
        return catalogTotals[categoryId]
    }
    
    static func setCatalogTotal(categoryId: Int, fetchLimit:Int, itemIds: ItemIds, minPrice: MinPrice, maxPrice: MaxPrice) {
        guard categoryId > 0 &&
              fetchLimit > 0 &&
              itemIds.count > 0 &&
              minPrice > 0 &&
              maxPrice > 0
        else { return }
        guard catalogTotals[categoryId] == nil else { return }
        let catalogTotal = CatalogTotal(categoryId, fetchLimit, itemIds, minPrice, maxPrice)
        catalogTotals[categoryId] = catalogTotal
    }
    
//    func getFilterEntities(categoryId: Int) -> FilterEntities? {
//        return filterEntities[categoryId]
//    }
    
    func setChunk123(categoryId: Int,
                                  filters: [FilterModel]? = nil,
                                  subFilters: [SubfilterModel]? = nil,
                                  subfiltersByFilter: SubfiltersByFilter? = nil,
                                  subfiltersByItem: SubfiltersByItem? = nil,
                                  itemsBySubfilter: ItemsBySubfilter? = nil,
                                  priceByItemId: PriceByItemId? = nil,
                                  printComment: String
                                  ){
        
        guard categoryId != 0 else { return }
        
        var filterEntity: FilterEntities!
        if let f = filterEntities[categoryId] {
            filterEntity = f
        } else {
            filterEntity = FilterEntities()
            filterEntities[categoryId] = filterEntity
        }
        
        guard categoryId != 0 ||
            ( filters != nil && filters!.count > 0 ) ||
            ( subFilters != nil && subFilters!.count > 0) ||
            ( subfiltersByFilter != nil && subfiltersByFilter!.count > 0) ||
            ( subfiltersByItem != nil && subfiltersByItem!.count > 0) ||
            ( itemsBySubfilter != nil && itemsBySubfilter!.count > 0) ||
            ( priceByItemId != nil && priceByItemId!.count > 0)
            else { return }
        
        filterEntity.setup(categoryId: categoryId,
                           filters: filters,
                           subFilters: subFilters,
                           subfiltersByFilter: subfiltersByFilter,
                           subfiltersByItem: subfiltersByItem,
                           itemsBySubfilter: itemsBySubfilter,
                           priceByItemId: priceByItemId)
        print(printComment)
    }
    
    
    func setChunk4(_ uuid_: String?,
                                       _ filterId: FilterId,
                                       _ subFilters: [SubfilterModel]? = nil,
                                       //_ subfiltersByFilter: SubfiltersByFilter? = nil,
                                       printComment: String){
        
        guard let uuid = uuid_
        else { return }
        
        crossUuidByFilter[filterId] = uuid
        crossSubFilters[filterId] = subFilters
        
        var tmp: SubfiltersByFilter = [:]
        tmp[filterId] = []
        if let ids = subFilters?.compactMap({$0.id}) {
            tmp[filterId]?.append(contentsOf: ids)
        }
        crossSubfiltersByFilter[filterId] = tmp
        
        let arr = crossSubfiltersByFilter.filter({$0.key == filterId}).map{$0.1}
        for elem in arr {
            guard let el = elem else {continue}
            for (k,v) in el {
                crossSubfiltersByFilterFlat[k] = v
            }
        }

        print(printComment)
    }
    
    
    
    func getChunk1(categoryId: Int) -> [FilterModel]? {
        
        guard let entity = filterEntities[categoryId] else { return nil }
        if let filters = entity.filters {
            for filter in filters {
                filter.enabled = true
            }
        }
        return entity.filters
    }
    
    
    func getChunk2(categoryId: Int) -> [SubfilterModel]? {
        guard let entity = filterEntities[categoryId] else { return nil }
        var res1: [SubfilterModel]?
        res1 = crossSubFilters.map({$0.1}).flatMap({$0})
        if let subfilters = entity.subFilters {
            if let f = res1 {
                res1 = f + subfilters
            } else {
                res1 = subfilters
            }
        }
        return res1
//        var res2: SubfiltersByFilter?
//        res2 = crossSubfiltersByFilterFlat
//
//        if let subfiltersByFilter = entity.subfiltersByFilter {
//            if let f = res2 {
//                res2 = f + subfiltersByFilter
//            } else {
//                res2 = subfiltersByFilter
//            }
//        }
//        return (res1, res2)
    }
    
    
    func getChunk3(categoryId: Int) -> (SubfiltersByItem?,  ItemsBySubfilter?, PriceByItemId?)? {
        guard let entity = filterEntities[categoryId] else { return nil }
        return (entity.subfiltersByItem, entity.itemsBySubfilter, entity.priceByItemId)
    }
    
//    private func dealloc(){
//        catalogTotals.removeAll()
//        filterEntities.removeAll()
//    }
    
}
