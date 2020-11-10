exports.verifyRestaurantKeysAndValues = (restaurant) => {
    return restaurant.name && restaurant.name.length > 2 
}
  
exports.rewriteTimestampToISO = (data) => {
    data.creationDate = data.creationDate._seconds
    data.modificationDate = data.modificationDate._seconds
    return data
}