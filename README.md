# Harmonic - iOS/Swift

A Swift library for loading JSON objects and arrays into Swift objects

```swift
var json : Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz"];

var user = UserModel.create(json)
println("User - \(user.firstName) \(user.lastName)");
```

### Updates

Version | Changes
--- | ---
**0.1.0** | Initial release

### Features
- Parses models from JSON objects and arrays
- Uses monads to set JSON values to `HarmonicModel` attributes
    - Map primative-ish (integers, floats, booleans, strings) to attributes
    - Map JSON objects and arrays to sub-models (ex: UserModel can have a UserModel attribute)
    - Map values with formatting functions using custom monads (ex: take date as a string from the JSON object and format to NSDate for model)

## Installation

### Drop-in Classes
Clone the repository and drop in the .swift files from the "Classes" directory into your project.

## Example Usage

```swift
var json : Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz",
    "best_friend" : ["first_name" : "Bandit", "last_name" : "The Cat"],
    "friends" : [ ["first_name" : "Red Ranger"], ["first_name" : "Green Ranger"] ],
    "birthday" : "1989-03-01"
]
var jsons = [json]

// Single model
var user = UserModel.create(json) // OR HarmonicModelMaker<UserModel>.createModel(json)
println("User - \(user.firstName) \(user.lastName) \(user.birthday)")
println("\tBest Friend - \(user.bestFriend?.firstName) \(user.bestFriend?.lastName)")
user.friends?.each( {
    (friend) -> Void in
    println("\tFriend - \(friend.firstName)");
})
```

### Example model definition

```swift
import Foundation

class UserModel: HarmonicModel {
    
    var firstName: String?
    var lastName: String?
    var bestFriend: UserModel?
    var friends: Array<UserModel>?
    var birthday: NSDate?
    
    override func parse(json : JSONObject) {
        self.firstName = json["first_name"] >>> ToString
        self.lastName = json["last_name"] >>> ToString
        self.bestFriend = json["best_friend"] >>> ToJSONObject >>> HarmonicModelMaker<UserModel>.createModel
        self.friends = json["friends"] >>> ToJSONArray >>> HarmonicModelMaker<UserModel>.createCollection
        self.birthday = json["birthday"] >>> MyCustomFormatter.ToBirthday
    }
    
}
```

### Example Formatter using custom monad

```swift
struct MyCustomFormatter {
    
    static func ToBirthday(object: AnyObject) -> NSDate? {
        
        var date: NSDate?
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        date = dateStringFormatter.dateFromString(object as String)
        
        return date
    }
    
}
```

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

Harmonic is available under the MIT license. See the LICENSE file for more info.
