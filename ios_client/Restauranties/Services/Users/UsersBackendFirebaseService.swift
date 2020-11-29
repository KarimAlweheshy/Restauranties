//
//  UsersBackendFirebaseService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/27/20.
//

import Foundation
import Combine
import FirebaseAuth

final class UsersBackendFirebaseService {
    let env: HTTPEnvironment
    let authenticator: HTTPAuthenticator

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private let servicePathPrefix = "/users"

    init(
        env: HTTPEnvironment,
        authenticator: HTTPAuthenticator
    ) {
        self.env = env
        self.authenticator = authenticator
    }
}

// MARK: - UsersBackendService

extension UsersBackendFirebaseService: UsersBackendService {
    func delete(
        user: UserAccount,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        let urlRequest = url(
            httpMethod: .delete,
            path: servicePathPrefix + "/" + user.uid
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

    func getUsers(
        completionHandler: @escaping (Result<[UserAccount], Error>) -> Void
    ) -> AnyCancellable {
        let urlRequest = url(
            httpMethod: .get,
            path: servicePathPrefix
        )
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryCompactMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .decode(type: [UserAccount].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionHandler(.failure(error))
                }
            }, receiveValue: { users in
                completionHandler(.success(users))
            })
    }
}
