import * as functions from 'firebase-functions'
import Rating from '../models/rating'

export function verifyRatingKeysAndValues(rating: Rating) {
    if (rating.stars < 1 || rating.stars > 5) {
        throw new functions.https.HttpsError('failed-precondition', 'Rating value should be between 1 and 5');
    }

    if (rating.comment.length === 0) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing comment on rating');
    }
}
