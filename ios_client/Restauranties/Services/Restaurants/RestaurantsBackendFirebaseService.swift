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
    func getAllRestaurants(
        filter: AllRestaurantsFilter?,
        completionHandler: @escaping RestaurantsCallback
    ) -> AnyCancellable {
        let queryItems = filter
            .map { URLQueryItem(name: "filter", value: "\($0.starsNumber)") }
            .map { [$0] }

        let urlRequest = url(
            httpMethod: .get,
            path: servicePathPrefix,
            queryItems: queryItems
        )

        return getRestaurants(from: urlRequest, completionHandler: completionHandler)
    }

    func getMyRestaurants(
        filter: MyRestaurantsFilter?,
        completionHandler: @escaping RestaurantsCallback
    ) -> AnyCancellable {
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

        return getRestaurants(from: urlRequest, completionHandler: completionHandler)
    }

    func createNewRestaurant(
        restaurant: Restaurant,
        completionHandler: @escaping RestaurantCallback
    ) -> AnyCancellable {
        fatalError()
    }

    func deleteRestaurant(
        restaurantID: String,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        fatalError()
    }
}

// MARK: - Private Methods
extension RestaurantsBackendFirebaseService {
    private func getRestaurants(
        from urlRequest: URLRequest,
        completionHandler: @escaping (Result<[Restaurant], Error>) -> Void
    ) -> AnyCancellable {
        URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .decode(type: [Restaurant].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionHandler(.failure(error))
                }
            }, receiveValue: { restaurants in
                completionHandler(.success(restaurants))
            })
    }
}
