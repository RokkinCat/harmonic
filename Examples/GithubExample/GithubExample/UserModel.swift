//
//  UserModel.swift
//  GithubExample
//
//  Created by Josh Holtz on 8/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

class UserModel: HarmonicModel {

    var id: Int?
    var login: String?
    var name: String?
    var company: String?
    var blog: String?
    var location: String?
    
    convenience init(login: String) {
        self.init()
        self.login = login
    }
    
    override func parse(json : JSONObject) {
        super.parse(json)
        self.id = json["id"] >>> ToInt
        self.login = json["login"] >>> ToString
        self.name = json["name"] >>> ToString
        self.company = json["company"] >>> ToString
        self.blog = json["blog"] >>> ToString
        self.location = json["location"] >>> ToString
    }
    
    func validate() -> NSError? {
        if (login == nil) {
            return NSError(domain: "UserModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username/login is required"])
        }
        
        return nil
    }
    
    func get(parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: HarmonicModel?, error: NSError?) -> Void) {
        
        // Validates that we have login
        if let error = self.validate() {
            callback(request: nil, response: nil, models: nil, error: error)
            return
        }
        
        // Gets user json object
        var url = "https://api.github.com/users/\(login!)"
        get(url, parameters: parameters, callback: callback)
    }
    
}
