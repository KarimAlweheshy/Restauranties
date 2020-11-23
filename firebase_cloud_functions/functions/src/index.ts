import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

// import * as restaurants_apis from './apis/restaurants_apis'
// import * as user_rights_apis from './apis/user_right_apis'
// import * as users_management_apis from './apis/users_management_apis'
import * as ratings_apis from './modules/ratings_api_module'

import { DefaultServiceFactory } from './factories/ServiceFactory'
import { AuthenticationMiddleware } from './middleware/authentication_middleware'

admin.initializeApp()

const db = admin.firestore()
db.settings({ ignoreUndefinedProperties: true })

const serviceFactory = new DefaultServiceFactory()

const ratingsAPIS = new ratings_apis.RatingsAPISModule(serviceFactory)
ratingsAPIS.addRoutesToApp(new AuthenticationMiddleware())

exports.ratings = functions.https.onRequest(ratingsAPIS.app)
// module.exports = {
//     ...restaurants_apis,
//     ...user_rights_apis,
//     ...users_management_apis, 
//     ...ratings_apis,
// }