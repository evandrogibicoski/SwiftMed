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
    var totalCount = 0 as Int
    
    var articles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadJson(fromURLString: endpoint) { (result) in
            switch result {
            case .success(let data):
                self.parse(jsonData: data)
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
             }
         }
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
        let decoder = JSONDecoder()
        if let newsData = try? decoder.decode(News.self, from: jsonData) {
            articles = newsData.articles
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }

        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsCellIdentifier, for: indexPath) as! NewsCollectionViewCell
        
        cell.layer.cornerRadius = 10
        let article = articles[indexPath.row]
        cell.lblTitle.text = article.title
        cell.lblDetail.text = article.description
        if article.urlToImage == nil {
            cell.activityIndicator.stopAnimating()
            cell.imageWidthConstraint.constant = 0
        } else {
            if let url = URL(string: article.urlToImage!) {
                loadImage(imageView: cell.image, url: url, indicator: cell.activityIndicator)
            }
        }
        cell.lblAuthor.text = article.author
        if article.publishedAt != nil {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            if let date = formatter.date(from: article.publishedAt!) {
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
    
    func loadImage(imageView: UIImageView, url: URL, indicator: UIActivityIndicatorView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                        imageView.layer.cornerRadius = 3
                        indicator.stopAnimating()
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
                detailViewController.article = articles[indexPath.row]
            }
        }
    }

}

