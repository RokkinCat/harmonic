//
//  Formatters.swift
//  Harmonic
//
//  Created by Josh Holtz on 6/14/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

import Foundation

struct MyCustomFormatters {
	
	static func toBirthday(object: AnyObject) -> NSDate? {
		
		var date: NSDate?
		
		let dateStringFormatter = NSDateFormatter()
		dateStringFormatter.dateFormat = "yyyy-MM-dd"
		dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		date = dateStringFormatter.dateFromString(object as! String)
		
		return date
	}
	
}