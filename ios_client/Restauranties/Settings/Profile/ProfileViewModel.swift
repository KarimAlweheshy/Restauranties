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
    var delegate: HomeViewControllerDelegate? { get set }
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

    func refreshedViewModel() {
        user.getIDTokenResult(forcingRefresh: true) { result, error in
            guard let result = result else { return }
            switch UserRight(claims: result.claims) {
            case .admin: delegate?.didChangeUserPermission(.admin)
            case .restaurantOwner: delegate?.didChangeUserPermission(.restaurantOwner)
            case .rater: delegate?.didChangeUserPermission(.rater)
            case .unknown: fatalError()
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
    weak var delegate: HomeViewControllerDelegate?

    let user: User
    let changeRightsCallableHTTPS = "becomeRater"
    let changeUserRightButtonText = "Become Rater"
    let isChangeUserRightContainerHidden = false
    let userType = "Admin"
}

struct ProfileRestaurantOwnerViewModel: ProfileViewModel {
    weak var delegate: HomeViewControllerDelegate?

    let user: User
    let changeRightsCallableHTTPS = "becomeAdmin"
    let changeUserRightButtonText = "Become Admin"
    let isChangeUserRightContainerHidden = false
    let userType = "Restaurant Owner"
}

struct ProfileRaterViewModel: ProfileViewModel {
    weak var delegate: HomeViewControllerDelegate?

    let user: User
    let changeRightsCallableHTTPS = "becomeOwner"
    let changeUserRightButtonText = "Become Restaurant Owner"
    let isChangeUserRightContainerHidden = false
    let userType = "Rater"
}

struct ProfileUnknownViewModel: ProfileViewModel {
    weak var delegate: HomeViewControllerDelegate?

    let user: User
    let changeRightsCallableHTTPS = ""
    let changeUserRightButtonText = ""
    let isChangeUserRightContainerHidden = true
    let userType = "Unknown - Error"
}
