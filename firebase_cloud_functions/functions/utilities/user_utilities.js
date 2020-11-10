const functions = require("firebase-functions");

exports.findUser = async (admin, uid) => {
    try {
      return await admin.auth().getUser(uid);
    } catch (error) {
      throw new functions.https.HttpsError('failed-precondition', 'User with uid ' + uid + ' does not exist');  
    }
}
  
exports.verifyAuth = (context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }
}
  
exports.verifyIsAdminUser = async (admin, uid) => {
    const user = await findUser(admin, uid)
    if (!isAdminUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Restaurant Owner is allowed to access such calls');
    }
}
  
exports.verifyIsRaterUser = async (admin, uid) => {
    const user = await findUser(admin, uid)
    if (isAdminUser(user) || isRestaurantOwnerUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Rater is allowed to access such calls');
    }
}
  
exports.verifyIsRestaurantOwnerUser = async (admin, uid) => {
    const user = await findUser(admin, uid)
    if (!isRestaurantOwnerUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Admin is allowed to access such calls');
    }
}

exports.isAdminUser = (user) => {
    const claims = user.customClaims;
    return claims && claims['admin'] === true
}
  
exports.isRestaurantOwnerUser = (user) => {
    const claims = user.customClaims;
    return claims && claims['owner'] === true
}
