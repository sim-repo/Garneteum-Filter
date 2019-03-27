
import Foundation
import CoreData


public class NewUidPersistent: NSManagedObject {

    public func getModel() -> UidModel {
        return UidModel(uid: self.uid, type: self.type, cross: self.cross, filterId: Int(self.filterId) , categoryId: Int(self.categoryId), firebaseTemplate: nil)
    }
    
    public func setup(uidModel: UidModel) {
        self.uid = uidModel.uid
        self.type = uidModel.type
        self.categoryId = Int32(uidModel.categoryId)
        self.filterId = Int32(uidModel.filterId)
        self.cross = uidModel.cross
    }
}
