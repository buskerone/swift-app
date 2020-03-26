//
//  SWAPostDetailsViewController.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import UIKit
import WebKit
import JGProgressHUD

class SWAPostDetailsViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    var post: SWAPost?
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupProgressHud()
        self.setupWebView()
    }
}

extension SWAPostDetailsViewController {
    func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupProgressHud() {
        self.hud.textLabel.text = "Loading"
    }
    
    func setupWebView() {
        if let post = self.post {
            if let postUrl = post.postUrl {
                if postUrl == "" {
                    let alertController = UIAlertController(title: "Error", message:
                        "The selected story doesn't have a valid URL. Please select another one.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let url = URL(string: postUrl)!
                    self.webView.load(URLRequest(url: url))
                    self.webView.allowsBackForwardNavigationGestures = true
                    self.webView.navigationDelegate = self
                }
            }
        }
    }
}

extension SWAPostDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hud.dismiss()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.hud.show(in: self.view)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.hud.dismiss()
        let alertController = UIAlertController(title: "Error", message:
            "There is an error while trying to load the url. Please try again or select another story.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}
