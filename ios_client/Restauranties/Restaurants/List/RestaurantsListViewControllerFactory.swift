//
//  RestaurantsListViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit

struct RestaurantsListViewControllerFactory {
    private let service: RestaurantsBackendService

    init() {
        service = RestaurantsBackendFirebaseService(
            env: FirebaseReleaseHTTPEnvironment(),
            authenticator: FirebaseHTTPAuthenticator()
        )
    }

    func makeForRater() -> RestaurantsListViewController {
        let strategy = RestaurantsListViewModelRaterStratey(service: service)
        return makeViewController(strategy: strategy)
    }

    func makeForOwner() -> RestaurantsListViewController {
        let strategy = RestaurantsListViewModelOwnerStratey(service: service)
        return makeViewController(strategy: strategy)
    }

    func makeForAdmin() -> RestaurantsListViewController {
        let strategy = RestaurantsListViewModelAdminStratey(service: service)
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
