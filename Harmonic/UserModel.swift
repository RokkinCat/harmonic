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
    
    override func parse(json : JSONObject) {
        self.firstName = json["first_name"] >>> ToString
        self.lastName = json["last_name"] >>> ToString
        self.bestFriend = json["best_friend"] >>> ToJSONObject >>> HarmonicModelMaker<UserModel>.createModel
        self.friends = json["friends"] >>> ToJSONArray >>> HarmonicModelMaker<UserModel>.createCollection
        self.birthday = json["birthday"] >>> ToBirthday
    }
    
}