//
//  ViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import Firebase

protocol HomeViewControllerDelegate: AnyObject {
    func didChangeUserPermission(_ right: UserRight)
}

final class HomeViewController: UITabBarController {
    private let user: User
    private var userRight: UserRight?

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didChangeUserPermission(.rater)
    }
}

// MARK: - HomeViewControllerDelegate

extension HomeViewController: HomeViewControllerDelegate {
    func didChangeUserPermission(_ right: UserRight) {
        guard self.userRight != right else { return }
        self.userRight = right
        let profileViewController = ProfileViewControllerFactory()
            .makeViewController(
                user: user,
                right: right,
                delegate: self
            )
        switch right {
        case .admin:
            let factory = RestaurantsListViewControllerFactory()
            let allRestaurantsList = factory.makeForAdmin()
            viewControllers = [
                UINavigationController(rootViewController: allRestaurantsList),
                UINavigationController(rootViewController: UsersListViewControllerFactory().make()),
                profileViewController
            ]
        case .rater:
            let factory = RestaurantsListViewControllerFactory()
            let allRestaurantsList = factory.makeForRater()
            viewControllers = [
                UINavigationController(rootViewController: allRestaurantsList),
                profileViewController
            ]
        case .restaurantOwner:
            let factory = RestaurantsListViewControllerFactory()
            let myRestaurantsList = factory.makeForOwner()
            viewControllers = [
                UINavigationController(rootViewController: myRestaurantsList),
                profileViewController
            ]
        case .unknown:
            viewControllers = [
                profileViewController
            ]
        }
        profileViewController.loadViewIfNeeded()
        selectedViewController = viewControllers?.last
    }
}

// MARK: - Factory Methods

extension HomeViewController {
    static func make(user: User) -> HomeViewController {
        HomeViewController(user: user)
    }
}
