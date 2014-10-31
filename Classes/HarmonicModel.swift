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

struct HarmonicConfig {
    
    static var adapter: HarmonicNetworkAdapter?
    
}

protocol HarmonicModel {
    init()
    func parse(json : JSONObject)
}

class HarmonicModelMaker<T: HarmonicModel> {
    
    /**
    Createsa a model from a JSON string
    
    :param: json The JSONObject being parsed

    :return: The HarmonicModel filled with glorious data
    */
    func createModel(json : JSONObject) -> T {
        var model = T()
        model.parse(json)
        return model
    }
    
    /**
    Creates a model from a JSONObject
    
    :param: jsonString The string representation of the JSONObject being parsed
    
    :returns: The HarmonicModels filled with glorious data
    */
    func createModel(jsonString : String, inout error : NSError?) -> T? {
        if let jsonData: NSData? = jsonString.dataUsingEncoding(UInt(NSUTF8StringEncoding)) {
            let json = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as JSONObject
            if (error != nil) { return nil }
            
            return createModel(json)
        }

        return nil
    }
    
    /**
    Creates a collection of models from a JSONArray
    
    :param: json The JSONArray being parsed
    
    :returns: The HarmonicModels filled with glorious data
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
    
    :param: jsonString The string representation of the JSONArray being parsed
    
    :returns: The HarmonicModels filled with glorious data
    */
    func createCollection(jsonString : String, inout error : NSError?) -> Array<T>? {
        if let jsonData: NSData? = jsonString.dataUsingEncoding(UInt(NSUTF8StringEncoding)) {
            let json = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as JSONArray
            if (error != nil) { return nil }
            
            return createCollection(json)
        }

        return nil
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

class HarmonicRestModel: HarmonicModel {
    
    required init() {
        
    }
    
    func parse(json: JSONObject) {
        
    }
    
    class func create() -> Self {
        return self()
    }
    
    func me() -> Self {
        return self
    }
    
    class func request(method: HarmonicRestModelRequest.Method, url: String, parameters: [String: AnyObject]? = nil) -> HarmonicRestModelRequest {
        
        let modelRequest = HarmonicRestModelRequest(method: method, url: url, parameters: parameters, creator: create)
        modelRequest.doWork()
        
        return modelRequest
    }
    
    func request(method: HarmonicRestModelRequest.Method, url: String, parameters: [String: AnyObject]? = nil) -> HarmonicRestModelRequest {
        
        let modelRequest = HarmonicRestModelRequest(method: method, url: url, parameters: parameters, creator: me)
        modelRequest.doWork()
        
        return modelRequest
    }
    
}

extension HarmonicRestModel {

    class HarmonicRestModelRequest {
        
        enum Method {
            case GET
            case POST
            case PUT
            case DELETE
        }
        
        var method: Method
        var url: String
        var parameters: [String: AnyObject]? = nil
        var creator: (Void) -> HarmonicRestModel
        
        let queue: NSOperationQueue
        var request: NSURLRequest?
        var response: NSURLResponse?
        var JSON: AnyObject?
        var error: NSError?
        
        init(method: Method, url: String, parameters: [String: AnyObject]? = nil, creator: (Void) -> HarmonicRestModel) {
            self.method = method
            self.url = url
            self.parameters = parameters
            self.creator = creator
            
            self.queue = NSOperationQueue()
            self.queue.suspended = true
            self.queue.maxConcurrentOperationCount = 1
        }
        
        func callback(request: NSURLRequest?, response: NSURLResponse?, JSON: AnyObject?, error: NSError?) {
            self.request = request
            self.response = response
            self.JSON = JSON
            self.error = error
            
            self.queue.suspended = false
        }
        
        func response(callback: (request: NSURLRequest?, response: NSURLResponse?, JSON: AnyObject?, error: NSError?) -> Void) -> Self {
            self.queue.addOperationWithBlock { () -> Void in
                callback(request: self.request, response: self.response, JSON: self.JSON, error: self.error)
            }
            return self
        }
        
        func responseModel(callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) -> Self {
            return response({ (request, response, JSON, error) -> Void in
                var model = self.creator()
                if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
                callback(request: request, response: response, model: model, error: error)
                
                return
            })

        }
        
        func responseModels(callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void) -> Self {
            return response({ (request, response, JSON, error) -> Void in
                var c = {(json: JSONObject) -> HarmonicRestModel in
                    var model = self.creator(); model.parse(json); return model
                };
                var models: [HarmonicRestModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
                callback(request: request, response: response, models: models, error: error)

                return
            })
            
        }

        func doWork() -> Self {

            switch self.method {
            case .GET:
                HarmonicConfig.adapter?.get(url, parameters: parameters, callback: self.callback)
            case .POST:
                HarmonicConfig.adapter?.post(url, parameters: parameters, callback: self.callback)
            case .PUT:
                HarmonicConfig.adapter?.put(url, parameters: parameters, callback: self.callback)
            case .DELETE:
                HarmonicConfig.adapter?.delete(url, parameters: parameters, callback: self.callback)
            default:
                println("Oops")
            }
            
            return self
        }
        
    }
}