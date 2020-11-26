//
//  ProfileUnknownViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

struct ProfileUnknownViewModelStrategy: ProfileViewModelStrategy {
    var changeRightsCallableHTTPS: (SettingsBackendService) -> (@escaping (Result<Void, Error>) -> Void) -> AnyCancellable = { _ in { _ in AnyCancellable({}) } }
    let changeUserRightButtonText = ""
    let isChangeUserRightContainerHidden = true
    let userType = "Unknown - Error"
}
