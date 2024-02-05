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
            let fullName = "\(person.name.first) \(person.name.last)"
            let address = "\(person.location.street.number) \(person.location.street.name)"
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
    let name: Name
    let location: Location
    let phone: String
    let picture: Picture
}

struct Name: Codable {
    let first: String
    let last: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let country: String
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Picture: Codable {
    let medium: String
}
