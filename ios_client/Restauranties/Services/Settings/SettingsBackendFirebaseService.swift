//
//  SettingsBackendFirebaseService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine
import FirebaseAuth

final class SettingsBackendFirebaseService {
    let env: HTTPEnvironment
    let authenticator: HTTPAuthenticator

    private let servicePathPrefix = "/me"

    init(
        env: HTTPEnvironment,
        authenticator: HTTPAuthenticator
    ) {
        self.env = env
        self.authenticator = authenticator
    }
}

// MARK: - SettingsBackendService

extension SettingsBackendFirebaseService: SettingsBackendService {
    func getMyUser() -> UserAccount {
        guard let user = Auth.auth().currentUser else { fatalError() }
        let mapper = FirebaseUserToUserAccountMapper()
        return mapper.map(user: user, claims: [:])
    }
    
    func getCurrentUserRight() -> AnyPublisher<UserRight, Error> {
        guard let user = Auth.auth().currentUser else { fatalError() }
        return Future { promise in
            user.getIDTokenResult(forcingRefresh: true) { result, error in
                if let error = error {
                    return promise(.failure(error))
                }
                guard let result = result else { fatalError() }
                switch UserRight(claims: result.claims) {
                case .admin: promise(.success(.admin))
                case .restaurantOwner: promise(.success(.restaurantOwner))
                case .rater: promise(.success(.rater))
                case .unknown: fatalError()
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func changeUserRightToOwner() -> AnyPublisher<Void, Error> {
        changeRight(path: "/becomeOwner")
    }
    
    func changeUserRightToAdmin() -> AnyPublisher<Void, Error> {
        changeRight(path: "/becomeAdmin")
    }
    
    func changeUserRightToRater() -> AnyPublisher<Void, Error> {
        changeRight(path: "/becomeRater")
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: - Private Methods

extension SettingsBackendFirebaseService {
    private func changeRight(path: String) -> AnyPublisher<Void, Error> {
        let urlRequest = url(
            httpMethod: .post,
            path: servicePathPrefix + path
        )

        return URLSession
            .shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().voidOrError(data: $0.data, response: $0.response) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
