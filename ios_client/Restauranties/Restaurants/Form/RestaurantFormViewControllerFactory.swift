//
//  RestaurantFormViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import UIKit

struct RestaurantFormViewControllerFactory {
    func makeNewRestaurant() -> RestaurantFormViewController {
        let storyboard = UIStoryboard(name: "RestaurantForm", bundle: nil)
        let service = RestaurantsBackendFirebaseService(
            env: FirebaseReleaseHTTPEnvironment(),
            authenticator: FirebaseHTTPAuthenticator()
        )
        let viewModel = NewRestaurantFormViewModel(service: service)
        let viewController = storyboard.instantiateInitialViewController { coder -> RestaurantFormViewController? in
            RestaurantFormViewController(coder: coder, viewModel: viewModel)
        }
        viewModel.view = viewController
        return viewController!
    }

    func makeEditRestaurant(_ restaurant: Restaurant) -> RestaurantFormViewController {
        let storyboard = UIStoryboard(name: "RestaurantForm", bundle: nil)
        let viewModel = EditRestaurantFormViewModel(restaurant: restaurant)
        let viewController = storyboard.instantiateInitialViewController { coder -> RestaurantFormViewController? in
            RestaurantFormViewController(coder: coder, viewModel: viewModel)
        }
        viewModel.view = viewController
        return viewController!
    }
}
