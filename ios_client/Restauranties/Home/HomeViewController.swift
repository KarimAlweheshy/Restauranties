//
//  ViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import Firebase

final class HomeViewController: UITabBarController {
    private let user: User
    private let collectionReference: CollectionReference

    init(user: User, collectionReference: CollectionReference) {
        self.user = user
        self.collectionReference = collectionReference
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            RestaurantsListViewController.make(collectionReference: collectionReference, user: user),
            ProfileViewController.make(user: user)
        ]
    }
}

// MARK: - Factory Methods

extension HomeViewController {
    static func make(user: User, collectionReference: CollectionReference) -> HomeViewController {
        HomeViewController(user: user, collectionReference: collectionReference)
    }
}
