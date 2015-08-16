//
//  CoreUserModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 7/11/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

import Foundation
import CoreData

class CoreUserModel: CoreHarmonicModel {

	static var entityName = "User"

	var firstName: String?
	var lastName: String?
	var birthday: NSDate?

	required init(json: JSONObject) {
		self.firstName <*> json["first_name"]
		self.lastName <*> json["last_name"]
		self.birthday <*> json["birthday"] >>> MyCustomFormatters.toBirthday
	}
	
}