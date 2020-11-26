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
    
    func getCurrentUserRight(completionHandler: @escaping (Result<UserRight, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { fatalError() }
        user.getIDTokenResult(forcingRefresh: true) { result, error in
            guard let result = result else { return }
            switch UserRight(claims: result.claims) {
            case .admin: completionHandler(.success(.admin))
            case .restaurantOwner: completionHandler(.success(.restaurantOwner))
            case .rater: completionHandler(.success(.rater))
            case .unknown: fatalError()
            }
        }
    }
    
    func changeUserRightToOwner(
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        changeRight(path: "/becomeOwner", completionHandler: completionHandler)
    }
    
    func changeUserRightToAdmin(
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        changeRight(path: "/becomeAdmin", completionHandler: completionHandler)
    }
    
    func changeUserRightToRater(
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        changeRight(path: "/becomeRater", completionHandler: completionHandler)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: - Private Methods

extension SettingsBackendFirebaseService {
    private func changeRight(
        path: String,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable {
        let urlRequest = url(
            httpMethod: .post,
            path: servicePathPrefix + path
        )

        return URLSession
            .shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { try HTTPResponseParser().dataOrError(data: $0.data, response: $0.response) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { completion in
                switch completion {
                case .failure(let error): completionHandler(.failure(error))
                case .finished: break
                }
            } receiveValue: { output in
                completionHandler(.success(()))
            }
    }
}
