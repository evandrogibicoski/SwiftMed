//
//  DetailViewController.swift
//  SwiftMed
//
//  Created by bigstar on 9/30/20.
//  Copyright © 2020 evandro. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var newsDetail = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageURLString = newsDetail.value(forKey: "urlToImage") as? String {
            if let url = URL(string: imageURLString) {
                loadImage(imageView: self.image, url: url)
            }
        }
        self.lblTitle.text = newsDetail.value(forKey: "title") as? String
    }
    

    func loadImage(imageView: UIImageView, url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                        imageView.layer.cornerRadius = 3
                    }
                }
            }
        }
    }

}
