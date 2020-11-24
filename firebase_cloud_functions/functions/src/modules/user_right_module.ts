import * as admin from 'firebase-admin'
import * as core from "express-serve-static-core"
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'
import { ServiceFactory } from '../factories/service_factory'
import * as module from './module'

export class UserRightAPISModule implements module.Module {
    pathPrefix = "me"

    private factory: ServiceFactory

    constructor(factory: ServiceFactory) {
        this.factory = factory
    }

    appForModule = (authenticationMiddleware: AuthenticationMiddleware): core.Express => {
        const app = this.factory.makeNewService()
        
        app.use(authenticationMiddleware.authenticate)

        app.post('/becomeOwner', this.becomeOwner)
        app.post('/becomeRater', this.becomeRater)
        app.post('/becomeAdmin', this.becomeAdmin)

        return app
    }

    private becomeOwner = async (req: core.Request, res: core.Response) => {
        await admin.auth().setCustomUserClaims(res.locals.uid, { owner: true })
        return res.status(200).json({ message: 'User is now an owner' })
    }

    private becomeRater = async (req: core.Request, res: core.Response) => {
        await admin.auth().setCustomUserClaims(res.locals.uid, {})
        return res.status(200).json({ message: 'User is now a rater' })
    }

    private becomeAdmin = async (req: core.Request, res: core.Response) => {
        await admin.auth().setCustomUserClaims(res.locals.uid, { admin: true })
        return res.status(200).json({ message: 'User is now an admin' })
    }
}