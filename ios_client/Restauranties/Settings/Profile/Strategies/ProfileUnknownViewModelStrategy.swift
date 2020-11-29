//
//  ProfileUnknownViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

struct ProfileUnknownViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS: (SettingsBackendService) -> AnyPublisher<Void, Error> = { _ in
        Future<Void, Error> { _ in }.eraseToAnyPublisher()
    }
    let changeUserRightButtonText = ""
    let isChangeUserRightContainerHidden = true
    let userType = "Unknown - Error"
}
