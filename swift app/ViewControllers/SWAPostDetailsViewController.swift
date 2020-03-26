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
        self.setupProgressHud()
        self.setupWebView()
    }
}

extension SWAPostDetailsViewController {
    func setupProgressHud() {
        self.hud.textLabel.text = "Loading"
    }
    
    func setupWebView() {
        if let postUrl = self.post?.postUrl {
            let url = URL(string: postUrl)!
            self.webView.load(URLRequest(url: url))
            self.webView.allowsBackForwardNavigationGestures = true
            self.webView.navigationDelegate = self
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
}
