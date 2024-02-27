//
//  CoreDataManager.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 22.02.24.
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func savePersonToCoreData(_ person: Person) {
        if let existingPerson = fetchPerson(firstName: person.firstName, lastName: person.lastName) {
            updatePersonInCoreData(existingPerson)
            print("Person updated in Core Data")
        } else {
            let personEntity = PersonEntity(context: context)
            configurePersonEntity(personEntity, with: person)
            saveContext()
            print("Person saved to Core Data")
        }
    }

    func saveDataToCoreData(_ persons: [Person]) {
            for person in persons {
                if fetchPerson(firstName: person.firstName, lastName: person.lastName) != nil {
                    updatePersonInCoreData(person)
                } else {
                    savePersonToCoreData(person)
                }
            }
        }

        func fetchData(isFavourite: Bool) -> [Person] {
            let personEntities = coreDataFetchData(isFavourite: isFavourite)
            return personEntities.map { personEntity in
                return Person(
                    gender: personEntity.gender ?? "",
                    firstName: personEntity.firstName ?? "",
                    lastName: personEntity.lastName ?? "",
                    address: Address(
                        street: Street(
                            number: personEntity.addressStreetNumber,
                            name: personEntity.addressStreetName ?? ""
                        ),
                        city: personEntity.addressCity ?? "",
                        country: personEntity.addressCountry ?? "",
                        coordinates: Coordinates(
                            latitude: personEntity.addressCoordinatesLatitude ?? "",
                            longitude: personEntity.addressCoordinatesLongitude ?? ""
                        )
                    ),
                    phone: personEntity.phone ?? "",
                    picture: Picture(
                        largePicture: personEntity.largePicture ?? "",
                        mediumPicture: personEntity.mediumPicture ?? ""
                    ),
                    isFavourite: personEntity.isFavourite
                )
            }
        }

        private func coreDataFetchData(isFavourite: Bool) -> [PersonEntity] {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            if isFavourite {
                fetchRequest.predicate = NSPredicate(format: "isFavourite == true")
            }
            do {
                return try context.fetch(fetchRequest)
            } catch {
                print("Error fetching data from Core Data: \(error)")
                return []
            }
        }

    func updatePersonInCoreData(_ person: Person) {
        let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "firstName == %@ AND lastName == %@", person.firstName, person.lastName
        )
        do {
            let existingPersons = try context.fetch(fetchRequest)
            if let existingPerson = existingPersons.first {
                configurePersonEntity(existingPerson, with: person)
                print("Person updated in Core Data")
            } else {
                print("Person not found for update")
            }
        } catch {
            print("Error updating person in Core Data: \(error)")
        }
    }

    func fetchPerson(firstName: String, lastName: String) -> Person? {
        let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "firstName == %@ AND lastName == %@", firstName, lastName
        )
        do {
            let existingPersons = try context.fetch(fetchRequest)
            if let existingPerson = existingPersons.first {
                return Person(
                    gender: existingPerson.gender ?? "",
                    firstName: existingPerson.firstName ?? "",
                    lastName: existingPerson.lastName ?? "",
                    address: Address(
                        street: Street(
                            number: existingPerson.addressStreetNumber,
                            name: existingPerson.addressStreetName ?? ""),
                        city: existingPerson.addressCity ?? "",
                        country: existingPerson.addressCountry ?? "",
                        coordinates: Coordinates(
                            latitude: existingPerson.addressCoordinatesLatitude ?? "",
                            longitude: existingPerson.addressCoordinatesLongitude ?? "")
                    ),
                    phone: existingPerson.phone ?? "",
                    picture: Picture(
                        largePicture: existingPerson.largePicture ?? "",
                        mediumPicture: existingPerson.mediumPicture ?? ""
                    ),
                    isFavourite: existingPerson.isFavourite
                )
            } else {
                return nil
            }
        } catch {
            print("Error fetching person from Core Data: \(error)")
            return nil
        }
    }

    private func configurePersonEntity(_ personEntity: PersonEntity, with person: Person) {
        personEntity.gender = person.gender
        personEntity.firstName = person.firstName
        personEntity.lastName = person.lastName
        personEntity.addressStreetNumber = person.address.street.number
        personEntity.addressStreetName = person.address.street.name
        personEntity.addressCity = person.address.city
        personEntity.addressCountry = person.address.country
        personEntity.addressCoordinatesLatitude = person.address.coordinates.latitude
        personEntity.addressCoordinatesLongitude = person.address.coordinates.longitude
        personEntity.phone = person.phone
        personEntity.largePicture = person.picture.largePicture
        personEntity.mediumPicture = person.picture.mediumPicture
        personEntity.isFavourite = person.isFavourite
    }

    func updateFavoriteStatus(for person: inout Person) {
        person.isFavourite.toggle() // Toggle the favorite status
        saveContext() // Save the changes to Core Data
    }
    private init() {}
}
