import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import Rating from '../models/rating'
import Restaurant from '../models/restaurant'
import * as UserUtilities from '../utilities/user_utilities'
import * as RatingUtilities from './../utilities/rating_utilities'

export const restaurantRatings = functions.https.onCall(async (data, context) => {
    UserUtilities.verifyAuth(context)
    
    if (!data.restaurantID) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing restaurantID body arg');  
    }

    await assertRestaurantexists(data.restaurantID)
    
    const db = admin.firestore()
    const ratingsCollection = db.collection("ratings").orderBy("visitDate", 'desc')
    const snapshot = await ratingsCollection.where('restaurantID', '==', data.restaurantID).get()
    if (!snapshot.docs) { return [] }

    const ratingDocMaps = snapshot.docs.map(doc => { return { doc: doc, rating: doc.data() as Rating }})
    const userIDs = new Set(ratingDocMaps.map(ratingDocMap => { return { uid: ratingDocMap.rating.ownerID } }))
    const usersResult = await admin.auth().getUsers(Array.from(userIDs))
    if (usersResult.notFound.length > 0) {
        throw new functions.https.HttpsError('failed-precondition', 'Couldn\'t find all raters with ids ' + usersResult.notFound);  
    }
    const userMap = new Map()
    usersResult.users.map(user => userMap.set(user.uid, user))
    return ratingDocMaps.map(ratingDocMap => {
        const user = userMap.get(ratingDocMap.rating.ownerID)
        return {
            ...ratingDocMap.rating,
            username: user.displayName,
            photoURL: user.photoURL,
            creationDate: ratingDocMap.doc.createTime.seconds,
            modificationDate: ratingDocMap.doc.updateTime.seconds,
            visitDate: ratingDocMap.rating.visitDate.seconds,
        }
    })
});

export const addRating = functions.https.onCall(async (data, context) => {
    UserUtilities.verifyAuth(context)
    await UserUtilities.verifyIsRaterUser(admin.auth(), context.auth!.uid)

    RatingUtilities.verifyRatingKeysAndValues(data as Rating)
    await assertRestaurantexists(data.restaurantID)
    
    const visitDate = new admin.firestore.Timestamp(parseInt(data.visitDate), 0)
    
    if (visitDate.toDate().getTime() > new Date().getTime()) {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot add a rating in the future');  
    }
    
    const rating = {
        visitDate: new admin.firestore.Timestamp(parseInt(data.visitDate), 0),
        restaurantID: data.restaurantID,
        ownerID: context.auth?.uid,
        stars: data.stars,
        comment: data.comment,
        creationDate: admin.firestore.Timestamp.fromDate(new Date()),
        modificationDate: admin.firestore.Timestamp.fromDate(new Date()),
    }

    const db = admin.firestore()
    
    try {
        const newRatingDocRef = db.collection("ratings").doc()
        await db.runTransaction(async transaction => {
            const restaurantDocSnapshot = await transaction.get(db.collection("restaurants").doc(data.restaurantID));
            const restaurant = restaurantDocSnapshot.data() as Restaurant
            const newTotalRatings = restaurant.totalRatings + 1
            const newAverageRating = ((restaurant.averageRating * restaurant.totalRatings) + data.stars) / newTotalRatings
            const newTotalNoReply = restaurant.noReplyCount + 1
    
            transaction.update(restaurantDocSnapshot.ref, { totalRatings: newTotalRatings, averageRating: newAverageRating, noReplyCount: newTotalNoReply })
            transaction.create(newRatingDocRef, rating)
       })

        const newRating = await newRatingDocRef.get()
        return { id: newRating.id, ...newRating.data() }
    } catch (error) {
        console.error(error)
        throw new functions.https.HttpsError('failed-precondition', 'Error adding the new rating');  
    }
});

export const deleteRating = functions.https.onCall(async (data, context) => {
    UserUtilities.verifyAuth(context)
    await UserUtilities.verifyIsAdminUser(admin.auth(), context.auth!.uid)

    const db = admin.firestore()

    const ratingDocRef = db.collection("ratings").doc(data.id)
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
     } catch(error) {
        console.error(error)
        throw new functions.https.HttpsError('failed-precondition', 'Error happened deleting the rating');  
     }
});

export const replyToRating = functions.https.onCall(async (data, context) => {
    UserUtilities.verifyAuth(context)
    await UserUtilities.verifyIsRestaurantOwnerUser(admin.auth(), context.auth!.uid)

    const db = admin.firestore()

    if (!data.id) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing id argument');  
    }
    const ratingDocRef = db.collection("ratings").doc(data.id)
    const ratingSnapshot = await ratingDocRef.get()
    if (!ratingSnapshot.exists) {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot find rating with id ' + data.id);  
    }
    const rating = ratingSnapshot.data() as Rating

    const restaurantDocRef = db.collection("restaurants").doc(rating.restaurantID)
    const restaurantSnapshot = await restaurantDocRef.get()
    if (!restaurantSnapshot.exists) {
        throw new functions.https.HttpsError('failed-precondition', 'Failed to find restaurant with id ' + rating.restaurantID);  
    }
    const restaurant = restaurantSnapshot.data() as Restaurant

    if (restaurant.ownerID !== context.auth?.uid) {
        throw new functions.https.HttpsError('failed-precondition', 'User does not own this restaurant');  
    }

    if (rating.reply) {
        throw new functions.https.HttpsError('failed-precondition', 'Already replied to this rating');  
    }

    if (!data.reply || !data.reply.length) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing reply body param');  
    }

    try{
        await db.runTransaction(async transaction => {
            const doc = await transaction.get(restaurantDocRef);
            const noReplyCount = doc.data()?.noReplyCount - 1;
            transaction.update(restaurantSnapshot.ref, { noReplyCount: noReplyCount })
            transaction.update(ratingDocRef, { reply: data.reply })
       })
     } catch(error) {
        console.error(error)
        throw new functions.https.HttpsError('failed-precondition', 'Error happened updating the rating');  
     }
});

async function assertRestaurantexists(restaurantID: string) {
    const db = admin.firestore()
    const restaurantSnapshot = await db.collection("restaurants").doc(restaurantID).get()
    
    if (!restaurantSnapshot.exists) {
        throw new functions.https.HttpsError('failed-precondition', 'Restaurant does not exist');
    }
}