//
//  RatingsBackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/27/20.
//

import Foundation
import Combine

protocol RatingsBackendService: BackendService {
    func getRatings(restaurantID: String) -> AnyPublisher<[Rating], Error>
    func reply(ratingID: String, reply: String) -> AnyPublisher<Void, Error>
    func delete(ratingID: String) -> AnyPublisher<Void, Error>

    func create(
        restaurantID: String,
        visitDate: Date,
        comment: String,
        stars: Int
    ) -> AnyPublisher<Void, Error>
}
