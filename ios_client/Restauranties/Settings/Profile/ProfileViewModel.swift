//
//  ProfileViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation
import FirebaseAuth
import FirebaseFunctions

protocol ProfileViewModel {
    var user: User { get }
    var userType: String { get }
    var isChangeUserRightContainerHidden: Bool { get }
    var changeUserRightButtonText: String { get }
    var changeRightsCallableHTTPS: String { get }
}

extension ProfileViewModel {
    var displayName: String? { user.displayName}
    var userEmail: String? { user.email }
    var isEmailVerified: Bool { user.isEmailVerified }

    func refreshedViewModel(completionHandler: @escaping (ProfileViewModel) -> Void) {
        user.getIDTokenResult(forcingRefresh: true) { result, error in
            if let result = result {
                let isAdmin = result.claims["admin"] as? Bool == true
                let isOwner = result.claims["owner"] as? Bool == true
                completionHandler(
                    isAdmin
                        ? ProfileAdminViewModel(user: user)
                        : isOwner
                        ? ProfileRestaurantOwnerViewModel(user: user) as ProfileViewModel
                        : ProfileRaterViewModel(user: user) as ProfileViewModel
                )
            } else {
                completionHandler(ProfileUnknownViewModel(user: user))
            }
        }
    }

    func didTapChangeRightAction(completionHandler: @escaping () -> Void) {
        Functions.functions().httpsCallable(changeRightsCallableHTTPS).call([]) { _, _ in
            completionHandler()
        }
    }

    func didTapSignOut() {
        try? Auth.auth().signOut()
    }
}

struct ProfileAdminViewModel: ProfileViewModel {
    let user: User
    let changeRightsCallableHTTPS = "becomeRater"
    let changeUserRightButtonText = "Become Rater"
    let isChangeUserRightContainerHidden = false
    let userType = "Admin"
}

struct ProfileRestaurantOwnerViewModel: ProfileViewModel {
    let user: User
    let changeRightsCallableHTTPS = "becomeAdmin"
    let changeUserRightButtonText = "Become Admin"
    let isChangeUserRightContainerHidden = false
    let userType = "Restaurant Owner"
}

struct ProfileRaterViewModel: ProfileViewModel {
    let user: User
    let changeRightsCallableHTTPS = "becomeOwner"
    let changeUserRightButtonText = "Become Restaurant Owner"
    let isChangeUserRightContainerHidden = false
    let userType = "Rater"
}

struct ProfileUnknownViewModel: ProfileViewModel {
    let user: User
    let changeRightsCallableHTTPS = ""
    let changeUserRightButtonText = ""
    let isChangeUserRightContainerHidden = true
    let userType = "Unknown - Error"
}
