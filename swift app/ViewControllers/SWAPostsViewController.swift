//
//  SWAPostsViewController.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol SWAPostDetailsProtocol: class {
    func showPostDetails(_ post:SWAPost)
}

class SWAPostsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var kShowPostDetailsViewControllerSegue = "SWASegueShowPostDetailsViewController"
    var refreshControl: UIRefreshControl!
    var posts = [SWAPost]()
    var post: SWAPost?
    
    // MARK: Data provider
    var provider: SWAPostsDataProvider?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDataProvider()
        self.setupRefreshControl()
        self.getPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.kShowPostDetailsViewControllerSegue {
            let vc = segue.destination as! SWAPostDetailsViewController
            vc.post = self.post
        }
    }
}

extension SWAPostsViewController {
    func setupDataProvider() {
        self.provider = SWAPostsDataProvider(tableView: self.tableView)
        self.provider?.delegate = self
    }
    
    func setupRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    func getPosts() {
        guard let postsURL = URL(string: "http://hn.algolia.com/api/v1/search_by_date?query=ios") else {
            return
        }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        let request = URLRequest(url: postsURL)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            OperationQueue.main.addOperation({
                hud.dismiss()
            })
            
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                self.posts = self.parseJsonData(data: data)
                OperationQueue.main.addOperation({
                    self.posts = self.posts.sorted(by: { $0.postDate?.compare($1.postDate!) == .orderedAscending })
                    self.provider?.postsItems = self.posts
                    self.tableView.reloadData()
                })
            }
        })
        
        task.resume()
    }
    
    func parseJsonData(data: Data) -> [SWAPost] {
        var posts = [SWAPost]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            guard let jsonPosts = jsonResult?["hits"] as? [AnyObject] else {
                return []
            }
            
            for jsonPost in jsonPosts {
                var post = SWAPost()
                if let createdAt = jsonPost["created_at"], let author = jsonPost["author"], let url = jsonPost["story_url"] {
                    post.postDate = createdAt as? String ?? ""
                    post.postAuthor = author as? String ?? ""
                    post.postUrl = url as? String ?? ""
                }
                if let storyTitle = jsonPost["story_title"] {
                    post.postTitle = storyTitle as? String ?? "No title available"
                } else if let title = jsonPost["title"] {
                    post.postTitle = title as? String ?? "No title available"
                }
                posts.append(post)
            }
        } catch {
            print(error)
        }
        return posts
    }
    
    //MARK: Pull to refresh
    @objc func refresh(sender:UIRefreshControl)
    {
        getPosts()
        sender.endRefreshing()
    }
}

extension SWAPostsViewController: SWAPostDetailsProtocol {
    func showPostDetails(_ post:SWAPost) {
        self.post = post
        self.performSegue(withIdentifier: self.kShowPostDetailsViewControllerSegue, sender: nil)
    }
}
