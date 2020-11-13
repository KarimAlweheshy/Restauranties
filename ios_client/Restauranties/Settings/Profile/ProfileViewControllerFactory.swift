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

        var viewModel: ProfileViewModel
        switch right {
        case .admin:
            viewModel = ProfileAdminViewModel(delegate: delegate, user: user)
        case .rater:
            viewModel = ProfileRaterViewModel(delegate: delegate, user: user)
        case .restaurantOwner:
            viewModel = ProfileRestaurantOwnerViewModel(delegate: delegate, user: user)
        case .unknown:
            viewModel = ProfileUnknownViewModel(delegate: delegate, user: user)
        }

        let viewController: ProfileViewController? = storyboard.instantiateInitialViewController { coder in
            ProfileViewController(coder: coder, viewModel: viewModel)
        }
        return viewController!
    }
}
