//
//  ProfileAdminViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation

struct ProfileAdminViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS = SettingsBackendService.changeUserRightToRater
    let changeUserRightButtonText = "Become Rater"
    let isChangeUserRightContainerHidden = false
    let userType = "Admin"
}
