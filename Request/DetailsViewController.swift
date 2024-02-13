//
//  DetailsViewController.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 12.02.24.
//

import UIKit
import MapKit

protocol PersonDelegate: AnyObject {
    func didSelectPerson(_ person: Person)
}

class DetailsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    weak var delegate: PersonDelegate?
    var selectedPerson: Person?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let person = selectedPerson else {
            return
        }

        setMap(person: person)
        setLabels(person: person)
        setImageView(pictureUrl: person.picture.largePicture)
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

        phoneLabel.attributedText = attributedPhoneNumber
        let phoneTapGesture = UITapGestureRecognizer(target: self, action: #selector(phoneLabelTapped))
        phoneLabel.isUserInteractionEnabled = true
        phoneLabel.addGestureRecognizer(phoneTapGesture)

        let attributedAddress = NSMutableAttributedString(
            string: "\(person.address.street.name), \(person.address.city), \(person.address.country)"
        )
        attributedAddress.addAttribute(.foregroundColor,
        value: UIColor.blue,
        range: NSRange(location: 0, length: attributedAddress.length)
        )
        attributedAddress.addAttribute(.underlineStyle,
        value: NSUnderlineStyle.single.rawValue,
        range: NSRange(location: 0, length: attributedAddress.length)
        )

        addressLabel.attributedText = attributedAddress
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .right
        addressLabel.widthAnchor.constraint(equalToConstant: 180).isActive = true
        addressLabel.sizeToFit()
        addressLabel.frame.origin = CGPoint(x: view.bounds.width - addressLabel.frame.width, y: 0)
        let addressTapGesture = UITapGestureRecognizer(target: self, action: #selector(addressLabelTapped))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(addressTapGesture)
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

    @objc private func phoneLabelTapped() {
        guard let phoneNumberWithoutParentheses = phoneLabel.text?.replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        else {
            return
        }

        guard let phoneURL = URL(string: "tel://\(phoneNumberWithoutParentheses)") else {
            return
        }
        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
    }

    @objc private func addressLabelTapped() {
        guard let addressText = addressLabel.text else {
            return
        }

        guard let encodedAddress = addressText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        if let mapsURL = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
            UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
        }
    }
}
