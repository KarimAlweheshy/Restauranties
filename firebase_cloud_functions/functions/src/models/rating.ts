import * as admin from 'firebase-admin'

export default class Rating {
    visitDate: admin.firestore.Timestamp
    restaurantID: string
    ownerID: string
    stars: number
    comment: string
    reply: string | null

    constructor(
        visitDate: admin.firestore.Timestamp,
        restaurantID: string,
        ownerID: string,
        stars: number,
        comment: string,
        reply: string | null
    ) {
        this.visitDate = visitDate
        this.restaurantID = restaurantID
        this.ownerID = ownerID
        this.stars = stars
        this.comment = comment
        this.reply = reply
    }
}