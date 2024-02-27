//
//  DetailsCollectionViewCell.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 27.02.24.
//

import Foundation
import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!

    func configure(with person: Person) {
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

        genderLabel.text = person.gender.capitalized
    }

    @IBAction func callPhoneNumber(_ sender: Any) {
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
}
