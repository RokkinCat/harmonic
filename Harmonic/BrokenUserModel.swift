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
	
	required init(json: JSONObject) {
		self.firstName <*> json["first_name"]
		self.lastName <*> json["elLastNameo"]
		self.bestFriend <*> json["best_frienddddd"]
		self.friends <*> json["friendssss"]
		self.birthday <*> json["birfday"] >>> MyCustomFormatters.toBirthday
	}
	
}