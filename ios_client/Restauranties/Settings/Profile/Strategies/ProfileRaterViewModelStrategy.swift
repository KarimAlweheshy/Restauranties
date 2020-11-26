//
//  ProfileRaterViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation

struct ProfileRaterViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS = SettingsBackendService.changeUserRightToOwner
    let changeUserRightButtonText = "Become Restaurant Owner"
    let isChangeUserRightContainerHidden = false
    let userType = "Rater"
}
