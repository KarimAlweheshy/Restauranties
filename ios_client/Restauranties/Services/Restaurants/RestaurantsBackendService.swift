//
//  RestaurantsBackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation
import Combine

protocol RestaurantsBackendService: BackendService {
    func getAllRestaurants(filter: AllRestaurantsFilter?) -> AnyPublisher<[Restaurant], Error>
    func getMyRestaurants(filter: MyRestaurantsFilter?) -> AnyPublisher<[Restaurant], Error>
    func createNewRestaurant(name: String) -> AnyPublisher<Restaurant, Error>
    func restaurantDetails(restaurantID: String) -> AnyPublisher<Restaurant, Error>
    func deleteRestaurant(restaurantID: String) -> AnyPublisher<Void, Error>
}
