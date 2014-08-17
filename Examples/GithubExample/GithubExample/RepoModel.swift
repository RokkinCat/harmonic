//
//  RepoModel.swift
//  GithubExample
//
//  Created by Josh Holtz on 8/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

class RepoModel: HarmonicModel {

    var id: Int?
    var name: String?
    var fullName: String?
    
    override func parse(json : JSONObject) {
        super.parse(json)
        self.id = json["id"] >>> ToInt
        self.name = json["name"] >>> ToString
        self.fullName = json["full_name"] >>> ToString
    }
    
    class func get(user: UserModel, searchParameters parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        // Validates that we have login
        if let error = user.validate() { callback(request: nil, response: nil, models: nil, error: error); return }
        
        var url = "https://api.github.com/users/\(user.login!)/repos"
        get(url, parameters: parameters, callback: callback)
    }
    
}
