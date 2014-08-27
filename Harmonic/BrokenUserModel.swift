//
//  BrokenUserModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

class BrokenUserModel: HarmonicModel {
    
    var firstName : String?;
    var lastName : String?;
    var bestFriend : UserModel?;
    var friends : Array<UserModel>?;
    var birthday : NSDate?;
    
    override func parse(json : JSONObject) {
        self.firstName = json["first_name"] >>> ToString
        self.lastName = json["elLastNameo"] >>> ToString
        self.bestFriend = json["best_frienddddd"] >>> ToJSONObject >>> HarmonicModelMaker<UserModel>.createModel
        self.friends = json["friendssss"] >>> ToJSONArray >>> HarmonicModelMaker<UserModel>.createCollection
        self.birthday = json["birfday"] >>> MyCustomFormatter.ToBirthday
    }
    
}