import Foundation
import Firebase
import FirebaseDatabase
import SwiftyJSON

class FilterModel1 {
    
    var id = 0
    var title: String = ""
    var categoryId = 0
    var filterEnum: FilterEnum = .select
    var enabled = true
    var cross = false
    var code = 0
    var uuid = ""
    
    init(id: Int, title: String, categoryId: Int, filterEnum: FilterEnum = .select, cross: Bool = false, uuid: String = "", firebaseTemplate: FirebaseTemplate){
        self.id = id
        self.title = title
        self.cross = cross
        if !cross {
            self.categoryId = categoryId
        }
        self.filterEnum = filterEnum
        self.uuid = uuid
        firebaseTemplate.filterUpload(filter: self)
    }
    
    convenience init(_ id: Int,
                     _ title: String,
                     _ categoryId: Int,
                     _ filterEnum: FilterEnum = .select,
                     _ cross: Bool = false,
                     _ uuid: String = "",
                     _ code: Int,
                     _ filterByCode: inout [Int:Int],
                     _ next: inout Int,
                     multiPerItem: Int = 0,
                     multipleFilter: inout [Int: Int],
                     firebaseTemplate: FirebaseTemplate){
        
        self.init(id: id, title: title, categoryId: categoryId, filterEnum: filterEnum, cross: cross, uuid: uuid, firebaseTemplate: firebaseTemplate)
        filterByCode[code] = id
        next += 1
        multipleFilter[id] = multiPerItem
    }
}


class SubfilterModel1 {
    var filterId = 0
    var id = 0
    var categoryId = 0
    var title: String
    var enabled = true
    var sectionHeader = ""
    var cross = false
    
    
    init(id: Int, filterId: Int, title: String, sectionHeader: String = "", categoryId: Int, cross: Bool = false, firebaseTemplate: FirebaseTemplate) {

        self.filterId = filterId
        self.id = id
        self.title = title
        self.sectionHeader = sectionHeader
        self.cross = cross
        if !cross {
            self.categoryId = categoryId
        }
        firebaseTemplate.subfilterUpload(subFilter: self)
    }
    
    convenience init(id: Int, filterId: Int, title: String, categoryId: Int, cross: Bool = false, next: inout Int, firebaseTemplate: FirebaseTemplate, useSection: Bool = false) {
        next += 1
        var sectionHeader = ""
        if useSection {
            sectionHeader = "\(title.first!)"
        }
        self.init(id: id, filterId: filterId, title: title, sectionHeader: sectionHeader, categoryId: categoryId, cross: cross, firebaseTemplate: firebaseTemplate)
    }
    
    convenience init(_ id: Int,
                     _ filterId: Int,
                     _ title: String,
                     _ categoryId: Int,
                     _ next: inout Int,
                     subfiltersByFilter: inout [Int:[Int]],
                     firebaseTemplate: FirebaseTemplate,
                     cross : Bool = false,
                     _ sectionHeader: String = ""){
        next += 1
        if subfiltersByFilter[filterId] == nil {
            subfiltersByFilter[filterId] = []
        }
        subfiltersByFilter[filterId]?.append(id)
        self.init(id: id, filterId: filterId, title: title, sectionHeader: sectionHeader, categoryId: categoryId, cross: cross, firebaseTemplate: firebaseTemplate)
    }
}




class Item {
    var id = 0
    var subfilters: [Int] = []
    var categoryId = 0
    
    init(id: Int, subfilters: [Int], categoryId: Int, firebaseTemplate: FirebaseTemplate) {
        self.id = id
        self.subfilters = subfilters
        self.categoryId = categoryId
        firebaseTemplate.itemUpload(item: self,  subfilters: subfilters)
    }
}



class CatalogModel1 {
    let id: Int
    let categoryId: Int
    var name: String
    let thumbnail: String
    let stars: Int
    let newPrice: Int
    let oldPrice: Int
    let votes: Int
    let discount: Int
    
    
    init(id: Int, categoryId: Int, name: String, thumbnail: String,  stars: Int, newPrice: Int, oldPrice: Int, votes: Int, discount: Int, subfiltersByItem: [Int:[Int]], subFilters: [Int:SubfilterModel1], firebaseTemplate: FirebaseTemplate) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.thumbnail = thumbnail
        self.stars = stars
        self.newPrice = newPrice
        self.oldPrice = oldPrice
        self.votes = votes
        self.discount = discount
        
        let subfilters = subfiltersByItem[id]!
        var newName = "(\(id))"
        for id in subfilters {
            let model = subFilters[id]!
            newName += model.title+","
        }
        self.name = newName
        
        firebaseTemplate.catalogFirebaseStore(catalog: self)
    }
    
    required init(json: JSON?) {
        let json = json!
        self.id = json["id"].intValue
        self.categoryId = json["categoryId"].intValue
        self.name = json["name"].stringValue
        self.thumbnail = json["thumbnail"].stringValue
        self.votes = json["votes"].intValue
        
        self.stars = json["stars"].intValue
        self.newPrice =  json["newPrice"].intValue
        self.oldPrice = json["oldPrice"].intValue
        self.discount = json["discount"].intValue
    }

}


public class UidModel {
    
    var uid: String = ""
    var type: String = ""
    var categoryId: Int = 0
    var filterId: FilterId = 0
    var cross: Bool = false
    
    
    convenience init(uid: String, type: String, cross: Bool, filterId: Int, categoryId: Int, firebaseTemplate: FirebaseTemplate?) {
        self.init(json: nil)
        self.uid = uid
        self.type = type
        self.cross = cross
        self.filterId = filterId
        self.categoryId = categoryId
        firebaseTemplate?.uidModelFirebaseStore(uidModel: self)
    }
    
    
    
    
    init(json: JSON?) {
        if let json = json {
            self.uid = json["uid"].stringValue
            self.type = json["type"].stringValue
            self.cross = json["cross"].boolValue
            self.categoryId = json["categoryId"].intValue
            self.filterId = json["filterId"].intValue
        }
    }
}
