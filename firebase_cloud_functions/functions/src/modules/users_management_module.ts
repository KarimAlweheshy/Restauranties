
import * as admin from 'firebase-admin'
import * as UserUtilities from '../utilities/user_utilities'
import * as core from "express-serve-static-core"
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'
import { ServiceFactory } from '../factories/service_factory'
import * as module from './module'

export class UserManagementAPISModule implements module.Module {
    pathPrefix = "users"

    private factory: ServiceFactory

    constructor(factory: ServiceFactory) {
        this.factory = factory
    }

    appForModule(authenticationMiddleware: AuthenticationMiddleware): core.Express {
        const app = this.factory.makeNewService()

        app.all('/', authenticationMiddleware.authenticate, authenticationMiddleware.authenticateAdmin)

        app.get('/', this.getAllUsers)
        app.delete('/:userID', this.deleteUser)

        return app
    }

    private async getAllUsers(req: core.Request, res: core.Response) {
        const result = await admin.auth().listUsers();
        res.status(200).send(
            result.users.map(user => {
                return { 
                    username: user.displayName,
                    photoURL: user.photoURL,
                    creationDate: user.metadata.creationTime,
                    claims: user.customClaims,
                    isVerified: user.emailVerified,
                    uid: user.uid,
                    email: user.email,
                }
            })
        )
    }

    private async deleteUser(req: core.Request, res: core.Response) {
        const userID = req.params.userID
        const user = await UserUtilities.findUser(admin.auth(), userID)
        if (UserUtilities.isAdminUser(user)) {
            res.status(400).send('Cannot delete admin a user from API')
            return
        }
    
        const db = admin.firestore()
        let batch = db.batch()
    
        try {
            // Rater: delete all restaurant ratings
            batch = await this.deleteAllRaterDocument(userID, db, batch)
    
            // Owner: delete all restaurants and restaurant ratings
            batch = await this.deleteAllRestaurantOwnerDocument(userID, db, batch)
            
            await batch.commit()
            await admin.auth().deleteUser(userID)

            res.status(200).send()
        } catch (error) {
            res.status(400).send('Error happened deleting the user')
        }
    }

    private async deleteAllRestaurantOwnerDocument(userID: string, db: FirebaseFirestore.Firestore, batch: FirebaseFirestore.WriteBatch) {
        const restaurantsQuery = db.collection("restaurants").where('ownerID', '==', userID)
        const restaurantsSnapshots = await restaurantsQuery.get()
        
        const restaurantIDs = new Array()
        restaurantsSnapshots.forEach(doc => { 
            restaurantIDs.push(doc.id)
            batch.delete(doc.ref) 
        })
    
        if (!restaurantIDs.length) { return batch }
    
        const ratingsQuery = db.collection("ratings").where('restaurantID', 'in', restaurantIDs)
        const ratingsSnapshots = await ratingsQuery.get()
        ratingsSnapshots.forEach(doc => batch.delete(doc.ref))
    
        return batch
    }
    
    private async deleteAllRaterDocument(userID: string, db: FirebaseFirestore.Firestore, batch: FirebaseFirestore.WriteBatch) {
        const ratingsQuery = db.collection("ratings").where('ownerID', '==', userID)
        const ratingsQuerySnapshots = await ratingsQuery.get()
        const ratings = ratingsQuerySnapshots.docs.map(doc => doc.data())
        const affectedRestaurantIDs = Array.from(new Set(ratings.map(rating => rating.restaurantID)))
        ratingsQuerySnapshots.forEach(doc => batch.delete(doc.ref))
    
        for (const restaurantID of affectedRestaurantIDs) { 
            const restaurantRef = db.collection("restaurants").doc(restaurantID)
            const remainingRatingsQuery = db.collection("ratings").where("restaurantID", "==", restaurantID)
            const newRatingsQuerySpanshot = await remainingRatingsQuery.get()
            let newRatings = newRatingsQuerySpanshot.docs.map(doc => doc.data())
            newRatings = newRatings.filter(rating => !ratings.includes(rating))
            
            const ratingsCount = newRatings.length
            const noReplyCount = newRatings.reduce((accumulator, currentValue) => accumulator + (currentValue.reply ? 1 : 0), 0)
            const totalStars = newRatings.reduce((accumulator, currentValue) => accumulator + currentValue.stars, 0)
            const updates = { totalRatings: ratingsCount, averageRating: totalStars / ratingsCount, noReplyCount: noReplyCount }
    
            batch.update(restaurantRef, updates)
        }
    
        return batch
    }
}

