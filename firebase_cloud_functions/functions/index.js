const { integrify } = require('integrify');
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

integrify({ config: { functions, db } });

// Rules will be loaded from "integrify.rules.js"
module.exports = integrify();

module.exports.becomeOwner = functions.https.onCall(async (_data, context) => {
  verifyAuth(context)
  await admin.auth().setCustomUserClaims(context.auth.uid, { owner: true });
  return { message: 'User is now an owner' };
});

module.exports.becomeRater = functions.https.onCall(async (_data, context) => {
  verifyAuth(context)
  await admin.auth().setCustomUserClaims(context.auth.uid, {});
  return { message: 'User is now a rater' };
});

module.exports.becomeAdmin = functions.https.onCall(async (_data, context) => {
  verifyAuth(context)
  await admin.auth().setCustomUserClaims(context.auth.uid, { admin: true });
  return { message: 'User is now an admin' };
});

module.exports.getAllUsers = functions.https.onCall(async (_data, context) => {
  verifyAuth(context)
  await verifyIsAdminUser(admin, context.auth.uid)
  
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

module.exports.deleteUser = functions.https.onCall(async (data, context) => {
  verifyAuth(context)
  await verifyIsAdminUser(admin, context.auth.uid)
  
  if (!data.uid) {
    throw new functions.https.HttpsError('failed-precondition', 'Missing uid in body');
  }
  
  if (isAdminUser(await findUser(admin, data.uid))) {
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

async function findUser(admin, uid) {
  try {
    return await admin.auth().getUser(uid);
  } catch (error) {
    throw new functions.https.HttpsError('failed-precondition', 'User with uid ' + uid + ' does not exist');  
  }
}

function verifyAuth(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }
}

async function verifyIsAdminUser(admin, uid) {
  const user = await findUser(admin, uid)
  if (!isAdminUser(user)) {
    throw new functions.https.HttpsError('failed-precondition', 'Only Admin is allowed to access such calls');
  }
}

function isAdminUser(user) {
  const claims = user.customClaims;
  return claims && claims['admin'] === true
}
