import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

import { RestaurantsAPISModule } from './modules/restaurants_module'
import { UserRightAPISModule } from './modules/user_right_module'
import { UserManagementAPISModule } from './modules/users_management_module'
import { RatingsAPISModule } from './modules/ratings_module'

import { DefaultServiceFactory } from './factories/service_factory'
import { AuthenticationMiddleware } from './middleware/authentication_middleware'
import { ModuleConstructor } from './modules/module'

admin.initializeApp()

const db = admin.firestore()
db.settings({ ignoreUndefinedProperties: true })

const serviceFactory = new DefaultServiceFactory()
const authenticationMiddleware = new AuthenticationMiddleware()

const modulesConstructors: ModuleConstructor[] = [
    RestaurantsAPISModule,
    UserRightAPISModule,
    UserManagementAPISModule,
    RatingsAPISModule
]

modulesConstructors.forEach(modulesConstructor => {
    const module = new modulesConstructor(serviceFactory)
    const service = module.appForModule(authenticationMiddleware)
    exports[module.pathPrefix] = functions.https.onRequest(service)
});
