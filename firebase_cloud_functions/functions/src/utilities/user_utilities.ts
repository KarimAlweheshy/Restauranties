import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
  
export function verifyAuth(context: functions.https.CallableContext) {
    if (!context.auth?.uid) {
      throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }
}
  
export async function verifyIsAdminUser(auth: admin.auth.Auth, uid: string) {
    const user = await findUser(auth, uid)
    if (!isAdminUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Restaurant Owner is allowed to access such calls');
    }
}
  
export async function verifyIsRaterUser(auth: admin.auth.Auth, uid: string) {
    const user = await findUser(auth, uid)
    if (isAdminUser(user) || isRestaurantOwnerUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Rater is allowed to access such calls');
    }
}

export async function verifyIsNotOwner(auth: admin.auth.Auth, uid: string) {
  const user = await findUser(auth, uid)
  if (isRestaurantOwnerUser(user)) {
    throw new functions.https.HttpsError('failed-precondition', 'Owner is not allowed to access this call');
  }
}
  
export async function verifyIsRestaurantOwnerUser(auth: admin.auth.Auth, uid: string) {
    const user = await findUser(auth, uid)
    if (!isRestaurantOwnerUser(user)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Admin is allowed to access such calls');
    }
}

export function isAdminUser(user: admin.auth.UserRecord): boolean {
    return user.customClaims?.admin === true
}
  
export function isRestaurantOwnerUser(user: admin.auth.UserRecord): boolean {
    return user.customClaims?.owner === true
}

export async function findUser(auth: admin.auth.Auth, uid: string) {
  try {
    return await auth.getUser(uid);
  } catch (error) {
    throw new functions.https.HttpsError('failed-precondition', 'User with uid ' + uid + ' does not exist');  
  }
}