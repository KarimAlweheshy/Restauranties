//
//  RestaurantService.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation
import SotoDynamoDB

enum RestaurantServiceError: Error {
    case restaurantNotFound
}

public final class RestaurantService {
    let db: DynamoDB
    let tableName: String

    public init(db: DynamoDB, tableName: String) {
        self.db = db
        self.tableName = tableName
    }

    // Get Restaurants List
    public func getAllRestaurants() -> EventLoopFuture<[Restaurant]> {
        let input = DynamoDB.ScanInput(tableName: tableName)
        return db.scan(input).flatMapThrowing { output -> [Restaurant] in
            guard let items = output.items else { return [] }
            return try items.compactMap { item -> Restaurant in
                try DynamoDBDecoder().decode(Restaurant.self, from: item)
            }
        }
    }

    // Get Single Restaurant Item
    public func getRestaurant(id: String) -> EventLoopFuture<Restaurant> {
        let key = DynamoDB.AttributeValue.s(id)
        let input = DynamoDB.GetItemInput(key: ["id": key], tableName: tableName)

        return db.getItem(input).flatMapThrowing { output -> Restaurant in
            guard let item = output.item else { throw RestaurantServiceError.restaurantNotFound }
            return try DynamoDBDecoder().decode(Restaurant.self, from: item)
        }
    }

    // Create Restaurant
    public func createTodo(restaurant: Restaurant) -> EventLoopFuture<Restaurant> {
        var restaurant = restaurant
        let currentDate = Date()

        restaurant.updatedAt = currentDate
        restaurant.createdAt = currentDate

        let input = DynamoDB.PutItemCodableInput(item: restaurant, tableName: tableName)

        return db.putItem(input).map { (_) -> Restaurant in
            restaurant
        }
    }

    // Update Restaurant
    public func update(_ restaurant: Restaurant) -> EventLoopFuture<Restaurant> {
        var restaurant = restaurant

        restaurant.updatedAt = Date()

        let input = DynamoDB.UpdateItemCodableInput(
            key: [],
            tableName: tableName,
            updateItem: restaurant
        )

        return db.updateItem(input).flatMap { (output)  in
            self.getRestaurant(id: restaurant.id)
         }
    }

    // Delete Restaurant
    public func deleteRestaurant(id: String) -> EventLoopFuture<Void> {
        let input = DynamoDB.DeleteItemInput(
            key: ["id": DynamoDB.AttributeValue.s(id)],
            tableName: tableName
        )

        return db.deleteItem(input).map { _ in }
    }
}
