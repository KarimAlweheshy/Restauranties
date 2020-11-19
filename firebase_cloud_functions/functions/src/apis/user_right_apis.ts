import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import * as UserUtilities from '../utilities/user_utilities'

export const becomeOwner = functions.https.onCall(async (_data, context) => {
    UserUtilities.verifyAuth(context)
    await admin.auth().setCustomUserClaims(context.auth!.uid, { owner: true });
    return { message: 'User is now an owner' };
});

export const becomeRater = functions.https.onCall(async (_data, context) => {
    UserUtilities.verifyAuth(context)
    await admin.auth().setCustomUserClaims(context.auth!.uid, {});
    return { message: 'User is now a rater' };
});

export const becomeAdmin = functions.https.onCall(async (_data, context) => {
    UserUtilities.verifyAuth(context)
    await admin.auth().setCustomUserClaims(context.auth!.uid, { admin: true });
    return { message: 'User is now an admin' };
});