//
//  PersonEntity+CoreDataProperties.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 26.02.24.
//
//

import Foundation
import CoreData

extension PersonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonEntity> {
        return NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
    }

    @NSManaged public var addressCity: String?
    @NSManaged public var addressCoordinatesLatitude: String?
    @NSManaged public var addressCoordinatesLongitude: String?
    @NSManaged public var addressCountry: String?
    @NSManaged public var addressStreetName: String?
    @NSManaged public var addressStreetNumber: Int32
    @NSManaged public var firstName: String?
    @NSManaged public var gender: String?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var largePicture: String?
    @NSManaged public var lastName: String?
    @NSManaged public var mediumPicture: String?
    @NSManaged public var phone: String?

}

extension PersonEntity : Identifiable {

}
