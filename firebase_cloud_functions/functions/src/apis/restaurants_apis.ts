import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import Restaurant from '../models/restaurant'
import * as UserUtilities from '../utilities/user_utilities'
import * as RestaurantUtilities from '../utilities/restaurant_utilities'

export const myRestaurants = functions.https.onCall(async (data, context) => {
  UserUtilities.verifyAuth(context)
  await UserUtilities.verifyIsRestaurantOwnerUser(admin.auth(), context.auth!.uid)
  const db = admin.firestore()
  const restaurantsCollection = db.collection("restaurants")
  const filteredRestaurantsCollection = applyPendingReplyFilterOnDocReferenceIfPossible(restaurantsCollection, data)
  const snapshot = await filteredRestaurantsCollection.where('ownerID', '==', context.auth?.uid).get()
  if (snapshot.empty) { return [] }
  return snapshot.docs.map(doc => dtoFromRestaurantDocument(doc))
});

export const allRestaurants = functions.https.onCall(async (data, context) => {
  UserUtilities.verifyAuth(context)
  await UserUtilities.verifyIsNotOwner(admin.auth(), context.auth!.uid)
  const db = admin.firestore()
  const restaurantsCollection = db.collection("restaurants")
  const filteredRestaurantsCollection = applyRatingFilterOnDocReferenceIfPossible(restaurantsCollection, data)
  const snapshot = await filteredRestaurantsCollection.orderBy("creationDate").get()
  if (snapshot.empty) { return [] }
  return snapshot.docs.map(doc => dtoFromRestaurantDocument(doc))
});

export const restaurantDetails = functions.https.onCall(async (data, context) => {
  UserUtilities.verifyAuth(context)
  const db = admin.firestore()

  if (!data.restaurantID) {
    throw new functions.https.HttpsError('failed-precondition', 'Missing restaurantID arg');  
  }

  const restaurantsRef = db.collection("restaurants").doc(data.restaurantID)
  const doc = await restaurantsRef.get()
  if (!doc.exists) {
    throw new functions.https.HttpsError('not-found', 'Restaurant with id ' + data.restaurantID + " not found")
  }
  return dtoFromRestaurantDocument(doc)
});

export const addRestaurant = functions.https.onCall(async (data, context) => {
  UserUtilities.verifyAuth(context)
  await UserUtilities.verifyIsRestaurantOwnerUser(admin.auth(), context.auth!.uid)
  RestaurantUtilities.verifyRestaurantKeysAndValues(data)

  const db = admin.firestore()
  const restaurantsCollection = db.collection("restaurants")

  const restaurantWithSameNameSnapshot = await restaurantsCollection.where('name', '==', data.name).get()
  if (!restaurantWithSameNameSnapshot.empty) {
    throw new functions.https.HttpsError('failed-precondition', 'Owner already has restaurant with same name');  
  }
  
  const restaurant = new Restaurant(
    data.name,
    data.phoneNumber,
    data.imageURL,
    data.categories,
    context.auth!.uid,
    0,
    0,
    0
  )
  const docReference = await restaurantsCollection.add(restaurant)
  const documentSnapshot = await docReference.get()
  return dtoFromRestaurantDocument(documentSnapshot)
});

function applyRatingFilterOnDocReferenceIfPossible(
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

function applyPendingReplyFilterOnDocReferenceIfPossible(
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

function dtoFromRestaurantDocument(doc: FirebaseFirestore.DocumentSnapshot): any {
  return {
    ...doc.data(),
    id: doc.id,
    creationDate: doc.createTime?.seconds,
    modificationDate: doc.updateTime?.seconds,
  }
}