//
//  HarmonicAlamofire.swift
//  Harmonic
//
//  Created by Josh Holtz on 8/12/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation

extension Alamofire.Request {
    class func HarmonicResponseSerializer(options: NSJSONReadingOptions = .AllowFragments) -> (NSURLRequest, NSHTTPURLResponse?, NSData?, NSError?) -> (AnyObject?, NSError?) {
        return { (request, response, data, error) in
            var serializationError: NSError?
            let JSON: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: options, error: &serializationError)
            
            
            return (JSON, serializationError)
        }
    }
    
    func responseHarmonic<T: HarmonicModel>(modelMaker: HarmonicModelMaker<T>.Type, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        
        return responseJSON({ (request, response, JSON, error) in
            var json : JSONObject = JSON as JSONObject
            var model = modelMaker.createModel(json)
            completionHandler(request, response, model, error)
        })
    }
    
    func responseHarmonics<T: HarmonicModel>(modelMaker: HarmonicModelMaker<T>.Type, completionHandler: (NSURLRequest, NSHTTPURLResponse?, Array<T>?, NSError?) -> Void) -> Self {
        
        return responseJSON({ (request, response, JSON, error) in
            let json = JSON as JSONArray
            var models = modelMaker.createCollection(json)
            completionHandler(request, response, models, error)
        })
    }
    
}
