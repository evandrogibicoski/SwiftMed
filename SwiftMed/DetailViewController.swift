//
//  DetailViewController.swift
//  SwiftMed
//
//  Created by evandro on 9/30/20.
//  Copyright © 2020 evandro. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnReadMore: UIButton!
    
    var article = Article()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnReadMore.layer.cornerRadius = 10
        
        if article.urlToImage != nil {
            if let url = URL(string: article.urlToImage!) {
                loadImage(imageView: self.image, url: url)
            }
        } else {
            self.imageIndicator.stopAnimating()
        }
        self.lblTitle.text = article.title
        self.lblDescription.text = article.description
        
        if article.publishedAt != nil {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let currentTime = Date()
            if let date = formatter.date(from: article.publishedAt!) {
                let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: currentTime)
                var formattedString = String(format: "%ld minutes ago",difference.minute!)
                if difference.hour! > 0 {
                    formattedString = String(format: "%ld hours ago",difference.hour!)
                }
                if difference.day!  > 0 {
                    formattedString = String(format: "%ld days ago", difference.day!, difference.hour!, difference.minute!)
                }
                
                self.lblTime.text = formattedString
            }
        }
    }
    

    func loadImage(imageView: UIImageView, url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                        imageView.layer.cornerRadius = 3
                        self.imageIndicator.stopAnimating()
                    }
                }
            }
        }
    }

    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "urlSegueIdentifier") {
            let urlViewController = segue.destination as! URLViewController
            urlViewController.urlString = article.url!
        }
    }
}
