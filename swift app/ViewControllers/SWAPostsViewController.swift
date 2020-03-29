//
//  SWAPostsViewController.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import UIKit
import JGProgressHUD
import RealmSwift
import DZNEmptyDataSet
import SwiftDate

class SWAPostsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let reuseIdentifier = "SWAPostTableViewCellIdentifier"
    let kShowPostDetailsViewControllerSegue = "SWASegueShowPostDetailsViewController"
    let networking = SWANetworkingService.shared
    let realm = try! Realm()
    var refreshControl: UIRefreshControl!
    var posts = [SWAPost]()
    var post: SWAPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupRefreshControl()
        self.getPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.kShowPostDetailsViewControllerSegue {
            let vc = segue.destination as! SWAPostDetailsViewController
            vc.post = self.post
        }
    }
}

extension SWAPostsViewController {
    
    func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
    }
    
    func setupRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    func getPosts() {
        
        let urlPath = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
        let hud = JGProgressHUD(style: .dark)
        
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        networking.request(_urlPath: urlPath) { (result) in
            
            OperationQueue.main.addOperation({
                hud.dismiss()
            })
            
            switch result {
            case .success(let data):
                
                self.posts = self.parseJsonData(data: data)
                self.posts = self.posts.sorted(by: { $0.postDate?.compare($1.postDate!) == .orderedAscending })
                self.saveData(posts: self.posts)

                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                })
                
            case .failure(let error):
                
                // Awful but works for now. We should use something like Reachability pod to check internet connection
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    self.readData()
                } else {
                    let alertController = UIAlertController(title: "Error", message:
                        "An error occurred when trying to fetch Hacker News posts. Please try again later.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func parseJsonData(data: Data) -> [SWAPost] {
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            guard let jsonPosts = jsonResult?["hits"] as? [AnyObject] else {
                return []
            }
            
            for jsonPost in jsonPosts {
                
                let post = SWAPost()
                if let createdAt = jsonPost["created_at"] as? String, let author = jsonPost["author"], let url = jsonPost["story_url"] {
                    
                    let date = createdAt
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let finalDate = dateFormatter.date(from:date)!
                    
                    post.postDate = "\(finalDate.getInterval(toDate: Date(), component: .minute))m"
                    post.postAuthor = author as? String ?? ""
                    post.postUrl = url as? String ?? ""
                    post.postId = "\(author as? String ?? "") - \(createdAt as? String ?? "")"
                }
                if let storyTitle = jsonPost["story_title"] {
                    post.postTitle = storyTitle as? String ?? "No title available"
                } else if let title = jsonPost["title"] {
                    post.postTitle = title as? String ?? "No title available"
                }
                
                self.posts.append(post)
            }
        } catch {
            print(error)
        }

        return posts
    }
    
    func saveData(posts: [SWAPost]) {
        
        OperationQueue.main.addOperation({
            
            do {
                try self.realm.write {
                    self.realm.add(posts)
                }
            } catch {
                print("Error saving post \(error)")
            }
        })
    }
    
    func readData() {
        OperationQueue.main.addOperation({
            
            do {
                let posts = self.realm.objects(SWAPost.self)
                self.posts = Array(posts)
                self.tableView.reloadData()
            } catch {
                print("Error saving post \(error)")
            }
        })
    }
    
    //MARK: Pull to refresh
    @objc func refresh(sender:UIRefreshControl)
    {
        self.getPosts()
        sender.endRefreshing()
    }
}

extension SWAPostsViewController {
    
    func showPostDetails(_ post:SWAPost) {
        self.post = post
        self.performSegue(withIdentifier: self.kShowPostDetailsViewControllerSegue, sender: nil)
    }
}

extension SWAPostsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postItem = posts[indexPath.row]
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as? SWAPostTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(postItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            OperationQueue.main.addOperation({
                do {
                    try! self.realm.write {
                        self.realm.delete(self.posts[indexPath.row])
                    }
                } catch {
                    print("Error deleting post \(error)")
                }
            })
            
            self.posts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension SWAPostsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.showPostDetails(self.posts[indexPath.row])
    }
}

extension SWAPostsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Hey! Welcome to Swift Demo App"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "There are no posts at the moment. Please connect to a Wi-Fi network or turn on your 4G."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "app")
    }
}
