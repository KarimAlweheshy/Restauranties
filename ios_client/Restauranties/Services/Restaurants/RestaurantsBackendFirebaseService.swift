//
//  RestaurantsBackendFirebaseService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation
import Combine

final class RestaurantsBackendFirebaseService {
    let env: HTTPEnvironment
    let authenticator: HTTPAuthenticator
    private let servicePathPrefix = "/restaurants"
    private let resParser = HTTPResponseParser()
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    init(
        env: HTTPEnvironment,
        authenticator: HTTPAuthenticator
    ) {
        self.env = env
        self.authenticator = authenticator
    }
}

// MARK: - RestaurantsBackendService

extension RestaurantsBackendFirebaseService: RestaurantsBackendService {
    func getAllRestaurants(filter: AllRestaurantsFilter?) -> AnyPublisher<[Restaurant], Error> {
        let queryItems = filter
            .map { URLQueryItem(name: "filter", value: "\($0.starsNumber)") }
            .map { [$0] }

        let urlRequest = url(
            httpMethod: .get,
            path: servicePathPrefix,
            queryItems: queryItems
        )

        return getRestaurants(from: urlRequest)
    }

    func getMyRestaurants(filter: MyRestaurantsFilter?) -> AnyPublisher<[Restaurant], Error> {
        let queryItems = filter
            .map { filter -> URLQueryItem in
                let value = filter == .hasPendingReplies ? "true" : "false"
                return URLQueryItem(name: "filter", value: value)
            }.map { [$0] }

        let urlRequest = url(
            httpMethod: .get,
            path: servicePathPrefix + "/mine",
            queryItems: queryItems
        )

        return getRestaurants(from: urlRequest)
    }

    func createNewRestaurant(name: String) -> AnyPublisher<Restaurant, Error> {
        let postBody = ["name": name]

        let urlRequest = url(
            httpMethod: .post,
            path: servicePathPrefix + "/",
            httpBody: try? JSONEncoder().encode(postBody)
        )

        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryCompactMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .decode(type: Restaurant.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func restaurantDetails(restaurantID: String) -> AnyPublisher<Restaurant, Error> {
        let urlRequest = url(
            httpMethod: .get,
            path: servicePathPrefix + "/" + restaurantID
        )

        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryCompactMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .decode(type: Restaurant.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func deleteRestaurant(restaurantID: String) -> AnyPublisher<Void, Error> {
        let urlRequest = url(
            httpMethod: .delete,
            path: servicePathPrefix + "/" + restaurantID
        )

        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().voidOrError(data: $0.data, response: $0.response) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Methods
extension RestaurantsBackendFirebaseService {
    private func getRestaurants(from urlRequest: URLRequest) -> AnyPublisher<[Restaurant], Error> {
        URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryCompactMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .decode(type: [Restaurant].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
