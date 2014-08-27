//
//  ViewController.swift
//  GithubExample
//
//  Created by Josh Holtz on 8/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var tblRepos: UITableView!
    
    var repos = [RepoModel]()
    var openedOnce = false
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Need this for models to know which network adapter to use
        // This should probably go in AppDelegate but putting it here cause yeah
        HarmonicConfig.adapter = HarmonicAlamofireAdapter(manager: Alamofire.Manager(), encoding: Alamofire.ParameterEncoding.URL)
        
        GithubAuth.Config.redirectURI = "harmonicexample://githubcallback"
        GithubAuth.Config.clientId = "5e2ece3c78578d4a7980"
        GithubAuth.Config.clientSecret = "0aef7d2b1743d161f06c3d75defa7cb2a90b0ced"

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!GithubAuth.session.isLoggedIn()) {
            GithubAuth.session.authCallback = { (error) in
                self.txtUsername.text = "joshdholtz"
                self.fetchRepos(self.txtUsername.text)
            }
            GithubAuth.session.login()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.repos.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let repo = self.repos[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoCell", forIndexPath: indexPath) as UITableViewCell
        
        // Set repo name
        let label: UILabel = cell.viewWithTag(1) as UILabel
        label.text = repo.fullName
        
        return cell
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        fetchRepos(textField.text)
        return false
    }
    
    // MARK: Private
    
    func fetchRepos(username: String) {
        self.isSearching(true);
        
        // Fetches user
        var user = UserModel(login: username)
        user.get(parameters: ["access_token": GithubAuth.session.accessToken!]) {(request, response, model, error) in
            if (error != nil) {
                println("User Error - \(error?.localizedDescription)")
                self.isSearching(false);
                return
            }
            
            // Fetches repos
            RepoModel.get(user, searchParameters: ["access_token": GithubAuth.session.accessToken!]) {(request, response, models, error) in
                if (error != nil) { println("Repo Error - \(error?.localizedDescription)") }
                
                // Clear, add, reload
                if let repos = models as? [RepoModel] {
                    self.repos.removeAll()
                    self.repos += repos
                    self.tblRepos.reloadData()
                }
                
                self.isSearching(false);
            }
            
        }
    }
    
    func isSearching(isSearching: Bool) {
        self.txtUsername.enabled = !isSearching
        
        self.activityIndicator.hidden = !isSearching
        if (isSearching) { self.activityIndicator.startAnimating() }
    }
    
}

