//
//  HarmonicModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

// Cause typing things is hard
public typealias JSONObject = Dictionary<String, AnyObject>
public typealias JSONArray = Array<JSONObject>

infix operator >>> { associativity left precedence 170 }
public func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

infix operator <*> { associativity left precedence 160 }
public func <*><A: HarmonicModel, B>(inout a: Array<A>?, b: B?) {
    if let c = b as? JSONArray {
		a = A.parse(c)
    }
}

public func <*><A: HarmonicModel, B>(inout a: A?, b: B?) {
    if let c = b as? JSONObject {
		a = A.parse(c)
    }
}

public func <*><A, B>(inout a: A?, b: B?) {
    a = b as? A
}

public protocol HarmonicModel {
	 init(json: JSONObject)
}

public enum HarmonicError: ErrorType {
	case CannotParseJSON
}

extension HarmonicModel {
	
	static func parse(json: JSONObject) -> Self {
		let model = Self(json: json)
		return model
	}
	
	static func parse(json: JSONArray) -> [Self] {
		var models : Array<Self> = []
		for obj in json {
			let model = Self(json: obj)
			models.append(model)
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