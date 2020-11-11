const functions = require("firebase-functions");
  
const verifyAuth = (context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }
}
  
const verifyIsAdminUser = async (admin, uid) => {
    const user = await findUser(admin, uid)
    if (!isAdminUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Restaurant Owner is allowed to access such calls');
    }
}
  
const verifyIsRaterUser = async (admin, uid) => {
    const user = await findUser(admin, uid)
    if (isAdminUser(user) || isRestaurantOwnerUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Rater is allowed to access such calls');
    }
}
  
const verifyIsRestaurantOwnerUser = async (admin, uid) => {
    const user = await findUser(admin, uid)
    if (!isRestaurantOwnerUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Admin is allowed to access such calls');
    }
}

const isAdminUser = (user) => {
    const claims = user.customClaims;
    return claims && claims['admin'] === true
}
  
const isRestaurantOwnerUser = (user) => {
    const claims = user.customClaims;
    return claims && claims['owner'] === true
}

const findUser = async (admin, uid) => {
  try {
    return await admin.auth().getUser(uid);
  } catch (error) {
    throw new functions.https.HttpsError('failed-precondition', 'User with uid ' + uid + ' does not exist');  
  }
}

exports.verifyIsAdminUser = verifyIsAdminUser
exports.isAdminUser = isAdminUser
exports.verifyIsRestaurantOwnerUser = verifyIsRestaurantOwnerUser
exports.isRestaurantOwnerUser = isRestaurantOwnerUser
exports.verifyIsRaterUser = verifyIsRaterUser
exports.verifyAuth = verifyAuth