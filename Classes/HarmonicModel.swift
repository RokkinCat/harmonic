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

// Used for monad for awesomely easy parsing
infix operator >>> { associativity left precedence 150 }

func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

struct HarmonicConfig {
    static var adapter: HarmonicNetworkAdapter?
    
}

class HarmonicModel: NSObject {
    
    /**
        :param: json The JSONObject being parsed
        
        :returns: The HarmonicModel filled with glorious data
    */
    class func create(json : JSONObject) -> Self {
        var model = self()
        model.parse(json);
        return model
    }
    
    class func make(json : JSONObject) -> HarmonicModel {
        var model = self()
        model.parse(json);
        return model
    }

    required override init() {
        super.init()
    }
    
    /**
        This is the method that gets overwritten for each subclasses HarmonicModel
    */
    func parse(json : JSONObject) {
        fatalError("Must Override")
    }
    
    class func get(url: String, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        var c = self;
        var tja = ToJSONArray
        
        HarmonicConfig.adapter?.getCollection(url) {(request, response, JSON, error) in
            
            var ja: JSONArray? = JSON as? JSONArray
            
            var models: [HarmonicModel] = []
            for obj in ja! {
                let model = c()
                model.parse(obj)
                models.append(model)
            }
            
            callback(request: request, response: response, models: models, error: error)
            
            return
        }
        
    }
    
    func get(url: String, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicModel?, error: NSError?) -> Void) {
        
        var model = self
        
        HarmonicConfig.adapter?.getCollection(url) {(request, response, JSON, error) in
            
            var jo: JSONObject? = JSON as? JSONObject
            model.parse(jo!)
            
            callback(request: request, response: response, model: model, error: error)
            
            return
        }
    }
    
}

class HarmonicModelMaker<T: HarmonicModel>: NSObject {
    
    /**
        :param: json The JSONObject being parsed
    
        :return: The HarmonicModel filled with glorious data
    */
    class func createModel(json : JSONObject) -> T {
        return T.create(json)
    }
    
    /**
        :param: jsonString The string representation of the JSONObject being parsed
        
        :returns: The HarmonicModels filled with glorious data
    */
    class func createModel(jsonString : String, inout error : NSError?) -> T? {
        let jsonData = jsonString.dataUsingEncoding(UInt(NSUTF8StringEncoding), allowLossyConversion: false)
        let json = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as JSONObject
        
        if (error != nil) { return nil }
        
        return createModel(json);
    }
    
    /**
        :param: json The JSONArray being parsed
        
        :returns: The HarmonicModels filled with glorious data
    */
    class func createCollection(json : JSONArray) -> Array<T> {
        var models : Array<T> = []
        for (obj) in json {
            models.append( T.create(obj) )
        }
        return models
    }
    
    /**
        :param: jsonString The string representation of the JSONArray being parsed
        
        :returns: The HarmonicModels filled with glorious data
    */
    class func createCollection(jsonString : String, inout error : NSError?) -> Array<T>? {
        
        let jsonData = jsonString.dataUsingEncoding(UInt(NSUTF8StringEncoding), allowLossyConversion: false)
        let json = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as JSONArray
        
        if (error != nil) { return nil }
        
        return createCollection(json)
    }
    
    required override init() {
        super.init()
    }
    
}

// MARK: Formatter extenstions

extension HarmonicModel {
    
    class func ToJSONObject(object: AnyObject) -> JSONObject? {
        return object as? JSONObject
    }
    
    class func ToJSONArray(object: AnyObject) -> JSONArray? {
        return object as? JSONArray
    }
    
    func ToJSONObject(object: AnyObject) -> JSONObject? {
        return HarmonicModel.ToJSONObject(object)
    }
    
    func ToJSONArray(object: AnyObject) -> JSONArray? {
        return HarmonicModel.ToJSONArray(object)
    }
    
    func ToFloat(object: AnyObject) -> Bool? {
        return object as? Bool
    }
    
    func ToFloat(object: AnyObject) -> Float? {
        return object as? Float
    }
    
    func ToInt(object: AnyObject) -> Int? {
        return object as? Int
    }
    
    func ToString(object: AnyObject) -> String? {
        return object as? String
    }
    
}

// MARK: Array extentions

extension Array {
    
    func each (iterator: (T) -> Void ) -> Array {
        for item in self {
            iterator(item)
        }
        return self
    }
    
}

protocol HarmonicNetworkAdapter {
    
    func getCollection(url: String, callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void);
    
}