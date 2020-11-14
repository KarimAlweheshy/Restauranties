const functions = require("firebase-functions")
const admin = require("firebase-admin")
const userUtilities = require("./../utilities/user_utilities")
const ratingUtilities = require("./../utilities/rating_utilities")

exports.restaurantRatings = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    
    if (!data.restaurantID) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing restaurantID body arg');  
    }

    const _assertRestaurantExists = await restaurantDocumentSnapshot(data.restaurantID)
    
    const db = admin.firestore()
    const ratingsCollection = db.collection("ratings").orderBy("visitDate", 'desc')
    const snapshot = await ratingsCollection.where('restaurantID', '==', data.restaurantID).get()
    if (!snapshot.docs) { return [] }

    var ratings = snapshot.docs.map(doc => { return { id: doc.id, ...doc.data() }})
    const userIDs = ratings.map(rating => { return { uid: rating.ownerID } })
    const usersResult = await admin.auth().getUsers(userIDs)
    if (usersResult.notFound.length > 0) {
        throw new functions.https.HttpsError('failed-precondition', 'Couldn\'t find all raters with ids ' + usersResult.notFound);  
    }
    var userMap = new Map()
    usersResult.users.map(user => userMap.set(user.uid, user))
    ratings = ratings.map(rating => {
        const user = userMap.get(rating.ownerID)
        rating.username = user.displayName
        rating.photoURL = user.photoURL
        rating.visitDate = rating.visitDate._seconds
        rating.creationDate = rating.creationDate._seconds
        rating.modificationDate = rating.modificationDate._seconds
        return rating
    })

    return ratings
});

exports.addRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsRaterUser(admin, context.auth.uid)

    ratingUtilities.verifyRatingKeysAndValues(data)
    const documentSnapshot = await restaurantDocumentSnapshot(data.restaurantID)
    const restaurant = documentSnapshot.data()
    const newTotalRatings = restaurant.totalRatings + 1
    const newAverageRating = ((restaurant.averageRating * restaurant.totalRatings) + data.stars) / newTotalRatings
    
    const visitDate = new admin.firestore.Timestamp(parseInt(data.visitDate), 0)
    
    if (visitDate.toDate().getTime() > new Date().getTime()) {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot add a rating in the future');  
    }
    
    let rating = {
        visitDate: new admin.firestore.Timestamp(parseInt(data.visitDate), 0),
        restaurantID: data.restaurantID,
        ownerID: context.auth.uid,
        stars: data.stars,
        comment: data.comment,
        creationDate: admin.firestore.Timestamp.fromDate(new Date()),
        modificationDate: admin.firestore.Timestamp.fromDate(new Date())
    }

    const db = admin.firestore()
    const batch = db.batch()

    const newRatingDocRef = db.collection("ratings").doc()
    batch.create(newRatingDocRef, rating)
    batch.update(documentSnapshot.ref, { totalRatings: newTotalRatings, averageRating: newAverageRating })
    
    try {
        await batch.commit()

        const newRating = await newRatingDocRef.get()
        return { id: newRating.id, ...newRating.data() }
    } catch (error) {
        throw new functions.https.HttpsError('failed-precondition', 'Error adding the new rating');  
    }
});

exports.deleteRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsAdminUser(admin, context.auth.uid)

    const ratingDocRef = db.collection("ratings").doc(data.id)
    const ratingSnapshot = await ratingDocRef.get()
    const rating = ratingSnapshot.data()

    const restaurantSnapshot = await restaurantDocumentSnapshot(data.restaurantID)
    const restaurant = restaurantSnapshot.data()
    const newTotalRatings = restaurant.totalRatings - 1
    const newAverageRating = ((restaurant.averageRating * restaurant.totalRatings) - rating.stars) / newTotalRatings

    const db = admin.firestore()
    const batch = db.batch()

    batch.delete(ratingDocRef)
    batch.update(restaurantSnapshot.ref, { totalRatings: newTotalRatings, averageRating: newAverageRating })

    try {
        return await batch.commit()
    } catch (error) {
        throw new functions.https.HttpsError('failed-precondition', 'Error happened deleting the rating');  
    }
});

async function restaurantDocumentSnapshot(restaurantID) {
    const db = admin.firestore()
    const restaurantSnapshot = await db.collection("restaurants").doc(restaurantID).get()
    
    if (restaurantSnapshot.empty) {
        throw new functions.https.HttpsError('failed-precondition', 'Restaurant does not exist');
    }

    return restaurantSnapshot
}