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

If you are looking to use the Alamofire offerings, please look at [Alamofire doc](https://github.com/Alamofire/Alamofire) on how to install into your project

## Example Model Usage

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
        self.firstName <*> json["first_name"]
        self.lastName <*> json["last_name"]
        self.bestFriend <*> json["best_friend"]
        self.friends <*> json["friends"]
        self.birthday <*> json["birthday"] >>> MyCustomFormatter.ToBirthday
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

## Example Network Adapter Usage

### Loading collection of models via URL

If you want to have the URL being created dynamically or wrap this not have to use this nasty URL everywhere, you can easily move this into its own method. See the folloing examples for that
- [Wrapped function for code below](https://github.com/RokkinCat/harmonic/blob/master/Harmonic/UserModel.swift#L28)
- [Real example using GitHub API](https://github.com/RokkinCat/harmonic/blob/master/Examples/GithubExample/GithubExample/UserModel.swift#L43)

```swift
HarmonicConfig.adapter = HarmonicAlamofireAdapter()  // This only needs to get done once (probably in AppDelegate)
        
// Gets collection of users
UserModel.get("http://statuscodewhat.herokuapp.com/200?body=%5B%7B%22birthday%22%3A%221989-03-01%22%2C%22first_name%22%3A%22Josh%22%2C%22friends%22%3A%5B%7B%22first_name%22%3A%22Red%2520Ranger%22%7D%2C%7B%22first_name%22%3A%22Green%2520Ranger%22%7D%5D%2C%22last_name%22%3A%22Holtz%22%2C%22best_friend%22%3A%7B%22first_name%22%3A%22Bandit%22%2C%22last_name%22%3A%22The%2520Cat%22%7D%7D%5D") {(request, response, models, error) in
    
    var users = models as? [UserModel]
    users?.each({
        (user) -> () in
        println("From Mock users.json API with model - \(user.firstName)")
    })

}
```

### Loading single model via URL

```swift
HarmonicConfig.adapter = HarmonicAlamofireAdapter() // This only needs to get done once (probably in AppDelegate)
        
// Gets user model
var user = UserModel()
user.get("http://statuscodewhat.herokuapp.com/200?body=%7B%22birthday%22%3A%221989-03-01%22%2C%22first_name%22%3A%22Josh%22%2C%22friends%22%3A%5B%7B%22first_name%22%3A%22Red%2520Ranger%22%7D%2C%7B%22first_name%22%3A%22Green%2520Ranger%22%7D%5D%2C%22last_name%22%3A%22Holtz%22%2C%22best_friend%22%3A%7B%22first_name%22%3A%22Bandit%22%2C%22last_name%22%3A%22The%2520Cat%22%7D%7D") {(request, response, model, error) in
    println("From Mock user.json API with model - \(user.firstName)")
}
```

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

Harmonic is available under the MIT license. See the LICENSE file for more info.
