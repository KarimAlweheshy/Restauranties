//
//  ProfileViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit
import FirebaseAuth

struct ProfileViewControllerFactory {
    func makeViewController(
        user: User,
        right: UserRight,
        delegate: HomeViewControllerDelegate?
    ) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)

        var strategy: ProfileViewModelStrategy
        switch right {
        case .admin:
            strategy = ProfileAdminViewModelStrategy()
        case .rater:
            strategy = ProfileRaterViewModelStrategy()
        case .restaurantOwner:
            strategy = ProfileRestaurantOwnerViewModelStrategy()
        case .unknown:
            strategy = ProfileUnknownViewModelStrategy()
        }

        let service = SettingsBackendFirebaseService(
            env: FirebaseReleaseHTTPEnvironment(),
            authenticator: FirebaseHTTPAuthenticator()
        )
        let viewModel = ProfileDefaultViewModel(
            strategy: strategy,
            settingsBackendService: service
        )
        let viewController: ProfileViewController? = storyboard.instantiateInitialViewController { coder in
            ProfileViewController(coder: coder, viewModel: viewModel)
        }

        viewModel.view = viewController
        viewModel.delegate = delegate
        return viewController!
    }
}
