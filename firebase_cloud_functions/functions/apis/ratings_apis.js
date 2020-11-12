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

    var ratings = snapshot.docs.map(doc => doc.data())
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
    const ratingsCollection = db.collection("ratings")
    const docReference = await ratingsCollection.add(rating)

    await documentSnapshot.ref.update({ totalRatings: newTotalRatings, averageRating: newAverageRating })
    const newDocumentSnapshot = await docReference.get()
    return newDocumentSnapshot.data()
});

exports.deleteRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsAdminUser(admin, context.auth.uid)

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

    return restaurantSnapshot
}