//
//  UserModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

class UserModel: HarmonicRestModel, HarmonicModel {
    
    var firstName: String?
    var lastName: String?
    var bestFriend: UserModel?
    var friends: Array<UserModel>?
    var birthday: NSDate?

    required init() {
        super.init()
    }
    
    override  func parse(json : JSONObject) {
        // FIXME: Do stuff
        self.firstName <*> json["first_name"]
        self.lastName <*> json["last_name"]
        self.bestFriend <*> json["best_friend"]
        self.friends <*> json["friends"]
        self.birthday <*> json["birthday"] >>> MyCustomFormatter.ToBirthday
    }
    
    class func get(parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        // Here is where you can do generate the URL and paremeters and things
        var url = "http://statuscodewhat.herokuapp.com/200?body=%5B%7B%22birthday%22%3A%221989-03-01%22%2C%22first_name%22%3A%22Josh%22%2C%22friends%22%3A%5B%7B%22first_name%22%3A%22Red%2520Ranger%22%7D%2C%7B%22first_name%22%3A%22Green%2520Ranger%22%7D%5D%2C%22last_name%22%3A%22Holtz%22%2C%22best_friend%22%3A%7B%22first_name%22%3A%22Bandit%22%2C%22last_name%22%3A%22The%2520Cat%22%7D%7D%5D"
        
        get(url, parameters: parameters, callback: callback)
    }
    
    func get(parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: HarmonicModel?, error: NSError?) -> Void) {
        
        // Here is where you can do generate the URL and paremeters and things
        var url = "http://statuscodewhat.herokuapp.com/200?body=%7B%22birthday%22%3A%221989-03-01%22%2C%22first_name%22%3A%22Josh%22%2C%22friends%22%3A%5B%7B%22first_name%22%3A%22Red%2520Ranger%22%7D%2C%7B%22first_name%22%3A%22Green%2520Ranger%22%7D%5D%2C%22last_name%22%3A%22Holtz%22%2C%22best_friend%22%3A%7B%22first_name%22%3A%22Bandit%22%2C%22last_name%22%3A%22The%2520Cat%22%7D%7D"
        
        get(url, parameters: parameters, callback: callback)
    }
    
}