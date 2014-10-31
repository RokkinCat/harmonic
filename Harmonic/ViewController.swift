//
//  ViewController.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.justDoStuff()
    }
    
    func justDoStuff() {
//        self.justModelStuff()
//        self.justNetworkStuff()
//        self.justModelNetworkStuff()
        
        self.justCustomParsing()
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
        var user = HarmonicModelMaker<UserModel>().createModel(json)
        
        println("User - \(user.firstName) \(user.lastName) \(user.birthday)")
        println("\tBest Friend - \(user.bestFriend?.firstName) \(user.bestFriend?.lastName)")
        user.friends?.each( {
            (friend) -> Void in
            println("\tFriend - \(friend.firstName)")
        })
        
        // Collection of model
        var users = HarmonicModelMaker<UserModel>().createCollection(jsons)
        var userInUsers = users[0]
        println("User in Users - \(userInUsers.firstName) \(userInUsers.lastName) \(userInUsers.birthday)")
        println("\tBest Friend - \(userInUsers.bestFriend?.firstName) \(userInUsers.bestFriend?.lastName)")
        user.friends?.each( {
            (friend) -> Void in
            println("\tFriend - \(friend.firstName)")
        })
        
        println("\n\n")
    }
    
    func justNetworkStuff() {

        println("MOCKED USER API")
        
        Alamofire.request(.GET, "https://raw.githubusercontent.com/joshdholtz/harmonic/master/user.json")
            .responseHarmonic {(request, response, model: UserModel?, error) in
                println("From Mock user.json API - \(model?.firstName) \(model?.lastName) \(model?.birthday)")
                
                return // Need to return otherwise get compile error
            }
        
        Alamofire.request(.GET, "https://raw.githubusercontent.com/joshdholtz/harmonic/master/users.json")
            .responseHarmonics {(request, response, models: [UserModel]?, error) in
                
                models?.each({
                    (user) -> () in
                    println("From Mock users.json API - \(user.firstName)")
                })
                
                return // Need to return otherwise get compile error
            }
        
    }
    
    func justModelNetworkStuff() {
        HarmonicConfig.adapter = HarmonicAlamofireAdapter()

        // Gets collection of users
        UserModel.get()
            .responseModels {(request, response, models, error) in
                if let users = models as? [UserModel] {
                    users.each({
                        (user) -> () in
                        println("From Mock users.json API with model - \(user.firstName)")
                    })
                }
            }
        
        // Gets user model
        var user = UserModel()
        user.get(parameters: nil)
            .responseModel {(request, response, model: HarmonicRestModel?, error) in
                println("From Mock user.json API with model - \(user.firstName)  \(user.lastName) \(user.birthday)")
            }
    }
    
    func justCustomParsing() {
        HarmonicConfig.adapter = HarmonicAlamofireAdapter()
        
        // Gets user model
        var user = UserModel()
        user.request(.GET, url: "https://raw.githubusercontent.com/joshdholtz/harmonic/master/data_wrapped_user.json")
            .responseModelWrappedInData {(request, response, model: HarmonicRestModel?, error) in
                println("From Mock user.json API with model - \(user.firstName)  \(user.lastName) \(user.birthday)")
            }
    }

}

struct MyCustomFormatter {
    
    static func ToBirthday(object: AnyObject) -> NSDate? {
        
        var date: NSDate?
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        date = dateStringFormatter.dateFromString(object as String)
        
        return date
    }
    
}

extension HarmonicRestModel.HarmonicRestModelRequest {
    
    func responseModelWrappedInData(callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) {
        self.callback = { (request: NSURLRequest?, response: NSURLResponse?, JSON: AnyObject?, error: NSError?) in
            var model = self.creator()
            if let json = JSON as? JSONObject {
                model.parse(json["data"] as JSONObject)
            }
            callback(request: request, response: response, model: model, error: error)
            
        }
    }
    
}