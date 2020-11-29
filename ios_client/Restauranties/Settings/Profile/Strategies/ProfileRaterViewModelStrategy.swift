//
//  ProfileRaterViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

struct ProfileRaterViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS: (SettingsBackendService) -> AnyPublisher<Void, Error> = {
        $0.changeUserRightToOwner()
    }
    let changeUserRightButtonText = "Become Restaurant Owner"
    let isChangeUserRightContainerHidden = false
    let userType = "Rater"
}
