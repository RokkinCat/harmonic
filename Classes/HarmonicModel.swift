//
//  HarmonicModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

// Cause typing things is hard
typealias JSONObject = Dictionary<String, AnyObject>
typealias JSONArray = Array<JSONObject>

typealias HarmonicRestModelCallback = (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void
//typealias HarmonicRestModelCallback = (request: NSURLRequest?, response: NSURLResponse?, models: HarmonicRestModel?, error: NSError?) -> Void
//typealias HarmonicRestModelsCallback = (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void

// Used for monad for awesomely easy parsing
infix operator >>> { associativity left precedence 170 }

func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

infix operator <*> { associativity left precedence 160 }

func <*><A: HarmonicModel, B>(inout a: Array<A>?, b: B?) {
    if let c = b as? JSONArray {
		a = A.parse(c)
    }
}

func <*><A: HarmonicModel, B>(inout a: A?, b: B?) {
    if let c = b as? JSONObject {
		a = A.parse(c)
    }
}

func <*><A, B>(inout a: A?, b: B?) {
    a = b as? A
}

protocol HarmonicModel {
    init()
    func handleParse(json : JSONObject)
}

enum HarmonicError: ErrorType {
	case CannotParseJSON
}

extension HarmonicModel {
	
	static func parse(json: JSONObject) -> Self {
		let model = Self()
		model.handleParse(json)
		return model
	}
	
	static func parse(json: JSONArray) -> [Self] {
		var models : Array<Self> = []
		for obj in json {
			models.append( parse(obj) )
		}
		return models
	}
	
	static func parse(jsonString : String) throws -> Self {
		do {
			if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
				json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? JSONObject {
					return Self.parse(json)
			}
		} catch {}

		throw HarmonicError.CannotParseJSON
	}
	
	static func parse(jsonString : String) throws -> [Self] {
		do {
			if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
				json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? JSONArray {
					return Self.parse(json)
			}
		} catch {}
		
		throw HarmonicError.CannotParseJSON
	}
}