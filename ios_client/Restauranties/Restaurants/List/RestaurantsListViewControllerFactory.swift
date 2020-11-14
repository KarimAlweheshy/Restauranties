//
//  RestaurantsListViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit

struct RestaurantsListViewControllerFactory {
    func makeForRater() -> RestaurantsListViewController {
        let strategy = RestaurantsListViewModelRaterStratey()
        return makeViewController(strategy: strategy)
    }

    func makeForOwner() -> RestaurantsListViewController {
        let strategy = RestaurantsListViewModelOwnerStratey()
        return makeViewController(strategy: strategy)
    }

    func makeForAdmin() -> RestaurantsListViewController {
        let strategy = RestaurantsListViewModelAdminStratey()
        return makeViewController(strategy: strategy)
    }
}

extension RestaurantsListViewControllerFactory {
    private func makeViewController(strategy: RestaurantsListViewModelStratey) -> RestaurantsListViewController {
        let storyboard = UIStoryboard(name: "RestaurantsList", bundle: nil)
        let restaurantsListViewModel = RestaurantsListDefaultViewModel(strategy: strategy)
        let viewController: RestaurantsListViewController? = storyboard.instantiateInitialViewController { coder in
            RestaurantsListViewController(coder: coder, viewModel: restaurantsListViewModel)
        }
        restaurantsListViewModel.view = viewController
        return viewController!
    }
}
