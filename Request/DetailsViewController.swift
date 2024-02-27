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
    @IBOutlet weak var addFavouriteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var removeButton: UIButton!
    weak var delegate: PersonDelegate?
    var selectedPerson: Person?
    var coreDataManager: CoreDataManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let person = selectedPerson else { return }
        let nib = UINib(nibName: "DetailsCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "detailsCell")
        setMap(person: person)
        setLabels(person: person)
        setImageView(pictureUrl: person.picture.largePicture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                userImageView.isUserInteractionEnabled = true
                userImageView.addGestureRecognizer(tapGesture)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage",
           let imageViewController = segue.destination as? ImageViewController,
           let imageUrl = selectedPerson?.picture.largePicture {
            imageViewController.imageUrl = imageUrl
        }
    }

    @objc func imageTapped() {
        performSegue(withIdentifier: "showImage", sender: self)
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
        addFavouriteButton.layer.cornerRadius = 28
        removeButton.setTitle("Remove from Favourites", for: .normal)
        removeButton.setTitle(" ", for: .disabled)

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

    private func toggleFavouriteStatus(forPersonWithID id: NSManagedObjectID) {
        do {
            guard let person = try coreDataManager.context.existingObject(with: id) as? PersonEntity else {
                print("Error: Failed to fetch PersonEntity with ID: \(id)")
                return
            }
            person.isFavourite.toggle()
            coreDataManager.saveContext()
            print("isFavourite status toggled for PersonEntity with ID: \(id)")
        } catch {
            print("Error toggling isFavourite status: \(error.localizedDescription)")
        }
    }

    func getObjectID(forPerson person: Person) -> NSManagedObjectID? {
        let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "firstName == %@ AND lastName == %@", person.firstName, person.lastName)
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
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

extension DetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailsCell", for: indexPath) as? DetailsCollectionViewCell else {
            fatalError("Unable to dequeue DetailsCollectionViewCell")
        }
        let person = selectedPerson!
        cell.configure(with: person)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width = collectionView.bounds.width
           let height: CGFloat = 150

           return CGSize(width: width, height: height)
       }
}
