import UIKit
import RxSwift
import CoreData


protocol DataLoadFacadeProtocol {
    
    func screenHandle(eventString: String, _ categoryId: CategoryId, _ itemsIds: Set<Int>)
    func screenHandle(eventString: String, _ categoryId: CategoryId)
    func screenHandle(eventString: String)
    
    func getFilters() -> BehaviorSubject<[FilterModel]>
    func getCrossSubfilters() -> BehaviorSubject<[SubfilterModel]>
    func getCategorySubfilters() -> BehaviorSubject<[SubfilterModel]>
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>
    func getApplyByPriceEvent() -> PublishSubject<FilterIds>
    

    func reqEnterSubFilter(filterId: FilterId, applied: Applied, rangePrice: RangePrice)
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice)
    func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func getMidTotal() -> PublishSubject<Int>
   // func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]>
    func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    func getCatalogTotalEvent() -> BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)>
    
    
    func getPrefetchEvent() -> PublishSubject<[CatalogModel]>
    
}



class DataLoadService : DataLoadFacadeProtocol {
   
    internal init(){}
    
    public static var shared = DataLoadService()
    
    internal var subfiltersByItem: SubfiltersByItem = SubfiltersByItem()
    internal var itemsBySubfilter: ItemsBySubfilter = ItemsBySubfilter()
    
    enum CrossFilterEnum: Int {
        case brands = 1, colors
    }
   
    enum DataTypeEnum: String {
        case filters = "filters", subfilters = "subfilters", subfiltersByItem = "subfiltersByItem", itemsBySubfilter = "itemsBySubfilter", priceByItemId = "priceByItemId", prefetch = "prefetch", catalogIds = "catalogIds"
    }
    
    internal let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var updateContext: NSManagedObjectContext = {
        let _updateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _updateContext.parent = self.viewContext
        return _updateContext
    }()
    
    internal var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    internal var subfilters: [SubfilterModel] = []
    
    let applyLogic: FilterApplyLogic = FilterApplyLogic.shared
    
    internal var outFilters = BehaviorSubject<[FilterModel]>(value: [])
    internal var outCrossSubfilters = BehaviorSubject<[SubfilterModel]>(value: [])
    internal var outCategorySubfilters = BehaviorSubject<[SubfilterModel]>(value: [])
    internal var outEnterSubFilter = PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>()
    internal var outApplyItemsResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>()
    internal var outApplyFiltersResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>()
    internal var outApplyByPrices = PublishSubject<FilterIds>()
    internal var outTotals = PublishSubject<Int>()
    internal var outPrefetch = PublishSubject<[CatalogModel]>()
    internal var outCatalogTotal = BehaviorSubject<(CategoryId, ItemIds, Int, MinPrice, MaxPrice)>(value: (0,[],20, 0, 0))
    
    internal let networkService = getNetworkService()
    
    func screenHandle(eventString: String) {
        switch eventString {
            case "RootCoord": loadNewUIDs()
            case "CatalogVM": doEmitCrossSubfilters(sql: "cross == 1")
            default:
                fatalError("screenHandle: no handlers found for value '\(eventString)'")
        }
    }
    
    func screenHandle(eventString: String, _ categoryId: CategoryId) {
        switch eventString {

        case "ShowCatalog": self.doEmitCategoryAllFilters(categoryId)
            
        case "StartCatalogFetch": self.doEmitCatalogStart(categoryId)
            
        default:
            fatalError("screenHandle: no handlers found for value '\(eventString)'")
        }
    }
    
    
    func screenHandle(eventString: String, _ categoryId: CategoryId, _ itemsIds: Set<Int>) {
        switch eventString {
            
        case "Prefetch":
            self.doEmitPrefetch(categoryId: categoryId, itemIds: itemsIds)
            
        default:
            fatalError("screenHandle: no handlers found for value '\(eventString)'")
        }
    }
    
    func getFilters() -> BehaviorSubject<[FilterModel]> {
        return outFilters
    }
    
    func getCrossSubfilters() -> BehaviorSubject<[SubfilterModel]> {
        return outCrossSubfilters
    }
    
    func getCategorySubfilters() -> BehaviorSubject<[SubfilterModel]> {
        return outCategorySubfilters
    }

    func reqEnterSubFilter(filterId: FilterId, applied: Applied, rangePrice: RangePrice) {
        applyLogic.doLoadSubFilters(filterId, applied, rangePrice)
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] res in
                let filterId = res.0
                let subfiltersIds = res.1
                let applied = res.2
                let countsItems = res.3
                self?.outEnterSubFilter.onNext((filterId, subfiltersIds, applied, countsItems))
            })
            .disposed(by: bag)
    }
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)> {
        return outEnterSubFilter
    }

    
    internal func dbDeleteData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                viewContext.delete(objectData)
                appDelegate.saveContext()
            }
            
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
}



extension DataLoadService {
    internal func doEmitCrossSubfilters(sql: String){
        if let subfiltersDB = dbLoadSubfilter(sql: sql) {
            let subfilters = subfiltersDB.compactMap({$0.getSubfilterModel()})
            self.applyLogic.setup(subFilters_: subfilters)
            self.outCrossSubfilters.onNext(subfilters)
        }
    }
    
    internal func emitCategorySubfilters(sql: String){
        if let subfiltersDB = dbLoadSubfilter(sql: sql) {
            let subfilters = subfiltersDB.compactMap({$0.getSubfilterModel()})
            self.applyLogic.setup(subFilters_: subfilters)
            self.outCategorySubfilters.onNext(subfilters)
        }
    }
    
    internal func emitCategoryFilters(sql: String){
        if let filtersDB = dbLoadFilter(sql: sql) {
            let filters = filtersDB.compactMap({$0.getFilterModel()})
            self.applyLogic.setup(filters_: filters)
            self.outFilters.onNext(filters)
        }
    }
    
    
    internal func setupApplyFromDB(sql: String){
        if let subfiltersItemsDB = dbLoadSubfiltersItems(sql: sql) {
            let (subfiltersByItem, itemsBySubfilter) = SubfilterItemPersistent.getApplyData(subfiltersItemPersistent: subfiltersItemsDB)
            self.applyLogic.setup(subfiltersByItem_: subfiltersByItem)
            self.applyLogic.setup(itemsBySubfilter_: itemsBySubfilter)
        }
        if let priceByItemDB = dbLoadPriceByItem(sql: sql) {
            let priceByItem = PriceByItemPersistent.getPriceByItem(priceByItemPersistent: priceByItemDB)
            self.applyLogic.setup(priceByItemId_: priceByItem)
        }
    }
}





// MARK: - FILTERS
extension DataLoadService {
    
    internal func dbLoadFilter(sql: String) -> [FilterPersistent]? {
        var db: [FilterPersistent]?
        let request: NSFetchRequest<FilterPersistent> = FilterPersistent.fetchRequest()
        request.predicate = NSPredicate(format: sql)
        do {
            db = try viewContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return db
    }
}

