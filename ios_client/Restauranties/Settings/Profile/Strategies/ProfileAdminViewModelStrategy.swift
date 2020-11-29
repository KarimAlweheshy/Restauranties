//
//  ProfileAdminViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

struct ProfileAdminViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS: (SettingsBackendService) -> AnyPublisher<Void, Error> = {
        $0.changeUserRightToRater()
    }
    let changeUserRightButtonText = "Become Rater"
    let isChangeUserRightContainerHidden = false
    let userType = "Admin"
}
