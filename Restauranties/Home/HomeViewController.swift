//
//  ViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import FirebaseAuth

final class HomeViewController: UITabBarController {
    private let user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [ProfileViewController.make(user: user)]
    }
}

// MARK: - Factory Methods

extension HomeViewController {
    static func make(user: User) -> HomeViewController {
        HomeViewController(user: user)
    }
}
