const admin = require("firebase-admin");

const restaurants_apis = require('./apis/restaurants_apis');
const user_rights_apis = require('./apis/user_right_apis');
const users_management_apis = require('./apis/users_management_apis');
const ratings_apis = require('./apis/ratings_apis');

admin.initializeApp()

const db = admin.firestore()
db.settings({ ignoreUndefinedProperties: true })

module.exports = {
    ...restaurants_apis,
    ...user_rights_apis,
    ...users_management_apis, 
    ...ratings_apis 
}