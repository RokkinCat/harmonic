//
//  HarmonicAlamofire.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/12/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation
import Alamofire

extension Alamofire.Request {
    
    class func HarmonicResponseSerializer(options: NSJSONReadingOptions = .AllowFragments) -> (NSURLRequest, NSHTTPURLResponse?, NSData?, NSError?) -> (AnyObject?, NSError?) {
        return { (request, response, data, error) in
            var serializationError: NSError?
            let JSON: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: options, error: &serializationError)
            return (JSON, serializationError)
        }
    }
    
    func responseHarmonic<T: HarmonicModel>(modelMaker: HarmonicModelMaker<T>.Type, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        
        return responseJSON({ (request, response, JSON, error) in
            let model = JSON >>> HarmonicModel.ToJSONObject >>> modelMaker.createModel
            completionHandler(request, response, model, error)
        })
    }
    
    func responseHarmonics<T: HarmonicModel>(modelMaker: HarmonicModelMaker<T>.Type, completionHandler: (NSURLRequest, NSHTTPURLResponse?, Array<T>?, NSError?) -> Void) -> Self {
        
        return responseJSON({ (request, response, JSON, error) in
            let models  = JSON >>> HarmonicModel.ToJSONArray >>> modelMaker.createCollection
            completionHandler(request, response, models, error)
        })
        
    }
    
}

class HarmonicAlamofireAdapter: HarmonicNetworkAdapter {
    
    var manager: Alamofire.Manager
    var encoding: Alamofire.ParameterEncoding
    
    convenience init() {
        self.init(manager: Alamofire.Manager.sharedInstance)
    }
    
    init(manager: Alamofire.Manager, encoding: Alamofire.ParameterEncoding = Alamofire.ParameterEncoding.URL) {
        self.manager = manager
        self.encoding = encoding
    }
    
    func URLRequest(method: Alamofire.Method, _ URL: String) -> NSURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URL))
        mutableURLRequest.HTTPMethod = method.toRaw()
        
        return mutableURLRequest
    }
    
    func startRequest(method: Alamofire.Method, url: String, parameters: [String: AnyObject]?) -> Alamofire.Request {
        return manager.request(encoding.encode(URLRequest(method, url), parameters: parameters).0)
    }
    
    func request(request: NSURLRequest, callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void) {
        
        let alamoRequest = self.manager.request(request)
        alamoRequest.responseJSON {(request, response, JSON, error) in
            callback(request: request, response: response, json: JSON, error: error)
        }
    }
    
    func get(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void) {
        
        self.startRequest(.GET, url: url, parameters: parameters)
            .responseJSON {(request, response, JSON, error) in
                callback(request: request, response: response, json: JSON, error: error)
            }
    }
    
    func post(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void) {
        
        self.startRequest(.POST, url: url, parameters: parameters)
            .responseJSON {(request, response, JSON, error) in
                callback(request: request, response: response, json: JSON, error: error)
        }
    }
    
    func put(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void) {
        
        self.startRequest(.PUT, url: url, parameters: parameters)
            .responseJSON {(request, response, JSON, error) in
                callback(request: request, response: response, json: JSON, error: error)
        }
    }
    
    func delete(url: String, parameters: [String: AnyObject]? , callback: (request: NSURLRequest?, response: NSURLResponse?, json: AnyObject?, error: NSError?) -> Void) {
        
        self.startRequest(.DELETE, url: url, parameters: parameters)
            .responseJSON {(request, response, JSON, error) in
                callback(request: request, response: response, json: JSON, error: error)
        }
    }
    
}