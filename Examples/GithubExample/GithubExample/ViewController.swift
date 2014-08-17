//
//  ViewController.swift
//  GithubExample
//
//  Created by Josh Holtz on 8/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Need this for models to know which network adapter to use
        // This should probably go in AppDelegate but putting it here cause yeah
        HarmonicConfig.adapter = HarmonicAlamofireAdapter()

        self.fetchRepos("joshdholtz")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: Private
    
    func fetchRepos(username: String) {
        
        // Fetches user
        var user = UserModel(login: username)
        user.get {(request, response, model, error) in
            if (error != nil) { println("User Error - \(error?.localizedDescription)") }
            println("User - \(user.id), \(user.login), \(user.name)")
            
            // Fetches repos
            RepoModel.get(user) {(request, response, models, error) in
                if (error != nil) { println("Repo Error - \(error?.localizedDescription)") }
                var repos = models as? [RepoModel]
                repos?.each { (repo) in
                    println("\tRepo - \(repo.fullName)")
                }
            }
            
        }
    }
    
}

