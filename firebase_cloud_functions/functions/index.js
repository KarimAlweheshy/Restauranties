const { integrify } = require('integrify');
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true })

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

module.exports.myRestaurants = functions.https.onCall(async (data, context) => {
  verifyAuth(context)
  await verifyIsRestaurantOwnerUser(admin, context.auth.uid)
  const restaurantsCollection = db.collection("restaurants").orderBy("modificationDate")
  const snapshot = await restaurantsCollection.where('ownerID', '==', context.auth.uid).get()
  if (!snapshot.docs) { return [] }
  return snapshot.docs.map(doc => rewriteTimestampToISO(doc.data()))
});

module.exports.allRestaurants = functions.https.onCall(async (data, context) => {
  verifyAuth(context)
  await verifyIsRaterUser(admin, context.auth.uid)
  const restaurantsCollection = db.collection("restaurants")
  const filteredRestaurantsCollection = applyRatingFilterOnDocReferenceIfPossible(restaurantsCollection, data)
  const snapshot = await filteredRestaurantsCollection.orderBy("modificationDate").get()
  if (!snapshot.docs) { return [] }
  return snapshot.docs.map(doc => rewriteTimestampToISO(doc.data()))
})

module.exports.addRestaurant = functions.https.onCall(async (data, context) => {
  verifyAuth(context)
  await verifyIsRestaurantOwnerUser(admin, context.auth.uid)
  verifyRestaurantKeysAndValues(data)
  const restaurantsCollection = db.collection("restaurants")

  const restaurantWithSameNameSnapshot = await restaurantsCollection.where('name', '==', data.name).get()
  const restaurantWithSameName = restaurantWithSameNameSnapshot.docs
  if (restaurantWithSameName.length > 0) {
    throw new functions.https.HttpsError('failed-precondition', 'Owner already has restaurant with same name');  
  }
  
  let restaurant = {
    name: data.name,
    phone: data.phoneNumber,
    imageURL: data.imageURL,
    categories: data.categories,
    ownerID: context.auth.uid,
    totalRatings: 0,
    averageRating: 0,
    creationDate: admin.firestore.Timestamp.fromDate(new Date()),
    modificationDate: admin.firestore.Timestamp.fromDate(new Date()),
  }
  const docReference = await restaurantsCollection.add(restaurant)
  const documentSnapshot = await docReference.get()
  return documentSnapshot.data
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
    throw new functions.https.HttpsError('failed-precondition', 'Only Restaurant Owner is allowed to access such calls');
  }
}

async function verifyIsRaterUser(admin, uid) {
  const user = await findUser(admin, uid)
  if (isAdminUser(user) || isRestaurantOwnerUser(user)) {
    throw new functions.https.HttpsError('failed-precondition', 'Only Rater is allowed to access such calls');
  }
}

async function verifyIsRestaurantOwnerUser(admin, uid) {
  const user = await findUser(admin, uid)
  if (!isRestaurantOwnerUser(user)) {
    throw new functions.https.HttpsError('failed-precondition', 'Only Admin is allowed to access such calls');
  }
}

function isAdminUser(user) {
  const claims = user.customClaims;
  return claims && claims['admin'] === true
}

function isRestaurantOwnerUser(user) {
  const claims = user.customClaims;
  return claims && claims['owner'] === true
}

function verifyRestaurantKeysAndValues(restaurant) {
  return restaurant.name && restaurant.name.length > 2 
}

function rewriteTimestampToISO(data) {
  data.creationDate = data.creationDate._seconds
  data.modificationDate = data.modificationDate._seconds
  return data
}

function applyRatingFilterOnDocReferenceIfPossible(docReference, data) {
  if (!data || !data.filter) {
    return docReference
  }
  if (!parseInt(data.filter)) {
    throw new functions.https.HttpsError('failed-precondition', 'Filter must be a whole number e.g. 1');  
  }
  if (parseInt(data.filter) > 5 || parseInt(data.filter) < 1) {
    throw new functions.https.HttpsError('failed-precondition', 'Filter must be between 1 (included) and 5 (included)');  
  }
  const filterRating = parseInt(data.filter)
  docReference = docReference.where('averageRating', '<=', filterRating)
  if (filterRating > 1) {
    docReference = docReference.where('averageRating', '>=', filterRating - 1)
  } else {
    // To exclude restaurants without ratings
    docReference = docReference.where('averageRating', '>', 0)
  }
  return docReference.orderBy('averageRating')
}