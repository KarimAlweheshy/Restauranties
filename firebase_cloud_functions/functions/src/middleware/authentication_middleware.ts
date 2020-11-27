import * as core from "express-serve-static-core"
import * as UserUtilities from '../utilities/user_utilities'
import * as admin from 'firebase-admin'

export class AuthenticationMiddleware {
    async authenticate(req: core.Request, res: core.Response, next: core.NextFunction) {
        if (req.headers.authorization === undefined) {
            res.sendStatus(401)
            return 
        }
        
        const token = req.headers.authorization!
        try {
            const decodedToken = await admin.auth().verifyIdToken(token)
            const user = await UserUtilities.findUser(admin.auth(), decodedToken.uid)
            res.locals.uid = decodedToken.uid
            res.locals.claims = user.customClaims
            next()
        } catch {
            res.sendStatus(401)
            return 
        }
    }

    async authenticateRater(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsRaterUser(res.locals.claims)
            next()
        } catch {
            res.status(403).send('Only Rater is allowed to access such calls')
        }
    }

    async authenticateAdmin(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsAdminUser(res.locals.claims)
            next()
        } catch {
            res.status(403).send('Only Admin is allowed to access such calls')
        }
    }

    async authenticateOwner(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsRestaurantOwnerUser(res.locals.claims)
            next()
        } catch {
            res.status(403).send('Only Owner is allowed to access such calls')
        }
    }

    async authenticateNotOwner(req: core.Request, res: core.Response, next: core.NextFunction) {
        try {
            await UserUtilities.verifyIsNotOwner(res.locals.claims)
            next()
        } catch {
            res.status(403).send('Only Non-Owner is allowed to access such calls')
        }
    }
}
