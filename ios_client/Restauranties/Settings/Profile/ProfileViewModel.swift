//
//  ProfileViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation

protocol ProfileViewModel {
    var displayName: String? { get }
    var userEmail: String? { get }
    var isEmailVerified: Bool { get }
    var userType: String { get }
    var isChangeUserRightContainerHidden: Bool { get }
    var changeUserRightButtonText: String { get }

    func refreshedViewModel()
    func didTapChangeRightAction(completionHandler: @escaping () -> Void)
    func didTapSignOut()
}
