const admin = require("firebase-admin");

const restaurants_apis = require('./apis/restaurants_apis');
const user_rights_apis = require('./apis/user_right_apis');
const users_management_apis = require('./apis/users_management_apis');

admin.initializeApp()

const db = admin.firestore()
db.settings({ ignoreUndefinedProperties: true })

exports.addRestaurant = restaurants_apis.addRestaurant
exports.allRestaurants = restaurants_apis.allRestaurants
exports.myRestaurants = restaurants_apis.myRestaurants

exports.becomeAdmin = user_rights_apis.becomeAdmin
exports.becomeOwner = user_rights_apis.becomeOwner
exports.becomeRater = user_rights_apis.becomeRater
  
exports.deleteUser = users_management_apis.deleteUser
exports.getAllUsers = users_management_apis.getAllUsers
