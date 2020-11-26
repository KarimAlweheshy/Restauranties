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

    func getCurrentUserRight(completionHandler: @escaping (Result<UserRight, Error>) -> Void)

    func changeUserRightToOwner(
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable

    func changeUserRightToAdmin(
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable

    func changeUserRightToRater(
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) -> AnyCancellable

    func signOut() throws
}
