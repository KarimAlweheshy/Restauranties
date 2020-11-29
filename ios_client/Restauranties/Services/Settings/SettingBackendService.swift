//
//  SettingBackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

protocol SettingsBackendService: BackendService {
    func getMyUser() -> UserAccount

    func getCurrentUserRight() -> AnyPublisher<UserRight, Error>
    func changeUserRightToOwner() -> AnyPublisher<Void, Error>
    func changeUserRightToAdmin() -> AnyPublisher<Void, Error>
    func changeUserRightToRater() -> AnyPublisher<Void, Error>

    func signOut() throws
}
