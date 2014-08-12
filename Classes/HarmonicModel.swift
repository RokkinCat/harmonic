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
operator infix >>> { associativity left precedence 150 }

func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

class _HarmonicModelBase: NSObject {
    
    required init() {
        super.init()
    }
    
}

class HarmonicModel: _HarmonicModelBase {
    
    // MARK: Class
    
    /**
        :param: json The JSONObject being parsed
        
        :returns: The HarmonicModel filled with glorious data
    */
    class func create(json : JSONObject) -> Self {
        var model = self()
        model.parse(json);
        return model
    }

    /**
        Needed a garbage init method so the init() - with zero parameters - can be a convience method
        
        :param: this
        :param: isSuch
        :param: aHack
    */
    init(this : Bool, isSuch : Bool, aHack : Bool) {
        
    }
    
    /**
        This is a convience method so that sublcasses aren't required to implement it
        It is needed though for the self() call up above
    */
    convenience init() {
        self.init(this: true, isSuch: true, aHack: true);
    }
    
    /**
        This is the method that gets overwritten for each subclasses HarmonicModel
    */
    func parse(json : JSONObject) {
        fatalError("Must Override")
    }
    
}

class HarmonicModelMaker<T: HarmonicModel>: _HarmonicModelBase {
    
    /**
        :param: json The JSONObject being parsed
    
        :return: The HarmonicModel filled with glorious data
    */
    class func createModel(json : JSONObject) -> T {
        return T.create(json)
    }
    
    /**
        :param: json The JSONArray being parsed
        
        :returns: The HarmonicModels  filled with glorious data
    */
    class func createCollection(json : JSONArray) -> Array<T> {
        var models : Array<T> = []
        for (obj) in json {
            models += T.create(obj)
        }
        return models
    }
    
    /**
        Needed a garbage init method so the init() - with zero parameters - can be a convience method
    
        :param: this
        :param: isSuch
        :param: aHack
    */
    init(this : Bool, isSuch : Bool, aHack : Bool) {
        
    }
    
    /**
        This is a convience method so that sublcasses aren't required to implement it
        It is needed though for the self() call up above
    */
    convenience init() {
        self.init(this: true, isSuch: true, aHack: true)
    }
    
}

extension HarmonicModel {
    
    func ToJSONObject(object: AnyObject) -> JSONObject? {
        return object as? JSONObject
    }
    
    func ToJSONArray(object: AnyObject) -> JSONArray? {
        return object as? JSONArray
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

extension Array {
    
    func each (iterator: (T) -> Void ) -> Array {
        for item in self {
            iterator(item)
        }
        return self
    }
    
}