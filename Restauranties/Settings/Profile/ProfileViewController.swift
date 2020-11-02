//
//  ProfileViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController {
    static func make(user: User) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewController: ProfileViewController? = storyboard.instantiateInitialViewController { coder in
            ProfileViewController(coder: coder, user: user)
        }
        return viewController!
    }

    init?(coder: NSCoder, user: User) {
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @IBAction private func didTapSignOut() {
        try? Auth.auth().signOut()
    }
}
