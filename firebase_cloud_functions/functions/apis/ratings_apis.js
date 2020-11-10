const functions = require("firebase-functions")
const admin = require("firebase-admin")
const userUtilities = require("./../utilities/user_utilities")
const ratingUtilities = require("./../utilities/rating_utilities")

exports.restaurantRatings = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    
    if (!data.restaurant_id) {
        throw functions.https.HttpsError()
    }

    const { assertRestaurantExists } = await restaurantRef(data.restaurantID)
    assertRestaurantExists()
    
    const ratingsCollection = db.collection("ratings").orderBy("creationDate")
    const snapshot = await ratingsCollection.where('restaurantID', '==', data.restaurant_id).get()
    if (!snapshot.docs) { return [] }
    return snapshot.docs.map(doc => doc.data())
});

exports.addRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsRaterUser(context, context.auth.uid)

    ratingUtilities.verifyRatingKeysAndValues(data)
    const restaurantRef = await restaurantRef(data.restaurantID)

    let rating = {
        visitDate: data.visitDate,
        restaurantID: data.restaurantID,
        ownerID: context.auth.uid,
        stars: data.stars,
        comment: data.comment
    }
    const ratingsCollection = db.collection("ratings")
    const docReference = await ratingsCollection.add(rating)
    const documentSnapshot = await docReference.get()
    return documentSnapshot.data
});

exports.deleteRating = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    userUtilities.verifyIsAdminUser(context, context.auth.uid)

    const docReference = db.collection("ratings").where('uid', '==', data.uid)
    try {
        return await docReference.delete()
    } catch (error) {
        throw new functions.https.HttpsError('failed-precondition', 'Error happened deleting the rating');  
    }
});

async function restaurantRef(restaurantID) {
    const restaurantsCollection = db.collection("restaurants")
    const restaurantSnapshot = await restaurantsCollection.where('uid', '==', restaurantID).get()
    if (restaurantSnapshot.empty) {
        throw functions.https.HttpsError('failed-precondition', 'Restaurant does not exist');
    }

    if (restaurantSnapshot.size > 1) {
        throw functions.https.HttpsError('failed-precondition', 'Many restaurants exist for same uid');
    }

    return restaurantSnapshot.docs[0].ref
}