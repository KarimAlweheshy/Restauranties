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
    func delete(user: UserAccount) -> AnyPublisher<Void, Error> {
        let urlRequest = url(
            httpMethod: .delete,
            path: servicePathPrefix + "/" + user.uid
        )
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().voidOrError(data: $0.data, response: $0.response) }
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getUsers() -> AnyPublisher<[UserAccount], Error> {
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
    }
}
