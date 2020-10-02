//
//  URLViewController.swift
//  SwiftMed
//
//  Created by evandro on 10/2/20.
//  Copyright © 2020 evandro. All rights reserved.
//

import UIKit
import WebKit

class URLViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var urlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activity.stopAnimating()
    }

}
