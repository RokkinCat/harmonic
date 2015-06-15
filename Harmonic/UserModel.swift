//
//  UserModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

class UserModel: HarmonicModel {
    
    var firstName: String?
    var lastName: String?
    var bestFriend: UserModel?
    var friends: Array<UserModel>?
    var birthday: NSDate?

    required init() {
		
    }
    
    func handleParse(json : JSONObject) {
        self.firstName <*> json["first_name"]
        self.lastName <*> json["last_name"]
        self.bestFriend <*> json["best_friend"]
        self.friends <*> json["friends"]
        self.birthday <*> json["birthday"] >>> MyCustomFormatter.ToBirthday
    }
    
}