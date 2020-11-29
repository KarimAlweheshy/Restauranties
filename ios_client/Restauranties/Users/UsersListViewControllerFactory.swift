//
//  UsersListViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit

struct UsersListViewControllerFactory {
    func make() -> UsersListViewController {
        let storyboard = UIStoryboard(name: "UsersList", bundle: nil)
        let service = 
        let viewController = storyboard.instantiateInitialViewController { coder -> UsersListViewController? in
            UsersListViewController(coder: coder, service: service)
        }
        return viewController!
    }
}
