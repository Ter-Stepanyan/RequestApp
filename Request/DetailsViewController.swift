//
//  DetailsViewController.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 12.02.24.
//

import UIKit
import MapKit
import CoreData

protocol PersonDelegate: AnyObject {
    func didSelectPerson(_ person: Person)
}

class DetailsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var addFavouriteButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    weak var delegate: PersonDelegate?
    var selectedPerson: Person?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let person = selectedPerson else { return }
        setMap(person: person)
        setLabels(person: person)
        setImageView(pictureUrl: person.picture.largePicture)
        addressButton.titleLabel?.numberOfLines = 3
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedPerson!.isFavourite {
            addFavouriteButton.isEnabled = false
            addFavouriteButton.backgroundColor = UIColor.lightGray
        } else {
            addFavouriteButton.isEnabled = true
            addFavouriteButton.backgroundColor = UIColor.darkGreen
        }
    }

    private func setMap(person: Person) {
        if let latitude = Double(person.address.coordinates.latitude),
           let longitude = Double(person.address.coordinates.longitude) {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(person.firstName) \(person.lastName)"
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    private func setLabels(person: Person) {
        nameLabel.text = "\(person.firstName) \(person.lastName)"
        genderLabel.text = person.gender.capitalized

        let attributedPhoneNumber = NSMutableAttributedString(string: person.phone)
        attributedPhoneNumber.addAttribute(.foregroundColor,
                                           value: UIColor.blue,
                                           range: NSRange(location: 0, length: attributedPhoneNumber.length)
        )
        attributedPhoneNumber.addAttribute(.underlineStyle,
                                           value: NSUnderlineStyle.single.rawValue,
                                           range: NSRange(location: 0, length: attributedPhoneNumber.length)
        )
        phoneButton.setAttributedTitle(attributedPhoneNumber, for: .normal)
        phoneButton.titleLabel?.textAlignment = .right
        phoneButton.contentHorizontalAlignment = .right
        phoneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        phoneButton.titleLabel?.lineBreakMode = .byWordWrapping

        let attributedAddress = NSMutableAttributedString(
            string: "\(person.address.country), \(person.address.street.number) \(person.address.street.name)"
        )
        attributedAddress.addAttribute(.foregroundColor,
                                       value: UIColor.blue,
                                       range: NSRange(location: 0, length: attributedAddress.length)
        )
        attributedAddress.addAttribute(.underlineStyle,
                                       value: NSUnderlineStyle.single.rawValue,
                                       range: NSRange(location: 0, length: attributedAddress.length)
        )
        addressButton.titleLabel?.numberOfLines = 0
        addressButton.setAttributedTitle(attributedAddress, for: .normal)
        addressButton.titleLabel?.textAlignment = .right
        addressButton.contentHorizontalAlignment = .right
        addressButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        addressButton.titleLabel?.lineBreakMode = .byWordWrapping
        addFavouriteButton.layer.cornerRadius = 28
        removeButton.setTitle("Remove from Favourites", for: .normal)
        removeButton.setTitle("           ", for: .disabled)

        if !person.isFavourite {
            addFavouriteButton.isEnabled = true
            removeButton.isEnabled = false
        }
    }

    private func setImageView(pictureUrl: String) {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        if let url = URL(string: pictureUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
            }.resume()
        }
    }

    @IBAction func callTheNumber(_ sender: Any) {
        guard let phoneNumberWithoutParentheses = phoneButton.titleLabel?.text?.replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        else { return }

        guard let phoneURL = URL(string: "tel://\(phoneNumberWithoutParentheses)") else { return }
        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
    }

    @IBAction func openMap(_ sender: Any) {
        guard let addressText = addressButton.titleLabel?.text else { return }
        guard let encodedAddress = addressText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }

        if let mapsURL = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
            UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
        }
    }

    private func toggleFavouriteStatus(forPersonWithID id: NSManagedObjectID) {
            do {
                let person = try ViewController.context.existingObject(with: id) as? PersonEntity
                person!.isFavourite.toggle()
                try ViewController.context.save()
                print("isFavourite status toggled for PersonEntity with ID: \(id)")
            } catch {
                print("Error toggling isFavourite status: \(error.localizedDescription)")
            }
        }

        func getObjectID(forPerson person: Person) -> NSManagedObjectID? {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "firstName == %@ AND lastName == %@", person.firstName, person.lastName
            )

            do {
                let result = try ViewController.context.fetch(fetchRequest)
                if let personEntity = result.first {
                    return personEntity.objectID
                }
            } catch {
                print("Error fetching PersonEntity: \(error.localizedDescription)")
            }
            return nil
        }

        @IBAction func addToFavourite(_ sender: Any) {
            toggleFavouriteStatus(forPersonWithID: getObjectID(forPerson: selectedPerson!)!)
            addFavouriteButton.setTitle("Person is Favourite", for: .disabled)
            addFavouriteButton.backgroundColor = UIColor.lightGray
            addFavouriteButton.isEnabled = false
            addFavouriteButton.setTitleColor(UIColor.black, for: .disabled)
            removeButton.isEnabled = true
    }

    @IBAction func removeFromFavourite(_ sender: Any) {
        toggleFavouriteStatus(forPersonWithID: getObjectID(forPerson: selectedPerson!)!)
        addFavouriteButton.isEnabled = true
        addFavouriteButton.setTitle("Add to Favourites", for: .normal)
        addFavouriteButton.setTitleColor(UIColor.white, for: .normal)
        addFavouriteButton.backgroundColor = UIColor.darkGreen
        removeButton.isEnabled = false
    }
}
