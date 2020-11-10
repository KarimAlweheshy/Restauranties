const functions = require("firebase-functions");
const admin = require("firebase-admin");
const userUtilities = require("./../utilities/user_utilities");

exports.becomeOwner = functions.https.onCall(async (_data, context) => {
    userUtilities.verifyAuth(context)
    await admin.auth().setCustomUserClaims(context.auth.uid, { owner: true });
    return { message: 'User is now an owner' };
});

exports.becomeRater = functions.https.onCall(async (_data, context) => {
    userUtilities.verifyAuth(context)
    await admin.auth().setCustomUserClaims(context.auth.uid, {});
    return { message: 'User is now a rater' };
});

exports.becomeAdmin = functions.https.onCall(async (_data, context) => {
    userUtilities.verifyAuth(context)
    await admin.auth().setCustomUserClaims(context.auth.uid, { admin: true });
    return { message: 'User is now an admin' };
});