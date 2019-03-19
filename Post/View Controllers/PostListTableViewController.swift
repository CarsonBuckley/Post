//
//  PostListTableViewController.swift
//  Post
//
//  Created by Carson Buckley on 3/18/19.
//  Copyright © 2019 Launch. All rights reserved.
//

import UIKit

class PostListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var postTableView: UITableView!
    
    let postController = PostController()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        
        postTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        postTableView.rowHeight = UITableView.automaticDimension
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }

    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.postTableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) - " + "\(post.date ?? "")"

        return cell
    }
    
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField = UITextField()
        newPostAlertController.addTextField { (usernameTF) in
            usernameTF.placeholder = "Enter Username"
            usernameTextField = usernameTF
        }
        
        var messageTextField = UITextField()
        newPostAlertController.addTextField { (messageTF) in
            messageTF.placeholder = "Enter Message"
            messageTextField = messageTF
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (postAction) in
            guard let username = usernameTextField.text, !username.isEmpty,
                let text = messageTextField.text, !text.isEmpty else {
                    return
            }
            
            self.postController.addNewPostWith(username: username, text: text, completion: {
                self.reloadTableView()
        })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        newPostAlertController.addAction(postAction)
        newPostAlertController.addAction(cancelAction)
        
        self.present(newPostAlertController, animated: true, completion: nil)
        
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Missing Info", message: "Make sure both Text Fields are filled out", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
}

extension PostListTableViewController {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts {
                self.reloadTableView()
            }
        }
    }
}
