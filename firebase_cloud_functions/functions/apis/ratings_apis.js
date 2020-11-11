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
    const ratingsCollection = db.collection("ratings").orderBy("creationDate")
    const snapshot = await ratingsCollection.where('restaurantID', '==', data.restaurantID).get()
    if (!snapshot.docs) { return [] }

    var ratings = snapshot.docs.map(doc => doc.data())
    const userIDs = ratings.map(rating => { return { uid: rating.ownerID } })
    const users = await admin.auth().getUsers(userIDs)
    ratings = ratings.map((rating, index) => {
        const user = users[index]
        rating.username = user.username
        rating.photoURL = user.photoURL
        return rating
    })

    return ratings
});

exports.addRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsRaterUser(context, context.auth.uid)

    ratingUtilities.verifyRatingKeysAndValues(data)
    const restaurantDocumentSnapshot = await restaurantDocumentSnapshot(data.restaurantID)
    const restaurant = restaurantDocumentSnapshot.data()
    const newTotalRatings = restaurant.totalRatings + 1
    const newAverageRating = ((restaurant.averageRating * restaurant.totalRatings) + rating.stars) / newTotalRatings
    await restaurantDocumentSnapshot.ref.update({ totalRatings: newTotalRatings, averageRating: newAverageRating })

    let rating = {
        visitDate: data.visitDate,
        restaurantID: data.restaurantID,
        ownerID: context.auth.uid,
        stars: data.stars,
        comment: data.comment,
        creationDate: admin.firestore.Timestamp.fromDate(new Date()),
        modificationDate: admin.firestore.Timestamp.fromDate(new Date())
    }

    const db = admin.firestore()
    const ratingsCollection = db.collection("ratings")
    const docReference = await ratingsCollection.add(rating)
    const documentSnapshot = await docReference.get()
    return documentSnapshot.data()
});

exports.deleteRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsAdminUser(context, context.auth.uid)

    const db = admin.firestore()
    const docReference = db.collection("ratings").doc(data.id)
    try {
        return await docReference.delete()
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

    return restaurantSnapshot.data()
}