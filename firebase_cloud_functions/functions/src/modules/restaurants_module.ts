import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import Restaurant from '../models/restaurant'
import * as RestaurantUtilities from '../utilities/restaurant_utilities'
import * as core from "express-serve-static-core"
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'
import { ServiceFactory } from '../factories/service_factory'
import * as module from './module'
import * as UserUtilities from '../utilities/user_utilities'

export class RestaurantsAPISModule implements module.Module {
    pathPrefix = "restaurants"

    private factory: ServiceFactory

    constructor(factory: ServiceFactory) {
        this.factory = factory
    }

    appForModule = (authenticationMiddleware: AuthenticationMiddleware): core.Express => {
        const app = this.factory.makeNewService()

        app.use(authenticationMiddleware.authenticate)

        app.get('/', authenticationMiddleware.authenticateNotOwner, this.getAllRestaurants)
        app.get('/mine', authenticationMiddleware.authenticateOwner, this.getMyRestaurants)
        app.post('/', authenticationMiddleware.authenticateOwner, this.addRestaurant)
        app.get('/:restaurantID', this.getRestaurantDetails)
        app.delete('/:restaurantID', authenticationMiddleware.authenticateAdmin, this.deleteRestaurant)

        return app
    }

    private getMyRestaurants = async (req: core.Request, res: core.Response) => {
        const db = admin.firestore()
        const restaurantsCollection = db.collection("restaurants")
        const filteredRestaurantsCollection = this.applyPendingReplyFilterOnDocReferenceIfPossible(restaurantsCollection, req.query)
        const snapshot = await filteredRestaurantsCollection.where('ownerID', '==', res.locals.uid).get()
        if (snapshot.empty) { 
            res.status(200).json('[]') 
        } else {
            res.status(200).json(snapshot.docs.map(doc => this.dtoFromRestaurantDocument(doc)))
        }
    }

    private getAllRestaurants = async (req: core.Request, res: core.Response) => {
        const db = admin.firestore()
        const restaurantsCollection = db.collection("restaurants")

        try {
            const filteredRestaurantsCollection = this.applyRatingFilterOnDocReferenceIfPossible(restaurantsCollection, req.query)
            const snapshot = await filteredRestaurantsCollection.orderBy("creationDate").get()
            if (snapshot.empty) { 
                res.status(200).json('[]') 
            } else {
                res.status(200).json(snapshot.docs.map(doc => {
                    let res = this.dtoFromRestaurantDocument(doc)
                    delete res.noReplyCount
                    return res
                }))
            }
        } catch (error) {
            res.status(400).send(error)
        }   
    }   

    private getRestaurantDetails = async (req: core.Request, res: core.Response) => {
        const restaurantID = req.params.restaurantID
        const db = admin.firestore()
        const restaurantsRef = db.collection("restaurants").doc(restaurantID)
        const doc = await restaurantsRef.get()
        if (!doc.exists) {
            res.status(400).send('Restaurant with id ' + restaurantID + ' not found') 
        } else {
            const response = this.dtoFromRestaurantDocument(doc)
            try {
                UserUtilities.verifyIsRaterUser(res.locals.claims)
                delete response.noReplyCount
            } catch {}
            res.status(200).json(response)
        }
    }

    private deleteRestaurant = async (req: core.Request, res: core.Response) => {
        const restaurantID = req.params.restaurantID
        const db = admin.firestore()
        const restaurantsRef = db.collection("restaurants").doc(restaurantID)
        await restaurantsRef.delete()
        res.sendStatus(200)
    }

    private addRestaurant = async (req: core.Request, res: core.Response) => {
        if (!RestaurantUtilities.verifyRestaurantKeysAndValues(req.body)) {
            res.status(400).send('Restaurant name is missing or invalid. At least three chars')
            return
        }
        

        const db = admin.firestore()
        const restaurantsCollection = db.collection("restaurants")

        const restaurantWithSameNameSnapshot = await restaurantsCollection.where('name', '==', req.body.name).get()
        if (!restaurantWithSameNameSnapshot.empty) {
            res.status(400).send('Owner already has restaurant with same name')
            return
        }
        
        const restaurant = new Restaurant(
            req.body.name,
            req.body.phoneNumber,
            req.body.imageURL,
            req.body.categories,
            res.locals.uid,
            0,
            0,
            0
        )
        try {
            const firebaseEntry = JSON.parse(JSON.stringify(restaurant))
            firebaseEntry.creationDate = admin.firestore.Timestamp.now()
            const docReference = await restaurantsCollection.add(firebaseEntry)
            const documentSnapshot = await docReference.get()
            res.status(201).json(this.dtoFromRestaurantDocument(documentSnapshot))
        } catch (error) {
            res.status(400).json('Something went wrong')
        }
    }

    private applyRatingFilterOnDocReferenceIfPossible = (
        docReference: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>, 
        data: any | null
      ): FirebaseFirestore.Query => {
          let query = docReference.orderBy('averageRating', 'desc')
          if (!data || !data.filter) {
            return query
          }
          const filterRating = parseInt(data.filter)
          if (!filterRating) {
            throw new functions.https.HttpsError('failed-precondition', 'Filter must be a whole number e.g. 1');  
          }
          if (filterRating > 5 || filterRating < 1) {
            throw new functions.https.HttpsError('failed-precondition', 'Filter must be between 1 (included) and 5 (included)');  
          }
          query = query.where('averageRating', '<=', filterRating)
          if (filterRating > 1) {
            query = query.where('averageRating', '>=', filterRating - 1)
          } else {
            // To exclude restaurants without ratings
            query = query.where('averageRating', '>', 0)
          }
          return query
      }
      
    private applyPendingReplyFilterOnDocReferenceIfPossible = (
        docReference: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>, 
        data: any | null
    ): FirebaseFirestore.Query => {
        if (!data || data.filterPendingReply === undefined) {
            return docReference.orderBy("creationDate")
        }
        if (data.filterPendingReply !== "true" && data.filterPendingReply !== "false") {
            throw new functions.https.HttpsError('failed-precondition', 'Filter must be a boolean');  
        }
        let queryReference: FirebaseFirestore.Query
        if (data.filterPendingReply) {
            queryReference = docReference.where('noReplyCount', '!=', 0).orderBy('noReplyCount', 'desc')
        } else {
            queryReference = docReference.where('noReplyCount', '==', 0)
        }
        return queryReference.orderBy("creationDate")
    }
      
    private dtoFromRestaurantDocument = (doc: FirebaseFirestore.DocumentSnapshot): any => {
        return {
            ...doc.data(),
            id: doc.id,
            creationDate: doc.createTime?.seconds,
            modificationDate: doc.updateTime?.seconds,
        }
    }
}