const functions = require("firebase-functions")
const admin = require("firebase-admin")
const userUtilities = require("./../utilities/user_utilities")

exports.getAllUsers = functions.https.onCall(async (_data, context) => {
    userUtilities.verifyAuth(context)
    await userUtilities.verifyIsAdminUser(admin, context.auth.uid)

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

exports.deleteUser = functions.https.onCall(async (data, context) => {
    userUtilities.verifyAuth(context)
    await userUtilities.verifyIsAdminUser(admin, context.auth.uid)

    if (!data.uid) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing uid in body');
    }

    if (userUtilities.isAdminUser(await findUser(admin, data.uid))) {
        throw new functions.https.HttpsError('failed-precondition', 'Cannot delete admin a user from API');
    }

    const user = userUtilities.findUser(admin, context.auth.uid)
    const db = admin.firestore()
    const batch = db.batch()

    if (userUtilities.isRestaurantOwnerUser(user)) {
        // Owner: delete all restaurants and restaurant ratings
        deleteAllRestaurantOwnerDocument(user, db, batch)
    } else {
        // Rater: delete all restaurant ratings
        deleteAllRaterOwnerDocument(user, db, batch)
    }

    try {
        await batch.commit()
        return await admin.auth().deleteUser(data.uid) 
    } catch (error) {
        throw new functions.https.HttpsError('failed-precondition', 'Error happened deleting the user');  
    }
});

async function deleteAllRestaurantOwnerDocument(user, db, batch) {
    const restaurantsQuery = db.collection("restaurant").where('ownerID', '==', user.uid)
    const restaurantsSnapshots = await restaurantsQuery.get()
    
    var restaurantIDs = new Array()
    restaurantsSnapshots.forEach(doc => { 
        restaurantIDs.push(doc.id)
        batch.delete(doc.ref) 
    })

    const ratingsQuery = db.collection("ratings").where('restaurantID', 'in', restaurantIDs)
    const ratingsSnapshots = await ratingsQuery.get()
    ratingsSnapshots.forEach(doc => batch.delete(doc.ref))
}

async function deleteAllRaterOwnerDocument(user, db, batch) {
    const ratingsQuery = db.collection("ratings").where('ownerID', '==', user.uid)
    const ratingsSnapshots = await ratingsQuery.get()
    ratingsSnapshots.forEach(doc => batch.delete(doc.ref))
}