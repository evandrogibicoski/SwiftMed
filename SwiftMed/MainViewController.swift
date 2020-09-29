//
//  ViewController.swift
//  SwiftMed
//
//  Created by evandro on 9/29/20.
//  Copyright © 2020 evandro. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let endpoint = "http://newsapi.org/v2/top-headlines?country=sg&category=health&apiKey=be87cc3494f44b03a3b794a24819ea90"
    let newsCellIdentifier = "NewsCell"
    var newsList = [] as! Array<NSDictionary>
    var totalCount = 0 as Int
    
        
    struct NewsModel: Codable {
        let status: Bool
        let totalResults: Int
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadJson(fromURLString: endpoint) { (result) in
            switch result {
            case .success(let data):
                self.parse(jsonData: data)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsList.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsCellIdentifier, for: indexPath) as! NewsCollectionViewCell
        
        cell.layer.cornerRadius = 10
        let newsDetail = newsList[indexPath.row]
        cell.lblTitle.text = newsDetail.value(forKey: "title") as? String
        cell.lblDetail.text = newsDetail.value(forKey: "description") as? String
        if let imageURLString = newsDetail.value(forKey: "urlToImage") as? String {
            if let url = URL(string: imageURLString) {
                loadImage(imageView: cell.image, url: url)
            }
        } else {
            cell.imageWidthConstraint.constant = 0
        }
        cell.lblAuthor.text = newsDetail.value(forKey: "author") as? String
        if let publishedAt = newsDetail.value(forKey: "publishedAt") as? String {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            if let date = formatter.date(from: publishedAt) {
                formatter.dateFormat = "MMM d"
                if cell.lblAuthor.text == nil {
                    cell.lblAuthor.text = formatter.string(from: date)
                } else {
                    cell.lblAuthor.text?.append(" \u{2022} ")
                    cell.lblAuthor.text?.append(formatter.string(from: date))
                }
                
            }
        }
        
        return cell;
    }
    
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    private func parse(jsonData: Data) {
        do {
            let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary

            let status = jsonDic?.value(forKey: "status") as? String
            if status == "ok" {
                totalCount = jsonDic?.value(forKey: "totalResults") as! Int
                newsList = jsonDic?.value(forKey: "articles") as? NSArray as! Array<NSDictionary>
            }
        } catch {
            print("decode error")
        }
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegueIdentifier") {
            let detailViewController = segue.destination as! DetailViewController
            let selectedNewsCell = sender as! NewsCollectionViewCell
            if let indexPath = self.collectionView.indexPath(for: selectedNewsCell) {
                detailViewController.newsDetail = newsList[indexPath.row]
            }
        }
    }

}

