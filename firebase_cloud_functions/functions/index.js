const { integrify } = require('integrify');
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

integrify({ config: { functions, db } });

// Rules will be loaded from "integrify.rules.js"
module.exports = integrify();

module.exports.becomeOwner = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' + 'while authenticated.');
  }
  return admin.auth().setCustomUserClaims(context.auth.uid, {owner: true}).then(() => {
    return { message: 'User is now an owner' };
  });
});

module.exports.becomeRater = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' + 'while authenticated.');
  }
  return admin.auth().setCustomUserClaims(context.auth.uid, {}).then(() => {
    return { message: 'User is now a rater' };
  });
});

module.exports.becomeAdmin = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' + 'while authenticated.');
  }
  return admin.auth().setCustomUserClaims(context.auth.uid, {admin: true}).then(() => {
    return { message: 'User is now an admin' };
  });
});