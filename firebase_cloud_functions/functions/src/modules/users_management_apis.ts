import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import * as UserUtilities from '../utilities/user_utilities'

export const getAllUsers = functions.https.onCall(async (_data, context) => {
    UserUtilities.verifyAuth(context)
    await UserUtilities.verifyIsAdminUser(admin.auth(), context.auth!.uid)

    const result = await admin.auth().listUsers();
    return result.users.map(user => {
        return { 
            username: user.displayName,
            photoURL: user.photoURL,
            creationDate: user.metadata.creationTime,
            claims: user.customClaims,
            isVerified: user.emailVerified,
            uid: user.uid,
            email: user.email,
        }
    });
});

export const deleteUser = functions.https.onCall(async (data, context) => {
    UserUtilities.verifyAuth(context)
    await UserUtilities.verifyIsAdminUser(admin.auth(), context.auth!.uid)

    if (!data.uid) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing uid in body');
    }

    const userID = data.uid
    const user = await UserUtilities.findUser(admin.auth(), userID)
    if (UserUtilities.isAdminUser(user)) {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot delete admin a user from API');
    }

    const db = admin.firestore()
    let batch = db.batch()

    try {
        // Rater: delete all restaurant ratings
        batch = await deleteAllRaterDocument(userID, db, batch)

        // Owner: delete all restaurants and restaurant ratings
        batch = await deleteAllRestaurantOwnerDocument(userID, db, batch)
        
        await batch.commit()
        return await admin.auth().deleteUser(userID) 
    } catch (error) {
        throw new functions.https.HttpsError('failed-precondition', 'Error happened deleting the user');  
    }
});

async function deleteAllRestaurantOwnerDocument(userID: string, db: FirebaseFirestore.Firestore, batch: FirebaseFirestore.WriteBatch) {
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

async function deleteAllRaterDocument(userID: string, db: FirebaseFirestore.Firestore, batch: FirebaseFirestore.WriteBatch) {
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