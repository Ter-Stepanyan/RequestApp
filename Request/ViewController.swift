//
//  ViewController.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 31.01.24.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    private let url = "https://randomuser.me/api?seed=artak&results=50"
    @IBOutlet weak var personTableView: UITableView!
    @IBOutlet weak var personSearchBar: UISearchBar!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    weak var delegate: PersonDelegate?

    var personData: [Person] = []
    var hasParsedData = false
    var isDataFetched = false
    static var context: NSManagedObjectContext!
    static var appDelegate: AppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        personSearchBar.placeholder = "Search People"
        personSearchBar.delegate = self
        let nib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        personTableView.register(nib, forCellReuseIdentifier: "customCell")
        initializeContext()

        if !hasParsedData {
            parseJson(from: url) { data in
                if !data.isEmpty {
                    self.saveDataToCoreData(data)
                }
                DispatchQueue.main.async {
                    self.fetchData(isOn: self.favouriteSwitch.isOn)
                }
            }
            hasParsedData = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData(isOn: self.favouriteSwitch.isOn)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            if let destinationVC = segue.destination as? DetailsViewController,
               let indexPath = personTableView.indexPathForSelectedRow {
                let selectedPerson = personData[indexPath.row]
                destinationVC.selectedPerson = selectedPerson
            }
        }
    }

    private func parseJson(from url: String, completion: @escaping ([Person]) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            var result: Response?
            do {
                result = try JSONDecoder().decode(Response.self, from: data)
            } catch {
                print("failed to convert \(error.localizedDescription)")
            }
            guard let personResponse = result else {
                return
            }
            completion(personResponse.results)
        }
        task.resume()
    }

    private func saveDataToCoreData(_ persons: [Person]) {

        for person in persons {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "firstName == %@ AND lastName == %@", person.firstName, person.lastName
            )
            do {
                let existingPersons = try ViewController.context.fetch(fetchRequest)
                if let existingPerson = existingPersons.first {
                    existingPerson.gender = person.gender
                    existingPerson.addressStreetNumber = person.address.street.number
                    existingPerson.addressStreetName = person.address.street.name
                    existingPerson.addressCity = person.address.city
                    existingPerson.addressCountry = person.address.country
                    existingPerson.addressCoordinatesLatitude = person.address.coordinates.latitude
                    existingPerson.addressCoordinatesLongitude = person.address.coordinates.longitude
                    existingPerson.phone = person.phone
                    existingPerson.pictureLargePicture = person.picture.largePicture
                    existingPerson.pictureMediumPicture = person.picture.mediumPicture
                    print("Person updated in Core Data")
                } else {
                    let personEntity = PersonEntity(context: ViewController.context)
                    personEntity.firstName = person.firstName
                    personEntity.gender = person.gender
                    personEntity.lastName = person.lastName
                    personEntity.addressStreetNumber = person.address.street.number
                    personEntity.addressStreetName = person.address.street.name
                    personEntity.addressCity = person.address.city
                    personEntity.addressCountry = person.address.country
                    personEntity.addressCoordinatesLatitude = person.address.coordinates.latitude
                    personEntity.addressCoordinatesLongitude = person.address.coordinates.longitude
                    personEntity.phone = person.phone
                    personEntity.pictureLargePicture = person.picture.largePicture
                    personEntity.pictureMediumPicture = person.picture.mediumPicture
                    personEntity.isFavourite = person.isFavourite
                    print("Person saved to Core Data")
                }
                try ViewController.context.save()
            } catch {
                print("Error saving person to Core Data: \(error)")
            }
        }
    }

    private func fetchData(isOn: Bool) {
        let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()

        do {
            let personEntities: [PersonEntity]
            if !isOn {
                personEntities = try ViewController.context.fetch(fetchRequest)
            } else {
                fetchRequest.predicate = NSPredicate(format: "isFavourite == true")
                personEntities = try ViewController.context.fetch(fetchRequest)
            }
            personData = personEntities.map { personEntity in
                return Person(
                    gender: personEntity.gender ?? "",
                    firstName: personEntity.firstName ?? "",
                    lastName: personEntity.lastName ?? "",
                    address: Address(
                        street: Street(
                            number: personEntity.addressStreetNumber,
                            name: personEntity.addressStreetName ?? ""),
                        city: personEntity.addressCity ?? "",
                        country: personEntity.addressCountry ?? "",
                        coordinates: Coordinates(
                            latitude: personEntity.addressCoordinatesLatitude ?? "",
                            longitude: personEntity.addressCoordinatesLongitude ?? "")
                    ),
                    phone: personEntity.phone ?? "",
                    picture: Picture(
                        largePicture: personEntity.pictureLargePicture ?? "",
                        mediumPicture: personEntity.pictureMediumPicture ?? ""
                    ),
                    isFavourite: personEntity.isFavourite
                )
            }
            isDataFetched = true
            print("Successfully fetched data from Core Data")
        } catch {
            print("Error fetching data from Core Data: \(error)")
        }
        personData.sort { $0.firstName < $1.firstName }

        DispatchQueue.main.async {
            self.personTableView.reloadData()
        }
    }

    private func clearDataFromCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PersonEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try ViewController.context.execute(deleteRequest)
            print("Existing data cleared from Core Data")
        } catch {
            print("Error clearing existing data from Core Data: \(error)")
        }
    }

    private func initializeContext() {
        ViewController.appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        ViewController.context = ViewController.appDelegate?.persistentContainer.viewContext
    }

    @IBAction func toggleFavourites(_ sender: Any) {
        fetchData(isOn: self.favouriteSwitch.isOn)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isDataFetched ? personData.count : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? PersonTableViewCell

        let person = personData[indexPath.row]
        cell?.configure(with: person)

        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPerson = personData[indexPath.row]
        self.delegate?.didSelectPerson(selectedPerson)
        performSegue(withIdentifier: "toDetails", sender: delegate)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
           if let searchText = searchBar.text {
               scrollToFirstMatchingRow(searchText)
           }
       }

    private func scrollToFirstMatchingRow(_ searchText: String) {
        if let index = personData.firstIndex(where: { person in
            let fullName = "\(person.firstName) \(person.lastName)"
            let address = "\(person.address.street)"
            return fullName.lowercased().contains(searchText.lowercased()) ||
            address.lowercased().contains(searchText.lowercased())
        }) {
            let indexPath = IndexPath(row: index, section: 0)
            personTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

extension ViewController: PersonDelegate {
    func didSelectPerson(_ person: Person) {
        let detailsVC = storyboard?.instantiateViewController(
            withIdentifier: "DetailsViewController") as? DetailsViewController
        detailsVC?.selectedPerson = person
        navigationController?.pushViewController(detailsVC!, animated: true)
    }
}

struct Response: Decodable {
    let results: [Person]
}

struct Person: Decodable {
    let gender: String
    let firstName: String
    let lastName: String
    let address: Address
    let phone: String
    let picture: Picture
    var isFavourite = false

    enum CodingKeys: String, CodingKey {
        case gender
        case name
        case first
        case last
        case address = "location"
        case phone
        case picture
    }

    enum NameCodingKeys: String, CodingKey {
        case first
        case last
    }

    init(gender: String, firstName: String, lastName: String, address: Address,
         phone: String, picture: Picture, isFavourite: Bool) {
        self.gender = gender
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.phone = phone
        self.picture = picture
        self.isFavourite = isFavourite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nameContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .name)
        gender = try container.decode(String.self, forKey: .gender)
        address = try container.decode(Address.self, forKey: .address)
        phone = try container.decode(String.self, forKey: .phone)
        picture = try container.decode(Picture.self, forKey: .picture)
        firstName = try nameContainer.decode(String.self, forKey: .first)
        lastName = try nameContainer.decode(String.self, forKey: .last)
    }
}

struct Address: Codable {
    let street: Street
    let city: String
    let country: String
    let coordinates: Coordinates

    enum CodingKeys: String, CodingKey {
        case street
        case city
        case country
        case coordinates
    }
}

struct Street: Codable {
    let number: Int32
    let name: String
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Picture: Codable {

    let largePicture: String
    let mediumPicture: String

    enum CodingKeys: String, CodingKey {
        case largePicture = "large"
        case mediumPicture = "medium"
    }
}
