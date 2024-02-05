//
//  CustomTableViewCell.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 31.01.24.
//
import UIKit

//class CustomTableViewCell: UITableViewCell {
//
//    let customImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    let nameLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        return label
//    }()
//
//    let genderLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = UIColor.darkGray
//        return label
//    }()
//
//    let countryLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = UIColor.darkGray
//        return label
//    }()
//
//    let streetLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = UIColor.darkGray
//        return label
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupSubviews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupSubviews() {
//        addSubview(customImageView)
//        addSubview(nameLabel)
//        addSubview(genderLabel)
//        addSubview(countryLabel)
//        addSubview(streetLabel)
//
//        NSLayoutConstraint.activate([
//            customImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            customImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
//            customImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
//
//            nameLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 16),
//            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
//
//            genderLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 16),
//            genderLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
//
//            countryLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 16),
//            countryLabel.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 4),
//
//            streetLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 16),
//            streetLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 4)
//        ])
//    }
//
//    func configure(with person: Person) {
//        customImageView.layer.cornerRadius = 10
//        nameLabel.text = "\(person.name.first) \(person.name.last)"
//        genderLabel.text = "\(person.gender.capitalized), \(person.phone)"
//        countryLabel.text = person.location.country
//        streetLabel.text = "\(person.location.street.number) \(person.location.street.name)"
//
//        if let imageUrl = URL(string: person.picture.medium) {
//            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self.customImageView.image = image
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
//}
