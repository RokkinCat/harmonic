//
//  ViewController.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.justDoStuff()
    }
    
    func justDoStuff() {
//        self.justModelStuff()
//        self.justNetworkStuff()
//        self.justModelNetworkStuff()
        
//        self.justCustomParsing()
    }
    
    func justModelStuff() {
        println("MOCKED RESPONSE")
        
        var json : Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz",
            "best_friend" : ["first_name" : "Bandit", "last_name" : "The Cat"],
            "friends" : [ ["first_name" : "Red Ranger"], ["first_name" : "Green Ranger"] ],
            "birthday" : "1989-03-01"
        ]
        var jsons = [json]
        
        // Single model
        var user = HarmonicModelMaker<UserNonRestModel>().createModel(json)
        
        println("User - \(user.firstName) \(user.lastName) \(user.birthday)")
        println("\tBest Friend - \(user.bestFriend?.firstName) \(user.bestFriend?.lastName)")
		if let friends = user.friends {
			for friend in friends {
				println("\tFriend - \(friend.firstName)")
			}
        }
        
        // Collection of model
        var users = HarmonicModelMaker<UserNonRestModel>().createCollection(jsons)
        var userInUsers = users[0]
        println("User in Users - \(userInUsers.firstName) \(userInUsers.lastName) \(userInUsers.birthday)")
        println("\tBest Friend - \(userInUsers.bestFriend?.firstName) \(userInUsers.bestFriend?.lastName)")
		if let friends = user.friends {
			for friend in friends {
				println("\tFriend - \(friend.firstName)")
			}
        }
        
        println("\n\n")
    }
	
}

struct MyCustomFormatter {
    
    static func ToBirthday(object: AnyObject) -> NSDate? {
        
        var date: NSDate?
		
		if let string = object as? String {
			let dateStringFormatter = NSDateFormatter()
			dateStringFormatter.dateFormat = "yyyy-MM-dd"
			dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
			date = dateStringFormatter.dateFromString(string)
		}
		
        return date
    }
    
}