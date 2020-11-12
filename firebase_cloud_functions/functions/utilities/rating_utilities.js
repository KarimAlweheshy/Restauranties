const functions = require("firebase-functions");

exports.verifyRatingKeysAndValues = (rating) => {
    if (!rating.stars || !parseInt(rating.stars)) {
        throw new functions.https.HttpsError('failed-precondition', 'Rating has no value');
    }
    const stars = parseInt(rating.stars)
    if (stars < 1 || stars > 5) {
        throw new functions.https.HttpsError('failed-precondition', 'Rating value should be between 1 and 5');
    }

    const comment = rating.comment
    if (!comment || comment.length === 0) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing comment on rating');
    }

    const visitDate = rating.visitDate
    if (!visitDate || !parseInt(visitDate) || parseInt(visitDate) <= 0) {
        throw new functions.https.HttpsError('failed-precondition', 'Missing visit date');
    }
}
