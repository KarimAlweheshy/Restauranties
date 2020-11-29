//
//  ProfileViewModelStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

protocol ProfileViewModelStrategy {
    var userType: String { get }
    var isChangeUserRightContainerHidden: Bool { get }
    var changeUserRightButtonText: String { get }
    var changeRightsCallableHTTPS: (SettingsBackendService) -> AnyPublisher<Void, Error> { get }
}
