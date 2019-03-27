import Foundation
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions


class HeavyClientFCF : NetworkFacadeBase {
    
    private override init(){
        super.init()
    }
    
    public static var shared = HeavyClientFCF()
    
    let applyLogic: FilterApplyLogic = FilterApplyLogic.shared
    
    typealias Completion = (() -> Void)?
    
    private var task1: Completion
    private var task2: Completion
    private var task3: Completion
    internal var task4: Completion
    internal var task5: Completion
    internal var task6: Completion
    internal var task7: Completion
    internal var task8: Completion
    internal var task9: Completion
    internal var task10: Completion
    internal var task11: Completion
    
    private var reqTry: [Int:Int] = [:]
    private let limitTry = 3
    
    private func runRequest(task: Completion = nil){
        task?()
    }
    
    private func showTime() -> String{
        let now = Date()
        
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ss.SSSZ"
        
        let dateString = formatter.string(from: now)
        return dateString
    }
    
   
    private func firebaseHandleErr(task: Completion, taskId: Int, error: NSError, delay: Int = 0){
        
        if let tryno = reqTry[taskId] {
            reqTry[taskId] = tryno + 1
        } else {
            reqTry[taskId] = 1
        }
        
        let period = delay == 0 ? 2 : delay
        
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            
          //  if code == FunctionsErrorCode.resourceExhausted {
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(period), qos: .background) {
                task?()
            }
            print("error:\(String(describing: code)) : \(message) : \(String(describing: details))")
        }
    }
    
    
    
    
//    override func reqCatalogModel(itemIds: ItemIds) {
//        guard task2 == nil
//            else { return }
//        task2 = {
//            functions.httpsCallable("meta").call(["useCache": true,
//                                                  "itemsIds": itemIds,
//                                                  "method":"getPrefetching"
//            ]){[weak self] (result, error) in
//                guard let `self` = self else { return }
//
//                if let error = error as NSError? {
//                    let cnt = self.reqTry[2] ?? 0
//                    if cnt < self.limitTry {
//                        self.firebaseHandleErr(task: self.task2, taskId: 2, error: error)
//                    } else {
//                       //self.fireNetworkError()
//                        self.reqTry[2] = 0
//                        self.task2 = nil
//                    }
//                    return
//                }
//                let arr:[CatalogModel] = ParsingHelper.parseCatalogModel(result: result, key: "items")
//                self.fireCatalogModel(catalogModel: arr)
//                self.task2 = nil
//            }
//        }
//        runRequest(task: task2)
//    }
    
    
    override func reqFullFilterEntities(categoryId: CategoryId) {
        guard task3 == nil
            else { return }
        task3 = { [weak self] in
            DispatchQueue.global(qos: .background).async {
                guard let `self` = self else { return }
                let filters = self.applyLogic.getFilters()
               // let subfilters = self.applyLogic.getSubFilters()
                
                guard filters.count > 0
                     // && subfilters.count > 0
                    else {
                        let cnt = self.reqTry[3] ?? 0
                        if cnt < 3 {
                            print("Ошибка reqFullFilterEntities")
                            self.firebaseHandleErr(task: self.task3, taskId: 3, error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0]), delay: 1 )
                        } else {
                            //self.fireNetworkError()
                            self.reqTry[3] = 0
                            self.task3 = nil
                        }
                        return
                    }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                 //   self.fireFullFilterEntities(filters, subfilters)
                    self.fireFilterChunk1(filters)
                    self.task3 = nil
                }
            }
        }
        runRequest(task: task3)
    }
    
    
//
//    override func reqEnterSubFilter(filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice) {
////        applyLogic.doLoadSubFilters(filterId, appliedSubFilters, rangePrice)
////            .asObservable()
////            .observeOn(MainScheduler.asyncInstance)
////            .subscribe(onNext: {[weak self] res in
////                let subfiltersIds = res.1
////                let applied = res.2
////                let countsItems = res.3
////                self?.fireEnterSubFilter(filterId, subfiltersIds, applied, countsItems)
////            })
////            .disposed(by: bag)
//    }
//
//
//
//    override func reqApplyFromFilter(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
//        self.applyLogic.doApplyFromFilter(appliedSubFilters, selectedSubFilters, rangePrice)
//            .asObservable()
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {[weak self] res in
//                let filterIds = res.0
//                let subfilterIds = res.1
//                let applied = res.2
//                let selected = res.3
//                let itemIds = res.4
//                self?.fireApplyForItems(filterIds, subfilterIds, applied, selected, itemIds)
//            })
//            .disposed(by: bag)
//    }
//
//
//
//    override func reqApplyFromSubFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
//        applyLogic.doApplyFromSubFilters(filterId, appliedSubFilters, selectedSubFilters, rangePrice)
//        .asObservable()
//        .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {[weak self] res in
//                let filterIds = res.0
//                let subfilterIds = res.1
//                let applied = res.2
//                let selected = res.3
//                let rangePrice = res.4
//                let itemsTotal = res.5
//                self?.fireApplyForFilters(filterIds,
//                                           subfilterIds,
//                                           applied,
//                                           selected,
//                                           rangePrice.tipMinPrice,
//                                           rangePrice.tipMaxPrice,
//                                           itemsTotal)
//            })
//            .disposed(by: bag)
//    }
//
//
//
//    override func reqApplyByPrices(categoryId: CategoryId, rangePrice: RangePrice) {
//        applyLogic.doApplyByPrices(categoryId, rangePrice)
//        .asObservable()
//        .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {[weak self] res in
//                let filterIds: FilterIds = res
//                self?.fireApplyByPrices(filterIds)
//            })
//            .disposed(by: bag)
//    }
//
//
//    override func reqRemoveFilter(categoryId: CategoryId, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
//        applyLogic.doRemoveFilter(filterId, appliedSubFilters, selectedSubFilters, rangePrice)
//            .asObservable()
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: {[weak self] res in
//                let filterIds = res.0
//                let subfilterIds = res.1
//                let applied = res.2
//                let selected = res.3
//                let rangePrice = res.4
//                let itemsTotal = res.5
//                self?.fireApplyForFilters(filterIds,
//                                           subfilterIds,
//                                           applied,
//                                           selected,
//                                           rangePrice.tipMinPrice,
//                                           rangePrice.tipMaxPrice,
//                                           itemsTotal)
//            })
//            .disposed(by: bag)
//    }
//
    
    override func reqPreloadFullFilterEntities(categoryId: CategoryId) {
        guard task4 == nil
            else { return }
        print("start download \(self.showTime())")
        task4 = {
            functions.httpsCallable("heavyFullFilterEntities").call(["useCache":true
            ]) {[weak self] (result, error) in
                DispatchQueue.global(qos: .background).async {
                    guard let `self` = self else { return }
                    
                    if let error = error as NSError? {
                        let cnt = self.reqTry[4] ?? 0
                        if cnt < self.limitTry {
                            print("Ошибка reqPreloadFullFilterEntities")
                            self.firebaseHandleErr(task: self.task4, taskId: 4, error: error)
                        } else {
                           // self.fireNetworkError()
                            self.task4 = nil
                        }
                        return
                    }
                    
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                    let subfilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                  //  let subfiltersByFilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByFilter")
                    let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                    let itemsBySubfilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "itemsBySubfilter")
                    let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                    
                    print("get data \(self.showTime())")
                    self.applyLogic.setup(filters_: filters,
                                          subFilters_: subfilters,
                                        //  subfiltersByFilter: subfiltersByFilter,
                                          subfiltersByItem_: subfiltersByItem,
                                          itemsBySubfilter_: itemsBySubfilter,
                                          priceByItemId_: priceByItemId)
                    self.task4 = nil
                }
            }
        }
        runRequest(task: task4)
    }
    
    
    
    
    
    
    override func reqMidTotal(categoryId: CategoryId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        applyLogic.doCalcMidTotal(appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] count in
                self?.fireMidTotal(count)
            })
            .disposed(by: bag)
    }
    
  
    
    
    var taskNo: Int = 0
    var activeTasks: [Int: Completion] = [:]
    
    
    override func reqLoadUIDs(completion: (([UidModel])->Void)?) {
        taskNo += 1
        runCheckUUIDS(taskCode: NetTasksEnum.crossUIDs.rawValue, taskIdx: taskNo, completion: completion)
    }
    
    override func reqLoadCrossFilters(filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? ) {
        taskNo += 1
        runCrossFilters(taskCode: NetTasksEnum.crossFilters.rawValue, taskIdx: taskNo, filterId: filterId, completion: completion)
    }
    
    override func reqLoadCategoryFilters(categoryId: CategoryId, completion: (([FilterModel],[SubfilterModel])->Void)? ) {
        taskNo += 1
        runCategoryFilters(taskCode: NetTasksEnum.categoryFilters.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }
    
    override func reqLoadCategoryApply(categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? ) {
        taskNo += 1
        runCategoryApply(taskCode: NetTasksEnum.categoryApply.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }
    
    override func reqCatalogStart(categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? ) {
        taskNo += 1
        runCatalogStart(taskCode: NetTasksEnum.catalogStart.rawValue, taskIdx: taskNo, categoryId: categoryId, completion: completion)
    }

    override func reqPrefetch(itemIds: ItemIds, completion: (([CatalogModel1])->Void)?) {
        taskNo += 1
        runPrefetch(taskCode: NetTasksEnum.catalogPrefetch.rawValue, taskIdx: taskNo, itemIds: itemIds, completion: completion)
    }
    
    
    private func checkedReqLimit(taskIdx: Int, error: Error?) -> Bool {
        if let err = error as NSError? {
            let cnt = self.reqTry[taskIdx] ?? 0
            if cnt < self.limitTry {
                self.firebaseHandleErr(task: self.activeTasks[taskIdx]!, taskId: taskIdx, error: err)
            } else {
                self.reqTry[taskIdx] = 0
                self.activeTasks[taskIdx] = nil
            }
            return false
        }
        return true
    }
    
    
    private func runCheckUUIDS(taskCode: Int, taskIdx: Int, completion: (([UidModel])->Void)?) {
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["method":"getUIDs"]) { [weak self] (result, error) in
                guard let `self` = self else { return }
                
                if self.checkedReqLimit(taskIdx: taskIdx, error: error) == false {
                    return
                }
                
               // DispatchQueue.global(qos: .userInteractive).async {
                    let uuidModels: [UidModel] = ParsingHelper.parseUUIDModel(result: result, key: "uids")
                    completion?(uuidModels)
                    self.activeTasks[taskIdx] = nil
               // }
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    private func runCrossFilters(taskCode: Int, taskIdx: Int, filterId: Int, completion: (([FilterModel],[SubfilterModel])->Void)? ) {
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true, "filterId": filterId,  "method":"getCrossChunk4"]) { [weak self] (result, error) in
                guard let `self` = self else { return }
                
                if self.checkedReqLimit(taskIdx: taskIdx, error: error) == false {
                    return
                }
                
                let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filter")
                let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                completion?(filters, subFilters)
                self.activeTasks[taskIdx] = nil

            }
        }
        
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    

    
    private func runCategoryFilters(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: (([FilterModel], [SubfilterModel])->Void)? ){
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getCategoryFiltersChunk5"]) { [weak self] (result, error) in
                guard let `self` = self else { return }
                
                if self.checkedReqLimit(taskIdx: taskIdx, error: error) == false {
                    return
                }
                
                let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                completion?(filters, subFilters)
                self.activeTasks[taskIdx] = nil
                
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
    private func runCategoryApply(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: ((SubfiltersByItem?, PriceByItemId?)->Void)? ){
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getItemsChunk3"]) { [weak self] (result, error) in
                                                    guard let `self` = self else { return }
                       
                if self.checkedReqLimit(taskIdx: taskIdx, error: error) == false {
                    return
                }
                let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                completion?(subfiltersByItem, priceByItemId)
                self.activeTasks[taskIdx] = nil
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
   func runCatalogStart(taskCode: Int, taskIdx: Int, categoryId: CategoryId, completion: ((CategoryId, Int, ItemIds, Int, Int)->Void)? ) {
    
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId": categoryId,
                                                  "method":"getCatalogTotals"]) { [weak self] (result, error) in
                guard let `self` = self else { return }
                                                    
                if self.checkedReqLimit(taskIdx: taskIdx, error: error) == false {
                    return
                }
                let fetchLimit_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
                let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
                let minPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "minPrice")
                let maxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "maxPrice")
                
                guard let fetchLimit = fetchLimit_,
                      let minPrice = minPrice_,
                      let maxPrice = maxPrice_,
                      itemIds.count > 0
                else {
                    let _ = self.checkedReqLimit(taskIdx: taskIdx, error: NSError(domain: "Network Service: runCatalogStart no values", code: 777, userInfo: nil))
                    return
                }
                completion?(categoryId, fetchLimit, itemIds, minPrice, maxPrice)
                self.activeTasks[taskIdx] = nil
            }
        }
        
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
    
    
    
    func runPrefetch(taskCode: Int, taskIdx: Int, itemIds: ItemIds, completion: (([CatalogModel1])->Void)? ) {
        print("prefetch")
        self.activeTasks[taskIdx] = {
            functions.httpsCallable("meta").call(["useCache": true,
                                                  "itemsIds": itemIds,
                                                  "method":"getPrefetching"
            ]){[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if self.checkedReqLimit(taskIdx: taskIdx, error: error) == false {
                    return
                }
                let arr:[CatalogModel1] = ParsingHelper.parseCatalogModel1(result: result, key: "items")
                completion?(arr)
                self.activeTasks[taskIdx] = nil
            }
        }
        operationQueues[taskCode]?.addOperation {[weak self] in
            guard let task = self?.activeTasks[taskIdx] else { return }
            task?()
        }
    }
}
