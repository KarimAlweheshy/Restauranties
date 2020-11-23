import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

import * as restaurants_module from './modules/restaurants_module'
import * as user_rights_module from './modules/user_right_module'
// import * as users_management_apis from './apis/users_management_apis'
import * as ratings_module from './modules/ratings_module'

import { DefaultServiceFactory } from './factories/service_factory'
import { AuthenticationMiddleware } from './middleware/authentication_middleware'

admin.initializeApp()

const db = admin.firestore()
db.settings({ ignoreUndefinedProperties: true })

const serviceFactory = new DefaultServiceFactory()
const authenticationMiddleware = new AuthenticationMiddleware()

const ratingsModule = new ratings_module.RatingsAPISModule(serviceFactory)
const ratingsService = ratingsModule.appForModule(authenticationMiddleware)

const restaurantsModule = new restaurants_module.RestaurantsAPISModule(serviceFactory)
const restaurantsService = restaurantsModule.appForModule(authenticationMiddleware)

const userRightsModule = new user_rights_module.UserRightAPISModule(serviceFactory)
const userRightsService = userRightsModule.appForModule(authenticationMiddleware)

exports.ratings = functions.https.onRequest(ratingsService)
exports.restaurants = functions.https.onRequest(restaurantsService)
exports.me = functions.https.onRequest(userRightsService)

// module.exports = {
//     ...restaurants_apis,
//     ...user_rights_apis,
//     ...users_management_apis, 
//     ...ratings_apis,
// }