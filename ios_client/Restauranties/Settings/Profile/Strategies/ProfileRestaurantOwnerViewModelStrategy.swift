//
//  ProfileRestaurantOwnerViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation

struct ProfileRestaurantOwnerViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS = SettingsBackendService.changeUserRightToAdmin
    let changeUserRightButtonText = "Become Admin"
    let isChangeUserRightContainerHidden = false
    let userType = "Restaurant Owner"
}
