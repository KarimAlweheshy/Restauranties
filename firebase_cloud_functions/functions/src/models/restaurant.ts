export default class Restaurant {
    name: string
    phone: string
    imageURL: URL
    categories: string[]
    ownerID: string
    totalRatings: number
    averageRating: number
    noReplyCount: number

    constructor(
        name: string,
        phone: string,
        imageURL: URL,
        categories: string[],
        ownerID: string,
        totalRatings: number,
        averageRating: number,
        noReplyCount: number
    ) {
        this.name = name
        this.phone = phone
        this.imageURL = imageURL
        this.categories = categories
        this.ownerID = ownerID
        this.totalRatings = totalRatings
        this.averageRating = averageRating
        this.noReplyCount = noReplyCount
    }
}