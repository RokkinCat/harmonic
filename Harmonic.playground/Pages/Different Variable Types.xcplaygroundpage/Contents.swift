//: [Previous](@previous)

/*:
# Different Variable Types
We can use more than just Strings! Our example in the "Introduction" page just simply used Strings. We can, however, use all the data types that JSON supports in our models.

Let's define a `JSONObject` (`Dictionary<String, AnyObject>`) with a variety of variable types.
*/

let json: JSONObject = [
	"full_name": "Josh Holtz",
	"age": 26,
	"favorite_number": 45.76,
	"pet": [
		"name": "Bandit",
		"type": "cat"
	],
	"favorite_clothes": ["Blue Hoodie", "Gray Hoodie", "Other Blue Hoodie"]
]

/*:
Our example in the "Introduction" page just simply used Strings. We can, however, use all the data types that JSON supports in our models.
- String
- Int
- Double
- Array
- Dictionary/Object
*/

struct UserModel: HarmonicModel {
	
	var fullName: String?
	var age: Int?
	var favoriteNumber: Double?
	var pet: JSONObject?
	var favoriteClothes: [String]?
	
	init(json: JSONObject) {
		fullName <*> json["full_name"]
		age <*> json["age"]
		favoriteNumber <*> json["favorite_number"]
		pet <*> json["pet"]
		favoriteClothes <*> json["favorite_clothes"]
	}
	
}

let user = UserModel(json: json)
print("Full name: \(user.fullName)")
print("Age: \(user.age)")
print("Favorite Number: \(user.favoriteNumber)")
if let pet = user.pet,
	petName = pet["name"],
	petType = pet["type"] {
	print("Pet: \(petName) the \(petType)")
}
print("Favorite Clothes: \(user.favoriteClothes)")

/*:
That was pretty easy! But what if we want to define a custom type? Like a `String` that needs to get parsed into an `NSDate`? Go to the next page to find out how!
*/

//: [Next](@next)
