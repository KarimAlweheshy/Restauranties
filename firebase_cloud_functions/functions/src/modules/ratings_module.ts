import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import Rating from '../models/rating'
import Restaurant from '../models/restaurant'
import * as RatingUtilities from '../utilities/rating_utilities'
import * as core from "express-serve-static-core"
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'
import { ServiceFactory } from '../factories/service_factory'
import * as module from './module'

export class RatingsAPISModule implements module.Module {
    pathPrefix = "ratings"

    private factory: ServiceFactory

    constructor(factory: ServiceFactory) {
        this.factory = factory
    }

    appForModule(authenticationMiddleware: AuthenticationMiddleware): core.Express {
        const app = this.factory.makeNewService()

        app.all('/', authenticationMiddleware.authenticate)
        
        app.get('/',  this.getRestaurantRatings)
        app.post('/', authenticationMiddleware.authenticateRater, this.addRating)
        app.delete('/:ratingID', authenticationMiddleware.authenticateAdmin, this.deleteRating)
        app.post('/:ratingID/reply', authenticationMiddleware.authenticateOwner, this.replyToRating)

        return app
    }

    private async getRestaurantRatings(req: core.Request, res: core.Response) {
        const restaurantID = req.query.restaurant_id
        if (!restaurantID) {
            res.status(400).send('Missing restaurantID query arg')
            return
        }
    
        try {
            await this.assertRestaurantExists(req.params.restaurantID)
        } catch {
            res.status(400).send('Restaurant does not exist')
            return
        }
        
        const db = admin.firestore()
        const ratingsCollection = db.collection("ratings").orderBy("visitDate", 'desc')
        const snapshot = await ratingsCollection.where('restaurantID', '==', restaurantID).get()
        if (!snapshot.docs) { 
            res.status(204).send() 
            return
        }
    
        const ratingDocMaps = snapshot.docs.map(doc => { return { doc: doc, rating: doc.data() as Rating }})
        const userIDs = new Set(ratingDocMaps.map(ratingDocMap => { return { uid: ratingDocMap.rating.ownerID } }))
        const usersResult = await admin.auth().getUsers(Array.from(userIDs))
        if (usersResult.notFound.length > 0) {
            res.status(400).send('Couldn\'t find all raters with ids ' + usersResult.notFound)
            return
        }
        const userMap = new Map()
        usersResult.users.map(user => userMap.set(user.uid, user))

        res.status(200).send(ratingDocMaps.map(ratingDocMap => {
            const user = userMap.get(ratingDocMap.rating.ownerID)
            return {
                ...ratingDocMap.rating,
                username: user.displayName,
                photoURL: user.photoURL,
                creationDate: ratingDocMap.doc.createTime.seconds,
                modificationDate: ratingDocMap.doc.updateTime.seconds,
                visitDate: ratingDocMap.rating.visitDate.seconds,
            }
        }))
    }

    private async addRating(req: core.Request, res: core.Response) {
        if (req.body as Rating === undefined) {
            res.status(400).send('Missing fields')
            return
        }
        RatingUtilities.verifyRatingKeysAndValues(req.body as Rating)

        try {
            await this.assertRestaurantExists(req.body.restaurantID)
        } catch {
            res.status(400).send('Restaurant does not exist')
            return
        }
        
        const visitDate = new admin.firestore.Timestamp(parseInt(req.body.visitDate), 0)
        
        if (visitDate.toDate().getTime() > new Date().getTime()) {
            res.status(400).send('Cannot add a rating in the future')
            return
        }
        
        const rating = {
            visitDate: new admin.firestore.Timestamp(parseInt(req.body.visitDate), 0),
            restaurantID: req.body.restaurantID,
            ownerID: req.params.uid,
            stars: req.body.stars,
            comment: req.body.comment,
            creationDate: admin.firestore.Timestamp.fromDate(new Date()),
            modificationDate: admin.firestore.Timestamp.fromDate(new Date()),
        }

        const db = admin.firestore()
        
        try {
            const newRatingDocRef = db.collection("ratings").doc()
            await db.runTransaction(async transaction => {
                const restaurantDocSnapshot = await transaction.get(db.collection("restaurants").doc(req.body.restaurantID));
                const restaurant = restaurantDocSnapshot.data() as Restaurant
                const newTotalRatings = restaurant.totalRatings + 1
                const newAverageRating = ((restaurant.averageRating * restaurant.totalRatings) + req.body.stars) / newTotalRatings
                const newTotalNoReply = restaurant.noReplyCount + 1
        
                transaction.update(restaurantDocSnapshot.ref, { totalRatings: newTotalRatings, averageRating: newAverageRating, noReplyCount: newTotalNoReply })
                transaction.create(newRatingDocRef, rating)
            })
            res.status(201).send()
        } catch (error) {
            res.status(400).send('Error adding the new rating')
        }
    }

    private async deleteRating(req: core.Request, res: core.Response) {
        const db = admin.firestore()

        const ratingDocRef = db.collection("ratings").doc(req.params.ratingID)
        const ratingSnapshot = await ratingDocRef.get()
        const rating = ratingSnapshot.data() as Rating

        try{
            await db.runTransaction(async transaction => {
                const restaurantDocSnapshot = await transaction.get(db.collection("restaurants").doc(rating.restaurantID));
                const restaurant = restaurantDocSnapshot.data() as Restaurant
                const newTotalRatings = restaurant.totalRatings - 1
                const newTotalNoReply = restaurant.noReplyCount - 1
                let newAverageRating = 0
                if (!newTotalRatings) {
                    newAverageRating = ((restaurant.averageRating * restaurant.totalRatings) - rating.stars) / newTotalRatings
                }

                transaction.update(restaurantDocSnapshot.ref, { totalRatings: newTotalRatings, averageRating: newAverageRating, noReplyCount: newTotalNoReply })
                transaction.delete(ratingDocRef)
            })
            res.status(200).send()
        } catch(error) {
            res.status(400).send('Error happened deleting the rating')
        }
    }

    private async replyToRating(req: core.Request, res: core.Response) {
        const db = admin.firestore()

        const ratingDocRef = db.collection("ratings").doc(req.params.ratingID)
        const ratingSnapshot = await ratingDocRef.get()
        if (!ratingSnapshot.exists) {
            res.status(400).send('Cannot find rating with id ' + req.params.ratingID)
            return
        }
        const rating = ratingSnapshot.data() as Rating

        const restaurantDocRef = db.collection("restaurants").doc(rating.restaurantID)
        const restaurantSnapshot = await restaurantDocRef.get()
        if (!restaurantSnapshot.exists) {
            res.status(400).send('Failed to find restaurant with id ' + rating.restaurantID)
            return
        }
        const restaurant = restaurantSnapshot.data() as Restaurant

        if (restaurant.ownerID !== req.params.uid) {
            res.status(400).send('User does not own this restaurant')
            return
        }

        if (rating.reply) {
            res.status(400).send('Already replied to this rating')
            return
        }

        if (!req.body.reply || !req.body.reply.length) {
            res.status(400).send('Missing reply body param')
            return
        }

        try{
            await db.runTransaction(async transaction => {
                const doc = await transaction.get(restaurantDocRef);
                const noReplyCount = doc.data()?.noReplyCount - 1;
                transaction.update(restaurantSnapshot.ref, { noReplyCount: noReplyCount })
                transaction.update(ratingDocRef, { reply: req.body.reply })
            })
            res.status(200).send()
        } catch(error) {
            res.status(400).send('Error happened updating the rating')
        }
    }

    private async assertRestaurantExists(restaurantID: string) {
        const db = admin.firestore()
        const restaurantSnapshot = await db.collection("restaurants").doc(restaurantID).get()
        
        if (!restaurantSnapshot.exists) {
            throw new functions.https.HttpsError('failed-precondition', 'Restaurant does not exist');
        }
    }
}