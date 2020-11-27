import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
  
export function verifyAuth(context: functions.https.CallableContext) {
    if (!context.auth?.uid) {
      throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }
}
  
export async function verifyIsAdminUser(claims: {[key: string]: any} | null) {
    if (!isAdminUser(claims)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Restaurant Owner is allowed to access such calls');
    }
}
  
export async function verifyIsRaterUser(claims: {[key: string]: any} | null) {
    if (isAdminUser(claims) || isRestaurantOwnerUser(claims)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Rater is allowed to access such calls');
    }
}

export async function verifyIsNotOwner(claims: {[key: string]: any} | null) {
  if (isRestaurantOwnerUser(claims)) {
    throw new functions.https.HttpsError('failed-precondition', 'Owner is not allowed to access this call');
  }
}
  
export async function verifyIsRestaurantOwnerUser(claims: {[key: string]: any} | null) {
    if (!isRestaurantOwnerUser(claims)) {
      throw new functions.https.HttpsError('failed-precondition', 'Only Admin is allowed to access such calls');
    }
}

export function isAdminUser(claims: {[key: string]: any} | null): boolean {
    return claims?.admin === true
}
  
export function isRestaurantOwnerUser(claims: {[key: string]: any} | null): boolean {
    return claims?.owner === true
}

export async function findUser(auth: admin.auth.Auth, uid: string) {
  try {
    return await auth.getUser(uid);
  } catch (error) {
    throw new functions.https.HttpsError('failed-precondition', 'User with uid ' + uid + ' does not exist');  
  }
}