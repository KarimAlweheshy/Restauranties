//
//  RestaurantsListViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit

struct RestaurantsListViewControllerFactory {
    func makeForRater() -> RestaurantsListViewController {
        let storyboard = UIStoryboard(name: "RestaurantsList", bundle: nil)
        let strategy = RestaurantsListViewModelRaterStratey()
        let restaurantsListViewModel = RestaurantsListDefaultViewModel(strategy: strategy)
        let viewController: RestaurantsListViewController? = storyboard.instantiateInitialViewController { coder in
            RestaurantsListViewController(coder: coder, viewModel: restaurantsListViewModel)
        }
        restaurantsListViewModel.view = viewController
        return viewController!
    }

    func makeForOwner() -> RestaurantsListViewController {
        let storyboard = UIStoryboard(name: "RestaurantsList", bundle: nil)
        let strategy = RestaurantsListViewModelOwnerStratey()
        let restaurantsListViewModel = RestaurantsListDefaultViewModel(strategy: strategy)
        let viewController: RestaurantsListViewController? = storyboard.instantiateInitialViewController { coder in
            RestaurantsListViewController(coder: coder, viewModel: restaurantsListViewModel)
        }
        restaurantsListViewModel.view = viewController
        return viewController!
    }
}
