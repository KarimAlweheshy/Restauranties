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

    appForModule(authenticationMiddleware: AuthenticationMiddleware): core.Express {
        const app = this.factory.makeNewService()
        
        app.all('/', authenticationMiddleware.authenticate)

        app.post('/becomeOwner', this.becomeOwner)
        app.post('/becomeRater', this.becomeRater)
        app.post('/becomeAdmin', this.becomeAdmin)

        return app
    }

    private async becomeOwner(req: core.Request, res: core.Response) {
        await admin.auth().setCustomUserClaims(req.params.uid, { owner: true })
        return res.status(200).send({ message: 'User is now an owner' })
    }

    private async becomeRater(req: core.Request, res: core.Response) {
        await admin.auth().setCustomUserClaims(req.params.uid, {})
        return res.status(200).send({ message: 'User is now a rater' })
    }

    private async becomeAdmin(req: core.Request, res: core.Response) {
        await admin.auth().setCustomUserClaims(req.params.uid, { admin: true })
        return res.status(200).send({ message: 'User is now an admin' })
    }
}