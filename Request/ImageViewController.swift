//
//  ImageViewController.swift
//  Request
//
//  Created by Artak Ter-Stepanyan on 26.02.24.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    var imageUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageUrl = imageUrl,
           let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
