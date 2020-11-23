import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import Restaurant from '../models/restaurant'
import * as RestaurantUtilities from '../utilities/restaurant_utilities'
import * as core from "express-serve-static-core"
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'
import { ServiceFactory } from '../factories/service_factory'
import * as module from './module'

export class RestaurantsAPISModule implements module.Module {
    factory: ServiceFactory

    constructor(factory: ServiceFactory) {
        this.factory = factory
    }

    appForModule(authenticationMiddleware: AuthenticationMiddleware): core.Express {
        const app = this.factory.makeNewService()

        app.get(
            '/',
            authenticationMiddleware.authenticate,
            authenticationMiddleware.authenticateNotOwner,
            this.getAllRestaurants
        )

        app.get(
            '/mine',
            authenticationMiddleware.authenticate,
            authenticationMiddleware.authenticateOwner,
            this.getMyRestaurants
        )

        app.post(
            '/',
            authenticationMiddleware.authenticate,
            authenticationMiddleware.authenticateOwner,
            this.addRestaurant
        )

        app.get(
            '/:restaurantID',
            authenticationMiddleware.authenticate,
            this.getRestaurantDetails
        )

        return app
    }

    private async getMyRestaurants(req: core.Request, res: core.Response) {
        const db = admin.firestore()
        const restaurantsCollection = db.collection("restaurants")
        const filteredRestaurantsCollection = this.applyPendingReplyFilterOnDocReferenceIfPossible(restaurantsCollection, req.query)
        const snapshot = await filteredRestaurantsCollection.where('ownerID', '==', req.params.uid).get()
        if (snapshot.empty) { 
            res.status(200).send('[]') 
        } else {
            res.status(200).send(snapshot.docs.map(doc => this.dtoFromRestaurantDocument(doc)))
        }
    }

    private async getAllRestaurants(req: core.Request, res: core.Response) {
        const db = admin.firestore()
        const restaurantsCollection = db.collection("restaurants")
        const filteredRestaurantsCollection = this.applyRatingFilterOnDocReferenceIfPossible(restaurantsCollection, req.query)
        const snapshot = await filteredRestaurantsCollection.orderBy("creationDate").get()
        if (snapshot.empty) { 
            res.status(200).send('[]') 
        } else {
            res.status(200).send(snapshot.docs.map(doc => this.dtoFromRestaurantDocument(doc)))
        }
    }

    private async getRestaurantDetails(req: core.Request, res: core.Response) {
        const restaurantID = req.params.restaurantID
        const db = admin.firestore()
        const restaurantsRef = db.collection("restaurants").doc(restaurantID)
        const doc = await restaurantsRef.get()
        if (!doc.exists) {
            res.status(404).send('Restaurant with id ' + restaurantID + ' not found') 
        } else {
            res.status(200).send(this.dtoFromRestaurantDocument(doc))
        }
    }

    private async addRestaurant(req: core.Request, res: core.Response) {
        RestaurantUtilities.verifyRestaurantKeysAndValues(req.body)

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
            req.params.uid,
            0,
            0,
            0
        )
        const docReference = await restaurantsCollection.add(restaurant)
        const documentSnapshot = await docReference.get()
        res.status(201).send(this.dtoFromRestaurantDocument(documentSnapshot))
    }

    private applyRatingFilterOnDocReferenceIfPossible(
        docReference: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>, 
        data: any
      ): FirebaseFirestore.Query {
          let query = docReference.orderBy('averageRating', 'desc')
          if (!data || !data.filter) {
            return query
          }
          if (!parseInt(data.filter)) {
            throw new functions.https.HttpsError('failed-precondition', 'Filter must be a whole number e.g. 1');  
          }
          if (parseInt(data.filter) > 5 || parseInt(data.filter) < 1) {
            throw new functions.https.HttpsError('failed-precondition', 'Filter must be between 1 (included) and 5 (included)');  
          }
          const filterRating = parseInt(data.filter)
          query = docReference.where('averageRating', '<=', filterRating)
          if (filterRating > 1) {
            query = docReference.where('averageRating', '>=', filterRating - 1)
          } else {
            // To exclude restaurants without ratings
            query = docReference.where('averageRating', '>', 0)
          }
          return query
      }
      
    private applyPendingReplyFilterOnDocReferenceIfPossible(
        docReference: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>, 
        data: any
    ): FirebaseFirestore.Query {
        if (!data || data.filterPendingReply === undefined) {
            return docReference.orderBy("creationDate")
        }
        if (data.filterPendingReply !== true && data.filterPendingReply !== false) {
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
      
    private dtoFromRestaurantDocument(doc: FirebaseFirestore.DocumentSnapshot): any {
        return {
            ...doc.data(),
            id: doc.id,
            creationDate: doc.createTime?.seconds,
            modificationDate: doc.updateTime?.seconds,
        }
    }
}