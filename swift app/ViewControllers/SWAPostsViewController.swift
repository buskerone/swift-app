//
//  SWAPostsViewController.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import UIKit
import JGProgressHUD

class SWAPostsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Data provider
    var provider: SWAPostsDataProvider?
    var posts = [SWAPost]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDataProvider()
        self.getPosts()
    }
}

extension SWAPostsViewController {
    func setupDataProvider() {
        self.provider = SWAPostsDataProvider(tableView: self.tableView)
    }
    
    func getPosts() {
        guard let postsURL = URL(string: "http://hn.algolia.com/api/v1/search_by_date?query=ios") else {
            return
        }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Cargando"
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
                if let createdAt = jsonPost["created_at"] {
                    post.postDate = createdAt as? String ?? ""
                }
                if let author = jsonPost["author"] {
                    post.postAuthor = author as? String ?? ""
                }
                if let storyTitle = jsonPost["story_title"] {
                    post.postTitle = storyTitle as? String ?? "No title available"
                } else if let title = jsonPost["title"] {
                    post.postTitle = title as? String ?? "No title available"
                }
                if let url = jsonPost["story_url"] {
                    post.postUrl = url as? String ?? ""
                }
                posts.append(post)
            }
        } catch {
            print(error)
        }
        return posts
    }
}
