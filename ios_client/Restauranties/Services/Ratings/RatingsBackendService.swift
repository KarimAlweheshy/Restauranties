//
//  RatingsBackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/27/20.
//

import Foundation
import Combine

protocol RatingsBackendService: BackendService {
    func getRatings(
        restaurantID: String,
        completionHandler: @escaping (Result<[Rating], Error>) -> Void
    ) -> AnyCancellable

    func reply(
        ratingID: String,
        reply: String,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable

    func delete(
        ratingID: String,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable
}
