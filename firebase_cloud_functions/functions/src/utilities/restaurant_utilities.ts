import Restaurant from '../models/restaurant'

export function verifyRestaurantKeysAndValues(restaurant: Restaurant) {
    return restaurant.name && restaurant.name.length > 2 
}