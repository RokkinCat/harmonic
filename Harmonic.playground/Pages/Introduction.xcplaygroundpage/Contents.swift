/*:
# Welcome to the Harmonic Playground
We will walk you through with the simplest Harmonic example to something a little more advanced and custom.

We will first create some sample JSON objects that we will parse with Harmonic. These JSON objects simple contain a first and last name.
*/
let jsonUser: Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : "Holtz"]

/*:
## Defining the `HarmonicModel`
We will next create a `UserModel` struct using the `HarmonicModel` protocol. This struct will contain the a `firstName` and `lastName` that will consume the data we will provide it from above.

The `HarmonicModel` requires an initializer that takes a `JSONObject`. `JSONObject` is simply a typealias for `Dictionary<String, AnyObject>`.
*/
struct UserModel: HarmonicModel {

	var firstName: String?
	var lastName: String?
	
	init(json: JSONObject) {
		firstName <*> json["first_name"]
		lastName <*> json["last_name"]
	}
	
}

// Single model
let user = UserModel(json: jsonUser)
print("First name: \(user.firstName)")
print("Last name: \(user.lastName)")

/*:
## Explaining the example
You will notice there is an operator that you (may) have not seen before. This `<*>` operator is used to assign the variables from the `JSONObject` that is passed into the function. What this operator does is cast the object from the `JSONObject` into the type of variable that the object is being assigned to. In this `UserModel` example above, both `json["first_name"]` and `json["last_name"]` will be casted into `String`s.

## What happens if `last_name` is't a String then?
If the value in `json["last_name"]` is not actually of type `String`, it will not be assigned and `lastName` will remain nil.
*/
let jsonUserWrong: Dictionary<String, AnyObject> = ["first_name" : "Josh", "last_name" : 10]

let userWrong = UserModel(json: jsonUserWrong)
print("First name: \(userWrong.firstName)")
print("Last name: \(userWrong.lastName)") // This will be nil
/*:
This line above will be nil because `10` isn't a `String`.

## Now it's your turn!
Change some values in the JSON objects above and in the `UserModel` to see how things behave.
*/

//: [Next](@next)
