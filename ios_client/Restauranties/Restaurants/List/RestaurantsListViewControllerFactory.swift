//
//  RestaurantsListViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation
import Firebase

struct RestaurantsListViewControllerFactory {
    func makeForNormalUser(
        collectionReference: CollectionReference,
        user: User
    ) -> RestaurantsListViewController {
        let storyboard = UIStoryboard(name: "RestaurantsList", bundle: nil)
        let restaurantsListViewModel = RestaurantsListNormalUserViewModel(
            collectionReference: collectionReference,
            user: user
        )
        let viewController: RestaurantsListViewController? = storyboard.instantiateInitialViewController { coder in
            RestaurantsListViewController(coder: coder, viewModel: restaurantsListViewModel)
        }
        restaurantsListViewModel.view = viewController
        return viewController!
    }
}
