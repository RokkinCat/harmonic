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

typealias HarmonicRestModelCallback = (request: NSURLRequest?, response: NSURLResponse?, models: HarmonicRestModel?, error: NSError?) -> Void
typealias HarmonicRestModelsCallback = (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void

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

//class HarmonicModel: NSObject {
//    
//    // MARK: Formatters
//
//        /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A JSONObject? or nil
//    */
//    class func ToJSONObject(object: AnyObject) -> JSONObject? {
//        return object as? JSONObject
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A JSONArray? or nil
//    */
//    class func ToJSONArray(object: AnyObject) -> JSONArray? {
//        return object as? JSONArray
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A JSONObject or nil
//    */
//    func ToJSONObject(object: AnyObject) -> JSONObject? {
//        return HarmonicModel.ToJSONObject(object)
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A JSONArray? or nil
//    */
//    func ToJSONArray(object: AnyObject) -> JSONArray? {
//        return HarmonicModel.ToJSONArray(object)
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A Bool? or nil
//    */
//    func ToFloat(object: AnyObject) -> Bool? {
//        return object as? Bool
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A Float? or nil
//    */
//    func ToFloat(object: AnyObject) -> Float? {
//        return object as? Float
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A Int? or nil
//    */
//    func ToInt(object: AnyObject) -> Int? {
//        return object as? Int
//    }
//    
//    /**
//    Used mainly in the parse() function to format/tranform data
//    
//    :param: anyObject The object to transform
//    
//    :returns: A String? or nil
//    */
//    func ToString(object: AnyObject) -> String? {
//        return object as? String
//    }
//
//
//}

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
    
    class func request(method: HarmonicRestModelRequest.Method, url: String, parameters: [String: AnyObject]? = nil, callback: HarmonicRestModelCallback) -> HarmonicRestModelRequest {
        
        let modelRequest = HarmonicRestModelRequest(method: method, url: url, parameters: parameters, callback: callback, creator: create)
        modelRequest.doWork()
        
        return modelRequest
    }
    
    func request(method: HarmonicRestModelRequest.Method, url: String, parameters: [String: AnyObject]? = nil, callback: HarmonicRestModelCallback) -> HarmonicRestModelRequest {
        
        let modelRequest = HarmonicRestModelRequest(method: method, url: url, parameters: parameters, callback: callback, creator: me)
        modelRequest.doWork()
        
        return modelRequest
    }
    
    class func request(method: HarmonicRestModelRequest.Method, url: String, parameters: [String: AnyObject]? = nil, callback: HarmonicRestModelsCallback) -> HarmonicRestModelRequest {
        
        let modelRequest = HarmonicRestModelRequest(method: method, url: url, parameters: parameters, callback:
            callback, creator: create)
        modelRequest.doWork()
        
        return modelRequest
    }
    
    func request(method: HarmonicRestModelRequest.Method, url: String, parameters: [String: AnyObject]? = nil, callback: HarmonicRestModelsCallback) -> HarmonicRestModelRequest {
        
        let modelRequest = HarmonicRestModelRequest(method: method, url: url, parameters: parameters, callback: callback, creator: me)
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
        var modelCallback: HarmonicRestModelCallback?
        var modelsCallback: HarmonicRestModelsCallback?
        var creator: (Void) -> HarmonicRestModel
        
        init(method: Method, url: String, parameters: [String: AnyObject]? = nil, callback: HarmonicRestModelCallback, creator: (Void) -> HarmonicRestModel) {
            self.method = method
            self.url = url
            self.parameters = parameters
            self.modelCallback = callback
            self.creator = creator
        }
        
        init(method: Method, url: String, parameters: [String: AnyObject]? = nil, callback: HarmonicRestModelsCallback, creator: (Void) -> HarmonicRestModel) {
            self.method = method
            self.url = url
            self.parameters = parameters
            self.modelsCallback = callback
            self.creator = creator
        }

        func doWork() -> Self {

            if (modelCallback != nil) {
                switch self.method {
                case .GET:
                    getModel(url, parameters: parameters, callback: modelCallback!)
                case .POST:
                    postModel(url, parameters: parameters, callback: modelCallback!)
                case .PUT:
                    putModel(url, parameters: parameters, callback: modelCallback!)
                case .DELETE:
                    deleteModel(url, parameters: parameters, callback: modelCallback!)
                default:
                    println("Oops")
                }
            } else if (modelsCallback != nil) {
                switch self.method {
                case .GET:
                    getList(url, parameters: parameters, callback: modelsCallback!)
                case .POST:
                    postList(url, parameters: parameters, callback: modelsCallback!)
                case .PUT:
                    putList(url, parameters: parameters, callback: modelsCallback!)
                case .DELETE:
                    deleteList(url, parameters: parameters, callback: modelsCallback!)
                default:
                    println("Oops")
                }
            }
            
            return self
        }
        
        /**
        Performs a NSURLRequest. The callback passes in an Array of the HarmonicModel subclasses that this was called on.
        
        Ex: var users = models as? [UserModel]
        
        :param: request The NSURLRequest to perform
        :param: callback The Array of the HarmonicModel subclasses that this was called on. The Array will need to be casted down.
        */
        func requestList(request: NSURLRequest, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void) {
            
            var c = {(json: JSONObject) -> HarmonicRestModel in
                var model = self.creator(); model.parse(json); return model
            };
            
            HarmonicConfig.adapter?.request(request) {(request, response, JSON, error) in
                var models: [HarmonicRestModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
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
        func getList(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void) {
            
            var c = {(json: JSONObject) -> HarmonicRestModel in
                var model = self.creator(); model.parse(json); return model
            };
            
            HarmonicConfig.adapter?.get(url, parameters: parameters) {(request, response, JSON, error) in
                var models: [HarmonicRestModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
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
        func postList(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void) {
            
            var c = {(json: JSONObject) -> HarmonicRestModel in
                var model = self.creator(); model.parse(json); return model
            };
            
            HarmonicConfig.adapter?.post(url, parameters: parameters) {(request, response, JSON, error) in
                var models: [HarmonicRestModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
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
        func putList(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void) {
            
            var c = {(json: JSONObject) -> HarmonicRestModel in
                var model = self.creator(); model.parse(json); return model
            };
            
            HarmonicConfig.adapter?.put(url, parameters: parameters) {(request, response, JSON, error) in
                var models: [HarmonicRestModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
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
        func deleteList(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, models: [HarmonicRestModel]?, error: NSError?) -> Void) {
            
            var c = {(json: JSONObject) -> HarmonicRestModel in
                var model = self.creator(); model.parse(json); return model
            };
            
            HarmonicConfig.adapter?.delete(url, parameters: parameters) {(request, response, JSON, error) in
                var models: [HarmonicRestModel]? = (JSON as? JSONArray)!.map {(JSON) in return c(JSON) }
                callback(request: request, response: response, models: models, error: error)
            }
            
        }
        
        /**
        Performs a NSURLRequest. The callback passes in an instance of the HarmonicModel subclass that this was called on. The model instance will need to be casted down in order to use properly.
        
        Ex: var user = model as? UserModel
        
        :param: request The NSURLRequest to perform
        :param: callback instance of the HarmonicModel subclass that this was called on.
        */
        func requestModel(request: NSURLRequest, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) {
            
            var model = creator()
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
        func getModel(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) {
            
            var model = creator()
            println("Model - \(model)")
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
        func postModel(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) {
            
            var model = creator()
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
        func putModel(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) {
            
            var model = creator()
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
        func deleteModel(url: String, parameters: [String: AnyObject]? = nil, callback: (request: NSURLRequest?, response: NSURLResponse?, model: HarmonicRestModel?, error: NSError?) -> Void) {
            
            var model = creator()
            HarmonicConfig.adapter?.delete(url, parameters: parameters) {(request, response, JSON, error) in
                if (JSON is JSONObject) { model.parse(JSON as JSONObject) }
                callback(request: request, response: response, model: model, error: error)
            }
            
        }
        
    }
}