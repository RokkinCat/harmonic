# Harmonic - iOS/Swift

A Swift library for loading JSON objects and arrays into Swift objects

```swift
var json : Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz"];

var user = UserModel(json: json)
println("User - \(user.firstName) \(user.lastName)");
```

### Updates

Version | Changes
--- | ---
**0.2.0** | Better implementation using protocol extensions
--- | ---
**0.1.0** | Initial release

### Features
- Parses models from JSON objects and arrays
- Uses super duper fun operators to set JSON values to `HarmonicModel` attributes
    - Map primative-ish (integers, floats, booleans, strings) to attributes
    - Map JSON objects and arrays to sub-models (ex: UserModel can have a UserModel attribute)
    - Map values with formatting functions using custom monads (ex: take date as a string from the JSON object and format to NSDate for model)
- Works for both classes and structs

## Installation

### Drop-in Classes
Clone the repository and drop in the .swift files from the "Classes" directory into your project.

## Example Model Usage

```swift
var json : Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz",
    "best_friend" : ["first_name" : "Bandit", "last_name" : "The Cat"],
    "friends" : [ ["first_name" : "Red Ranger"], ["first_name" : "Green Ranger"] ],
    "birthday" : "1989-03-01"
]
var jsons = [json]

// Single model
let user = UserModel.parse(json: json) // OR UserModel.parse(json)

print("User - \(user.firstName) \(user.lastName) \(user.birthday)")
print("\tBest Friend - \(user.bestFriend?.firstName) \(user.bestFriend?.lastName)")
if let friends = user.friends {
	for friend in friends {
		print("\tFriend - \(friend.firstName)")
	}
}

// Collection of models
let users = UserModel.parse(jsons)
let userInUsers = users[0]

print("User in Users - \(userInUsers.firstName) \(userInUsers.lastName) \(userInUsers.birthday)")
print("\tBest Friend - \(userInUsers.bestFriend?.firstName) \(userInUsers.bestFriend?.lastName)")
if let friends = user.friends {
	for friend in friends {
		print("\tFriend - \(friend.firstName)")
	}
}

```

### Example model definition

```swift
class UserModel: HarmonicModel {
    
    var firstName: String?
    var lastName: String?
    var bestFriend: UserModel?
    var friends: Array<UserModel>?
    var birthday: NSDate?
    
    required init(json: JSONObject) {
        self.firstName <*> json["first_name"]
        self.lastName <*> json["last_name"]
        self.bestFriend <*> json["best_friend"]
        self.friends <*> json["friends"]
        self.birthday <*> json["birthday"] >>> MyCustomFormatter.toBirthday
    }
    
}
```

### Example Formatter using custom monad

```swift
struct MyCustomFormatter {
    
    static func toBirthday(object: AnyObject) -> NSDate? {
        
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
