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
        let viewController = storyboard.instantiateInitialViewController { coder -> RestaurantFormViewController? in
            RestaurantFormViewController(coder: coder, viewModel: NewRestaurantFormViewModel())
        }
        return viewController!
    }

    func makeEditRestaurant(_ restaurant: Restaurant) -> RestaurantFormViewController {
        let storyboard = UIStoryboard(name: "RestaurantForm", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController { coder -> RestaurantFormViewController? in
            RestaurantFormViewController(coder: coder, viewModel: EditRestaurantFormViewModel(restaurant: restaurant))
        }
        return viewController!
    }
}
