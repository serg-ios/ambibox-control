//
//  DynBackground+CoreDataProperties.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 15/12/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//
//

import Foundation
import CoreData


extension DynBackground {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DynBackground> {
        return NSFetchRequest<DynBackground>(entityName: "DynBackground")
    }

    @NSManaged public var backgrounds: [String]?
    @NSManaged public var name: String?
    @NSManaged public var leds: Int32

}
