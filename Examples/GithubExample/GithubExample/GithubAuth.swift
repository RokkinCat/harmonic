//
//  GithubAuth.swift
//  GithubExample
//
//  Created by Josh Holtz on 8/17/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import Foundation
import UIKit

private let _GithubAuthedSession = GithubAuth()

class GithubAuth: HarmonicModel {

    struct Config {
        static var redirectURI: String?
        static var clientId: String?
        static var clientSecret: String?
        static var state = "1233456"
    }
    
    class var session: GithubAuth {
        return _GithubAuthedSession
    }
    
    typealias authCallbackClosure = (NSError?) -> ()
    var authCallback: authCallbackClosure?
    
    var accessToken: String?
    var scope: String?
    var tokenType: String?
    
    override func parse(json : JSONObject) {
        super.parse(json)
        self.accessToken = json["access_token"] >>> ToString
        self.scope = json["scope"] >>> ToString
        self.tokenType = json["token_type"] >>> ToString
    }
    
    func isLoggedIn() -> Bool {
        return self.accessToken != nil
    }
    
    func login() {
        UIApplication.sharedApplication().openURL(NSURL.URLWithString("https://github.com/login/oauth/authorize?client_id=\(GithubAuth.Config.clientId!)&state=\(GithubAuth.Config.state)&redirect_uri=\(GithubAuth.Config.redirectURI!)"))
    }
    
    func handleOpenURL(url: NSURL) -> Bool {
        if (!url.absoluteString.hasPrefix("harmonicexample://githubcallback")) { return false }
        
        NSNotificationCenter.defaultCenter()
        
        // Gets access token
        if let code = self.getCodeFromURL(url) {
            var request = NSMutableURLRequest(URL: NSURL(string: "https://github.com/login/oauth/access_token"))
            request.HTTPMethod = "POST"
            
            var dataString = "client_id=\(GithubAuth.Config.clientId!)&client_secret=\(GithubAuth.Config.clientSecret!)&code=\(code)"
            request.HTTPBody = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            self.request(request) { (request, response, model, error) -> Void in
                if (self.authCallback != nil) { self.authCallback!(error) }
            }
            
            return true
        }
        
        return false
    }
    
    func getCodeFromURL(url: NSURL) -> String? {
        var queryParams = url.absoluteString.stringByReplacingOccurrencesOfString("\(GithubAuth.Config.redirectURI!)?", withString: "")
        
        // Iterates through query parameters and
        for group in queryParams.componentsSeparatedByString("&") {
            var pieces = group.componentsSeparatedByString("=")
            if (pieces.count >= 2 && pieces[0] == "code") {
                return pieces[1]
            }
        }
        
        return nil
    }
    
}
