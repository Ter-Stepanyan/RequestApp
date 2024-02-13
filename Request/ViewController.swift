//
//  ViewController.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 31.01.24.
//

import UIKit

class ViewController: UIViewController {

    private let url = "https://randomuser.me/api?seed=artak&results=20"
    @IBOutlet weak var personTableView: UITableView!
    @IBOutlet weak var personSearchBar: UISearchBar!
    weak var delegate: PersonDelegate?

    var personData: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        personSearchBar.placeholder = "Search People"
        personSearchBar.delegate = self

        let nib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        personTableView.register(nib, forCellReuseIdentifier: "customCell")

        parseJson(from: url) { data in
            self.personData = data
            DispatchQueue.main.async {
                self.personTableView.reloadData()
            }
        }
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
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personData.count
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
    let number: Int
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
