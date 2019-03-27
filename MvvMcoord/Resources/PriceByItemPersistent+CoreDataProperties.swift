//
//  PriceByItemPersistent+CoreDataProperties.swift
//  MvvMcoord
//
//  Created by Igor Ivanov on 25/03/2019.
//  Copyright © 2019 Igor Ivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension PriceByItemPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceByItemPersistent> {
        return NSFetchRequest<PriceByItemPersistent>(entityName: "PriceByItemPersistent")
    }

    @NSManaged public var itemId: Int32
    @NSManaged public var price: Double
    @NSManaged public var categoryId: Int32

}
