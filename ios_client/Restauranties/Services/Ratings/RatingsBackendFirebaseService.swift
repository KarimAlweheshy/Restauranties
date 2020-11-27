//
//  RatingsBackendFirebaseService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/27/20.
//

import Foundation
import Combine
import FirebaseAuth

final class RatingsBackendFirebaseService {
    let env: HTTPEnvironment
    let authenticator: HTTPAuthenticator

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private let servicePathPrefix = "/ratings"

    init(
        env: HTTPEnvironment,
        authenticator: HTTPAuthenticator
    ) {
        self.env = env
        self.authenticator = authenticator
    }
}

// MARK: - RatingsBackendService

extension RatingsBackendFirebaseService: RatingsBackendService {
    func getRatings(
        restaurantID: String,
        completionHandler: @escaping (Result<[Rating], Error>) -> Void
    ) -> AnyCancellable {
        let urlRequest = url(
            httpMethod: .get,
            path: servicePathPrefix,
            queryItems: [URLQueryItem(name: "restaurant_id", value: restaurantID)]
        )
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryCompactMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .decode(type: [Rating].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionHandler(.failure(error))
                }
            }, receiveValue: { ratings in
                completionHandler(.success(ratings))
            })
    }

    func reply(
        ratingID: String,
        reply: String,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        let httpBody = ["reply": reply]
        let urlRequest = url(
            httpMethod: .post,
            path: servicePathPrefix + "/" + ratingID + "/reply",
            httpBody: try? JSONEncoder().encode(httpBody)
        )
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionHandler(.failure(error))
                }
            }, receiveValue: { _ in
                completionHandler(.success(()))
            })
    }

    func delete(
        ratingID: String,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        let urlRequest = url(
            httpMethod: .delete,
            path: servicePathPrefix + "/" + ratingID
        )
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionHandler(.failure(error))
                }
            }, receiveValue: { _ in
                completionHandler(.success(()))
            })
    }

    func create(
        restaurantID: String,
        visitDate: Date,
        comment: String,
        stars: Int,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        struct Body: Codable {
            let restaurantID: String
            let visitDate: TimeInterval
            let comment: String
            let stars: Int
        }

        let postBody = Body(
            restaurantID: restaurantID,
            visitDate: visitDate.timeIntervalSince1970,
            comment: comment,
            stars: stars
        )

        let urlRequest = url(
            httpMethod: .post,
            path: servicePathPrefix,
            httpBody: try? JSONEncoder().encode(postBody)
        )

        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionHandler(.failure(error))
                }
            }, receiveValue: { _ in
                completionHandler(.success(()))
            })
    }
}
