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
        
        self.justModelStuff()
        self.justNetworkStuff()
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
        var user = UserModel.create(json) // OR HarmonicModelMaker<UserModel>.createModel(json)
        println("User - \(user.firstName) \(user.lastName) \(user.birthday)")
        println("\tBest Friend - \(user.bestFriend?.firstName) \(user.bestFriend?.lastName)")
        user.friends?.each( {
            (friend) -> Void in
            println("\tFriend - \(friend.firstName)")
        })
        
        // Collection of model
        var users = HarmonicModelMaker<UserModel>.createCollection(jsons)
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
        
        Alamofire.request(.GET, "https://raw.githubusercontent.com/joshdholtz/harmonic/master/user.json", parameters: nil, encoding: .JSON(options: nil))
            .responseJSON {(request, response, JSON, error) in
                println("MOCKED USER API")
                
                var user = UserModel.create(JSON as JSONObject)
                println("From Mock user' API - \(user.firstName)")
                
            }
        
        Alamofire.request(.GET, "https://raw.githubusercontent.com/joshdholtz/harmonic/master/users.json", parameters: nil, encoding: .JSON(options: nil))
            .responseJSON {(request, response, JSON, error) in
                println("MOCKED USERS API")
                
                var users = HarmonicModelMaker<UserModel>.createCollection(JSON as JSONArray)
                users.each({
                    (user) -> () in
                    println("From Mock users API - \(user.firstName)")
                })
                
            }
        
    }
    

}

class MockProtocol : NSURLProtocol {
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        println("DUDE")
        println("Can init - \(request.URL.absoluteString)")
        return true
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest!) -> NSURLRequest! {
        println("SUP")
        return request
    }
    
    override func startLoading() {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                //                    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                //                    [client URLProtocol:self didLoadData:response.data];
                //                    [client URLProtocolDidFinishLoading:self];
                
            })
            
        })
        
    }
    
    override func stopLoading() {
        
    }
    
}

extension HarmonicModel {
    
    func ToBirthday(object: AnyObject) -> NSDate? {
        
        var date: NSDate?
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        date = dateStringFormatter.dateFromString(object as String)
        
        return date
    }
    
}