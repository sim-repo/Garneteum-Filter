//
//  PrefetchPersistent+CoreDataProperties.swift
//  MvvMcoord
//
//  Created by Igor Ivanov on 27/03/2019.
//  Copyright © 2019 Igor Ivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension PrefetchPersistent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrefetchPersistent> {
        return NSFetchRequest<PrefetchPersistent>(entityName: "PrefetchPersistent")
    }

    @NSManaged public var categoryId: Int32
    @NSManaged public var discount: Int32
    @NSManaged public var itemId: Int32
    @NSManaged public var name: String
    @NSManaged public var newPrice: Double
    @NSManaged public var oldPrice: Double
    @NSManaged public var stars: Int16
    @NSManaged public var thumbnail: String
    @NSManaged public var votes: Int16

}
