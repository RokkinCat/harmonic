//
//  HarmonicTests.swift
//  HarmonicTests
//
//  Created by Josh Holtz on 8/11/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

import UIKit
import XCTest

class HarmonicTests: XCTestCase {
    
    var jsonUser1 : JSONObject = ["first_name" : "Josh", "last_name" : "Holtz",
        "best_friend" : ["first_name" : "Bandit", "last_name" : "The Cat"],
        "friends" : [ ["first_name" : "Red Ranger"], ["first_name" : "Green Ranger"] ],
        "birthday" : "1989-03-01"
    ];
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUserModel() {
        let user = UserModel.parse(jsonUser1)
        self.commonUserTest(user)
    }
    
    func testUserModels() {
        let users = UserModel.parse([jsonUser1])
        let user : UserModel =  users[0]
        
        self.commonUserTest(user)
    }
	
	func testStructUserModel() {
		let user = StructUserModel.parse(jsonUser1)
		self.commonUserTest(user)
	}
	
	func testStructUserModels() {
		let users = StructUserModel.parse([jsonUser1])
		let user : StructUserModel =  users[0]
		
		self.commonUserTest(user)
	}
	
    func testUserModelString() {
        var user: UserModel?
        do {
            user = try UserModel.parse("{\"birthday\":\"1989-03-01\",\"first_name\":\"Josh\",\"friends\":[{\"first_name\":\"Red Ranger\"},{\"first_name\":\"Green Ranger\"}],\"last_name\":\"Holtz\",\"best_friend\":{\"first_name\":\"Bandit\",\"last_name\":\"The Cat\"}}")
        } catch {
			user = nil
        }
        
        XCTAssertNotNil(user, "User should not be nil");
        self.commonUserTest(user!);
        
    }
    
    func testUserModelsString() {
        var users: [UserModel]?
        do {
            users = try UserModel.parse("[{\"birthday\":\"1989-03-01\",\"first_name\":\"Josh\",\"friends\":[{\"first_name\":\"Red Ranger\"},{\"first_name\":\"Green Ranger\"}],\"last_name\":\"Holtz\",\"best_friend\":{\"first_name\":\"Bandit\",\"last_name\":\"The Cat\"}}]")
        } catch {
            users = nil
			XCTFail("Could not parse JSON collection string")
        }
        
        XCTAssertTrue(users != nil, "Users should not be nil")
        XCTAssertEqual(users!.count, 1, "Users count should be 1")

        let user = users![0] as UserModel
        self.commonUserTest(user)
    }
    
    func testBadUserModel() {
        // Broken model
        //  - has firstName mapped correctly
        //  - has lastName mapped incorrectly
        //  - has bestFriend mapped incorrectly
        //  - has friends mapped incorrectly
        //  - has format function on birthday incorrectly
		let user : BrokenUserModel = BrokenUserModel.parse(jsonUser1)
        
        // The good
        XCTAssertEqual(jsonUser1["first_name"]! as! String, user.firstName!, "First names should equal");
        
        // The nils
        XCTAssertNil(user.lastName, "Last name should be nil");
        XCTAssertNil(user.bestFriend, "Best friend should be nil");
        XCTAssertNil(user.friends, "Friends should be nil");
        XCTAssertNil(user.birthday, "Birthday should be nil");
        
    }
    
    // MARK: Private
    
    func commonUserTest(user : UserModel) {
        // Standard variables
        XCTAssertEqual(jsonUser1["first_name"]! as! String, user.firstName!, "First names should equal")
        XCTAssertEqual(jsonUser1["last_name"]! as! String, user.lastName!, "Last name should equal ")
        
        // Single model assocation
		let bestFriendFirstName = (jsonUser1["best_friend"] as! JSONObject)["first_name"] as! String
        XCTAssertEqual(bestFriendFirstName, user.bestFriend!.firstName!, "Best friend's first names should equal")
        
        // Collection models association
        var firstFriend : Dictionary<String, AnyObject> = jsonUser1["friends"]![0] as! Dictionary<String, AnyObject>
        XCTAssertEqual(jsonUser1["friends"]!.count, user.friends!.count, "Friend's count should equal")
        XCTAssertEqual(firstFriend["first_name"]! as! String, user.friends![0].firstName!, "Friend's first name should be equal")
        
        // Formatter function
        XCTAssertNotNil(user.birthday, "Birthday should not be nil")
        
        var birthdayParts : Array<String> = (jsonUser1["birthday"]! as! String).componentsSeparatedByString("-")
        XCTAssertEqual( Int(birthdayParts[0])! ,  user.birthday!.year(), "Birthdy years should equal")
        XCTAssertEqual( Int(birthdayParts[1])! ,  user.birthday!.month(), "Birthdy months should equal")
        XCTAssertEqual( Int(birthdayParts[2])! ,  user.birthday!.day(), "Birthdy days should equal")
    }
	
	func commonUserTest(user : StructUserModel) {
		// Standard variables
		XCTAssertEqual(jsonUser1["first_name"]! as! String, user.firstName!, "First names should equal")
		XCTAssertEqual(jsonUser1["last_name"]! as! String, user.lastName!, "Last name should equal ")
		
		// Formatter function
		XCTAssertNotNil(user.birthday, "Birthday should not be nil")
		
		var birthdayParts : Array<String> = (jsonUser1["birthday"]! as! String).componentsSeparatedByString("-")
		XCTAssertEqual( Int(birthdayParts[0])! ,  user.birthday!.year(), "Birthdy years should equal")
		XCTAssertEqual( Int(birthdayParts[1])! ,  user.birthday!.month(), "Birthdy months should equal")
		XCTAssertEqual( Int(birthdayParts[2])! ,  user.birthday!.day(), "Birthdy days should equal")
	}
	
}

extension NSDate {
    
    func componentFor(component : NSCalendarUnit) -> Int {
        return NSCalendar.currentCalendar().component(component, fromDate: self)
    }
    
    func year() -> Int {
        return self.componentFor(NSCalendarUnit.Year)
    }
    
    func month() -> Int {
        return self.componentFor(NSCalendarUnit.Month)
    }
    
    func day() -> Int {
        return self.componentFor(NSCalendarUnit.Day)
    }
    
}
