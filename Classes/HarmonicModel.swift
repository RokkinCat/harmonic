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
        a = HarmonicModelMaker<A>().createCollection(c)
    }
}

func <*><A: HarmonicModel, B>(inout a: A?, b: B?) {
    if let c = b as? JSONObject {
        a = HarmonicModelMaker<A>().createModel(c)
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

class HarmonicModelMaker<T: HarmonicModel> {
    
    /**
    Createsa a model from a JSON string
    
    - parameter json: The JSONObject being parsed

    :return: The HarmonicModel filled with glorious data
    */
    func createModel(json : JSONObject) -> T {
        let model = T()
        model.handleParse(json)
        return model
    }
    
    /**
    Creates a model from a JSONObject
    
    - parameter jsonString: The string representation of the JSONObject being parsed
    
    - returns: The HarmonicModels filled with glorious data
    */
    func createModel(jsonString : String) throws -> T {
		do {
			if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
				json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? JSONObject {
					return createModel(json)
			}
		} catch {}
		
		throw HarmonicError.CannotParseJSON
    }
    
    /**
    Creates a collection of models from a JSONArray
    
    - parameter json: The JSONArray being parsed
    
    - returns: The HarmonicModels filled with glorious data
    */
    func createCollection(json : JSONArray) -> Array<T> {
        var models : Array<T> = []
        for (obj) in json {
            models.append( createModel(obj) )
        }
        return models
    }
    
    /**
    Createsa a collection of models from a JSON string
    
    - parameter jsonString: The string representation of the JSONArray being parsed
    
    - returns: The HarmonicModels filled with glorious data
    */
    func createCollection(jsonString : String) throws -> Array<T> {
		do {
			if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
				json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? JSONArray {
					return createCollection(json)
			}
		} catch {}
		
		throw HarmonicError.CannotParseJSON
    }
    
}