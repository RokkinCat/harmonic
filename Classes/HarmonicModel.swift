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
    
    // Holds the JSON used to parse incase lazy variables are used
    var _json = JSONObject()
    
    /**
    Creates a model with a JSONObject
    
    :param: json The JSONObject being parsed
    
    :returns: The HarmonicModel filled with glorious data
    */
    class func create(json : JSONObject) -> Self {
        var model = self()
        model.parse(json);
        return model
    }

    required override init() {
        super.init()
    }
    
    /**
    This is the method that gets overwritten for each subclasses HarmonicModel

    :param: json The JSONObject being parsed
    */
    func parse(json : JSONObject) {
        _json = json
    }
    
}

class HarmonicModelMaker<T: HarmonicModel>: NSObject {
    
    /**
    Createsa a model from a JSON string
    
    :param: json The JSONObject being parsed

    :return: The HarmonicModel filled with glorious data
    */
    class func createModel(json : JSONObject) -> T {
        return T.create(json)
    }
    
    /**
    Creates a model from a JSONObject
    
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
    Creates a collection of models from a JSONArray
    
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
    Createsa a collection of models from a JSON string
    
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
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A JSONObject? or nil
    */
    class func ToJSONObject(object: AnyObject) -> JSONObject? {
        return object as? JSONObject
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A JSONArray? or nil
    */
    class func ToJSONArray(object: AnyObject) -> JSONArray? {
        return object as? JSONArray
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A JSONObject or nil
    */
    func ToJSONObject(object: AnyObject) -> JSONObject? {
        return HarmonicModel.ToJSONObject(object)
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A JSONArray? or nil
    */
    func ToJSONArray(object: AnyObject) -> JSONArray? {
        return HarmonicModel.ToJSONArray(object)
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A Bool? or nil
    */
    func ToFloat(object: AnyObject) -> Bool? {
        return object as? Bool
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A Float? or nil
    */
    func ToFloat(object: AnyObject) -> Float? {
        return object as? Float
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A Int? or nil
    */
    func ToInt(object: AnyObject) -> Int? {
        return object as? Int
    }
    
    /**
    Used mainly in the parse() function to format/tranform data
    
    :param: anyObject The object to transform
    
    :returns: A String? or nil
    */
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
    
    func request(request: NSURLRequest, callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void)
    
    func get(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void)
    
    func post(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void)
    
    func put(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void)
    
    func delete(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void)
    
}

extension HarmonicModel {
    
    /**
    Performs a NSURLRequest. The callback passes in an Array of the HarmonicModel subclasses that this was called on.
    
    Ex: var users = models as? [UserModel]
    
    :param: request The NSURLRequest to perform
    :param: callback The Array of the HarmonicModel subclasses that this was called on. The Array will need to be casted down.
    */
    class func request(request: NSURLRequest, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        var c = {(json: JSONObject) -> HarmonicModel in
            var model = self(); model.parse(json); return model
        };
        
        HarmonicConfig.adapter?.request(request) {(request, response, JSON, error) in
            var models: [HarmonicModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
            callback(request: request, response: response, models: models, error: error)
        }
        
    }
    
    /**
    Performs a GET request. The callback passes in an Array of the HarmonicModel subclasses that this was called on.
    
    Ex: var users = models as? [UserModel]
    
    :param: url The URL to perform a GET request on
    :param: parameters The parameters to send on the request
    :param: callback The Array of the HarmonicModel subclasses that this was called on. The Array will need to be casted down.
    */
    class func get(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        var c = {(json: JSONObject) -> HarmonicModel in
            var model = self(); model.parse(json); return model
        };
        
        HarmonicConfig.adapter?.get(url, parameters: parameters) {(request, response, JSON, error) in
            var models: [HarmonicModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
            callback(request: request, response: response, models: models, error: error)
        }
        
    }
    
    /**
    Performs a POST request. The callback passes in an Array of the HarmonicModel subclasses that this was called on.
    
    Ex: var users = models as? [UserModel]
    
    :param: url The URL to perform a POST request on
    :param: parameters The parameters to send on the request
    :param: callback The Array of the HarmonicModel subclasses that this was called on. The Array will need to be casted down.
    */
    class func post(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        var c = {(json: JSONObject) -> HarmonicModel in
            var model = self(); model.parse(json); return model
        };
        
        HarmonicConfig.adapter?.post(url, parameters: parameters) {(request, response, JSON, error) in
            var models: [HarmonicModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
            callback(request: request, response: response, models: models, error: error)
        }
        
    }
    
    /**
    Performs a PUT request. The callback passes in an Array of the HarmonicModel subclasses that this was called on.
    
    Ex: var users = models as? [UserModel]
    
    :param: url The URL to perform a PUT request on
    :param: parameters The parameters to send on the request
    :param: callback The Array of the HarmonicModel subclasses that this was called on. The Array will need to be casted down.
    */
    class func put(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        var c = {(json: JSONObject) -> HarmonicModel in
            var model = self(); model.parse(json); return model
        };
        
        HarmonicConfig.adapter?.put(url, parameters: parameters) {(request, response, JSON, error) in
            var models: [HarmonicModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
            callback(request: request, response: response, models: models, error: error)
        }
        
    }
    
    /**
    Performs a DELETE request. The callback passes in an Array of the HarmonicModel subclasses that this was called on.
    
    Ex: var users = models as? [UserModel]
    
    :param: url The URL to perform a DELETE request on
    :param: parameters The parameters to send on the request
    :param: callback The Array of the HarmonicModel subclasses that this was called on. The Array will need to be casted down.
    */
    class func delete(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicModel]?, error: NSError?) -> Void) {
        
        var c = {(json: JSONObject) -> HarmonicModel in
            var model = self(); model.parse(json); return model
        };
        
        HarmonicConfig.adapter?.delete(url, parameters: parameters) {(request, response, JSON, error) in
            var models: [HarmonicModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
            callback(request: request, response: response, models: models, error: error)
        }
        
    }
    
}

extension HarmonicModel {
    
    /**
    Performs a NSURLRequest. The callback passes in an instance of the HarmonicModel subclass that this was called on. The model instance will need to be casted down in order to use properly.
    
    Ex: var user = model as? UserModel
    
    :param: request The NSURLRequest to perform
    :param: callback instance of the HarmonicModel subclass that this was called on.
    */
    func request(request: NSURLRequest, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicModel?, error: NSError?) -> Void) {
        
        var model = self
        HarmonicConfig.adapter?.request(request) {(request, response, JSON, error) in
            if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
            callback(request: request, response: response, model: model, error: error)
        }
        
    }
    
    /**
    Performs a GET request. The callback passes in an instance of the HarmonicModel subclass that this was called on. The model instance will need to be casted down in order to use properly.
    
    Ex: var user = model as? UserModel
    
    :param: url The URL to perform a GET request on
    :param: parameters The parameters to send on the request
    :param: callback instance of the HarmonicModel subclass that this was called on.
    */
    func get(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicModel?, error: NSError?) -> Void) {
        
        var model = self
        HarmonicConfig.adapter?.get(url, parameters: parameters) {(request, response, JSON, error) in
            if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
            callback(request: request, response: response, model: model, error: error)
        }
        
    }
    
    /**
    Performs a POST request. The callback passes in an instance of the HarmonicModel subclass that this was called on. The model instance will need to be casted down in order to use properly.
    
    Ex: var user = model as? UserModel
    
    :param: url The URL to perform a POST request on
    :param: parameters The parameters to send on the request
    :param: callback instance of the HarmonicModel subclass that this was called on.
    */
    func post(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicModel?, error: NSError?) -> Void) {
        
        var model = self
        HarmonicConfig.adapter?.post(url, parameters: parameters) {(request, response, JSON, error) in
            if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
            callback(request: request, response: response, model: model, error: error)
        }
        
    }
    
    /**
    Performs a PUT request. The callback passes in an instance of the HarmonicModel subclass that this was called on. The model instance will need to be casted down in order to use properly.
    
    Ex: var user = model as? UserModel
    
    :param: url The URL to perform a PUT request on
    :param: parameters The parameters to send on the request
    :param: callback instance of the HarmonicModel subclass that this was called on.
    */
    func put(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicModel?, error: NSError?) -> Void) {
        
        var model = self
        HarmonicConfig.adapter?.put(url, parameters: parameters) {(request, response, JSON, error) in
            if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
            callback(request: request, response: response, model: model, error: error)
        }
        
    }
    
    /**
    Performs a DELETE request. The callback passes in an instance of the HarmonicModel subclass that this was called on. The model instance will need to be casted down in order to use properly.
    
    Ex: var user = model as? UserModel
    
    :param: url The URL to perform a DELETE request on
    :param: parameters The parameters to send on the request
    :param: callback instance of the HarmonicModel subclass that this was called on.
    */
    func delete(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicModel?, error: NSError?) -> Void) {
        
        var model = self
        HarmonicConfig.adapter?.delete(url, parameters: parameters) {(request, response, JSON, error) in
            if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
            callback(request: request, response: response, model: model, error: error)
        }
        
    }
    
}