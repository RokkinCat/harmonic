//
//  UserNonRestModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 10/31/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

class UserNonRestModel: HarmonicModel {
    
    var firstName: String?
    var lastName: String?
    var bestFriend: UserModel?
    var friends: Array<UserModel>?
    var birthday: NSDate?
    
    required init() {

    }
    
    func handleParse(json : JSONObject) {
        // Custom operators
        self.firstName <*> json["first_name"]
        self.lastName <*> json["last_name"]
        self.bestFriend <*> json["best_friend"]
        self.friends <*> json["friends"]
        self.birthday <*> json["birthday"] >>> MyCustomFormatter.ToBirthday

        // Non-custom operators
//        self.firstName = json["first_name"] as? String
//        self.lastName = json["last_name"] as? String
//        self.bestFriend = HarmonicModelMaker<UserModel>().createModel(json["best_friend"] as JSONObject)
//        self.friends = HarmonicModelMaker<UserModel>().createCollection(json["friends"] as JSONArray)
//        self.birthday = MyCustomFormatter.ToBirthday(json["birthday"] as String)
    }
    
}