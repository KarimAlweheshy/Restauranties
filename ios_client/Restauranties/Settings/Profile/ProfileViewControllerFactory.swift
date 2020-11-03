//
//  ProfileViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit
import FirebaseAuth

struct ProfileViewControllerFactory {
    func makeViewController(user: User) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewModel = ProfileUnknownViewModel(user: user)
        let viewController: ProfileViewController? = storyboard.instantiateInitialViewController { coder in
            ProfileViewController(coder: coder, viewModel: viewModel)
        }
        return viewController!
    }
}
