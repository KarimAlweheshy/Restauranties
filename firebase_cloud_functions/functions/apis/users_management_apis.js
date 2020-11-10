const functions = require("firebase-functions");
const admin = require("firebase-admin");
const userUtilities = require("./../utilities/user_utilities");

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

    // TODO: if owner, delete all restaurants in a transaction with user
    // TODO: if rater, delete all ratings in a transaction with user
    try {
        return await admin.auth().deleteUser(data.uid)  ;
    } catch (error) {
        throw new functions.https.HttpsError('failed-precondition', 'Error happened deleting the user');  
    }
});