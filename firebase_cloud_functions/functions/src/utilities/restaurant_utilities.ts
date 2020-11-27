import Restaurant from '../models/restaurant'

export function verifyRestaurantKeysAndValues(restaurant: Restaurant) {
    return restaurant.name !== undefined && restaurant.name.length > 2 
}