//
//  Background+CoreDataProperties.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 28/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//
//

import Foundation
import CoreData


extension Background {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Background> {
        return NSFetchRequest<Background>(entityName: "Background")
    }

    @NSManaged public var leds: Int32
    @NSManaged public var name: String?
    @NSManaged public var value: String?

}
