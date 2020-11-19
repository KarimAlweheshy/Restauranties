import * as admin from 'firebase-admin'

import * as restaurants_apis from './apis/restaurants_apis'
import * as user_rights_apis from './apis/user_right_apis'
import * as users_management_apis from './apis/users_management_apis'
import * as ratings_apis from './apis/ratings_apis'

admin.initializeApp()

const db = admin.firestore()
db.settings({ ignoreUndefinedProperties: true })

module.exports = {
    ...restaurants_apis,
    ...user_rights_apis,
    ...users_management_apis, 
    ...ratings_apis,
}