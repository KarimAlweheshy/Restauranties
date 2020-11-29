//
//  UsersBackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/27/20.
//

import Foundation
import Combine

protocol UsersBackendService: BackendService {
    func getUsers(
        completionHandler: @escaping (Result<[UserAccount], Error>) -> Void
    ) -> AnyCancellable

    func delete(
        user: UserAccount,
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable
}
