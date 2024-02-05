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

struct Response: Codable {
    let results: [Person]
}

struct Person: Codable {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(gender, forKey: .gender)

        var nameContainer = container.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)

        try nameContainer.encode(firstName, forKey: .first)
        try nameContainer.encode(lastName, forKey: .last)
    }
}

struct Address: Codable {
    let street: String
    let city: String
    let country: String

    enum CodingKeys: String, CodingKey {
        case street
        case city
        case country
    }

    enum StreetCodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let streetContainer = try container.nestedContainer(keyedBy: StreetCodingKeys.self, forKey: .street)
        self.street = try streetContainer.decode(String.self, forKey: .name)
        self.city = try container.decode(String.self, forKey: .city)
        self.country = try container.decode(String.self, forKey: .country)
    }
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Picture: Codable {

    let mediumPicture: String

    enum CodingKeys: String, CodingKey {
        case mediumPicture = "medium"
    }
}
