//
//  StructUserModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 6/14/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

import Foundation

struct StructUserModel: HarmonicModel {
	
	var firstName: String?
	var lastName: String?
	var birthday: NSDate?
	
	init(json: JSONObject) {
		self.firstName <<< json["first_name"]
		self.lastName <<< json["last_name"]
		self.birthday <<< json["birthday"] >>> MyCustomFormatters.toBirthday
	}
	
}