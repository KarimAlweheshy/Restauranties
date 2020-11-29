//
//  ProfileRestaurantOwnerViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

struct ProfileRestaurantOwnerViewModelStrategy: ProfileViewModelStrategy {
    let changeRightsCallableHTTPS: (SettingsBackendService) -> AnyPublisher<Void, Error> = {
        $0.changeUserRightToAdmin()
    }
    let changeUserRightButtonText = "Become Admin"
    let isChangeUserRightContainerHidden = false
    let userType = "Restaurant Owner"
}
