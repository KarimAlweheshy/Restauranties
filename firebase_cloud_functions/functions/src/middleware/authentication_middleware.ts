import * as core from "express-serve-static-core"
import * as UserUtilities from '../utilities/user_utilities'
import * as admin from 'firebase-admin'

export class AuthenticationMiddleware {
    async authenticate(req: core.Request, res: core.Response, next: core.NextFunction) {
        if (req.headers.authorization === undefined) {
            res.status(401).send('Missing auth token')
            return 
        }
        
        const token = req.headers.authorization!
        try {
            const decodedToken = await admin.auth().verifyIdToken(token)
            await UserUtilities.findUser(admin.auth(), decodedToken.uid)
            req.params.uid = decodedToken.uid
            next()
        } catch {
            res.status(401).send('Invalid token')
            return 
        }
    }

    async authenticateRater(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsRaterUser(admin.auth(), req.params.uid)
            next()
        } catch {
            res.status(403).send('Only Rater is allowed to access such calls')
        }
    }

    async authenticateAdmin(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsAdminUser(admin.auth(), req.params.uid)
            next()
        } catch {
            res.status(403).send('Only Admin is allowed to access such calls')
        }
    }

    async authenticateOwner(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsRestaurantOwnerUser(admin.auth(), req.params.uid)
            next()
        } catch {
            res.status(403).send('Only Owner is allowed to access such calls')
        }
    }

    async authenticateNotOwner(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsNotOwner(admin.auth(), req.params.uid)
            next()
        } catch {
            res.status(403).send('Only Owner is allowed to access such calls')
        }
    }
}
