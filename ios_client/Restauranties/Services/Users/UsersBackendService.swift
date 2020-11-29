//
//  UsersBackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/27/20.
//

import Foundation
import Combine

protocol UsersBackendService: BackendService {
    func getUsers() -> AnyPublisher<[UserAccount], Error>
    func delete(user: UserAccount) -> AnyPublisher<Void, Error>
}
