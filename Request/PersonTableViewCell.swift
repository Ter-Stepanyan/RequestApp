//
//  PersonTableViewCell.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 02.02.24.
//

import Foundation
import UIKit

class PersonTableViewCell: UITableViewCell {
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
    }

    func configure(with person: Person) {
        customImageView.layer.cornerRadius = 10
        nameLabel.text = "\(person.firstName) \(person.lastName)"
        genderLabel.text = "\(person.gender.capitalized), \(person.phone)"
        countryLabel.text = person.address.country
        streetLabel.text = "\(person.address.street.number) \(person.address.street.name)"
        starImageView.isHidden = !person.isFavourite

        if let imageUrl = URL(string: person.picture.mediumPicture) {
            let task = URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.customImageView.image = image
                    }
                }
            }
            task.resume()
        }
    }
}
