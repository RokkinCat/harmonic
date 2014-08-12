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
    
    var jsonUser1 : Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz",
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
        var user : UserModel = UserModel.create(jsonUser1)
        
        self.commonUserTest(user)
    }
    
    func testUserModels() {
        var users : Array<UserModel> = HarmonicModelMaker<UserModel>.createCollection([jsonUser1])
        var user : UserModel =  users[0]
        
        self.commonUserTest(user)
    }
    
    func testUserModelString() {
        var error: NSError?
        var user = HarmonicModelMaker<UserModel>.createModel("{\"birthday\":\"1989-03-01\",\"first_name\":\"Josh\",\"friends\":[{\"first_name\":\"Red Ranger\"},{\"first_name\":\"Green Ranger\"}],\"last_name\":\"Holtz\",\"best_friend\":{\"first_name\":\"Bandit\",\"last_name\":\"The Cat\"}}", error: &error)
        
        XCTAssertNotNil(user, "User should not be nil");
        self.commonUserTest(user!);
        
    }
    
    func testUserModelsString() {
        var error: NSError?
        var users = HarmonicModelMaker<UserModel>.createCollection("[{\"birthday\":\"1989-03-01\",\"first_name\":\"Josh\",\"friends\":[{\"first_name\":\"Red Ranger\"},{\"first_name\":\"Green Ranger\"}],\"last_name\":\"Holtz\",\"best_friend\":{\"first_name\":\"Bandit\",\"last_name\":\"The Cat\"}}]", error: &error)
        
        XCTAssertNotNil(users, "Users should not be nil")
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
        var user : BrokenUserModel = BrokenUserModel.create(jsonUser1);
        
        // The good
        XCTAssertEqual(jsonUser1["first_name"]! as String, user.firstName!, "First names should equal");
        
        // The nils
        XCTAssertNil(user.lastName, "Last name should be nil");
        XCTAssertNil(user.bestFriend, "Best friend should be nil");
        XCTAssertNil(user.friends, "Friends should be nil");
        XCTAssertNil(user.birthday, "Birthday should be nil");
        
    }
    
    // MARK: Private
    
    func commonUserTest(user : UserModel) {
        // Standard variables
        XCTAssertEqual(jsonUser1["first_name"]! as String, user.firstName!, "First names should equal")
        XCTAssertEqual(jsonUser1["last_name"]! as String, user.lastName!, "Last name should equal ")
        
        // Single model assocation
        XCTAssertEqual(jsonUser1["best_friend"]!["first_name"]! as String, user.bestFriend!.firstName!, "Best friend's first names should equal")
        
        // Collection models association
        var firstFriend : Dictionary<String, AnyObject> = jsonUser1["friends"]![0] as Dictionary<String, AnyObject>
        XCTAssertEqual(jsonUser1["friends"]!.count, user.friends!.count, "Friend's count should equal")
        XCTAssertEqual(firstFriend["first_name"]! as String, user.friends![0].firstName!, "Friend's first name should be equal")
        
        // Formatter function
        XCTAssertNotNil(user.birthday, "Birthday should not be nil")
        
        var birthdayParts : Array<String> = (jsonUser1["birthday"]! as String).componentsSeparatedByString("-")
        XCTAssertEqual( birthdayParts[0].toInt()! ,  user.birthday!.year(), "Birthdy years should equal")
        XCTAssertEqual( birthdayParts[1].toInt()! ,  user.birthday!.month(), "Birthdy months should equal")
        XCTAssertEqual( birthdayParts[2].toInt()! ,  user.birthday!.day(), "Birthdy days should equal")
    }
    
}

extension HarmonicModel {
    
    func ToBirthday(object: AnyObject) -> NSDate? {
        
        var date: NSDate?
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        date = dateStringFormatter.dateFromString(object as String)
        
        return date
    }
    
}

extension NSDate {
    
    func componentFor(component : NSCalendarUnit) -> Int {
        return NSCalendar.currentCalendar().component(component, fromDate: self)
    }
    
    func year() -> Int {
        return self.componentFor(NSCalendarUnit.YearCalendarUnit)
    }
    
    func month() -> Int {
        return self.componentFor(NSCalendarUnit.MonthCalendarUnit)
    }
    
    func day() -> Int {
        return self.componentFor(NSCalendarUnit.DayCalendarUnit)
    }
    
}
