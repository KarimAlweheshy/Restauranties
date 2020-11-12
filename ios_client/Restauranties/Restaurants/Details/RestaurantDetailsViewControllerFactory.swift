//
//  RestaurantDetailsViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import UIKit

final class RestaurantDetailsViewControllerFactory {
    func make(viewModel: RestaurantDetailsViewModel) -> RestaurantDetailsViewController {
        let storyboard = UIStoryboard(name: "RestaurantDetails", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController { coder -> RestaurantDetailsViewController? in
            RestaurantDetailsViewController(coder: coder, viewModel: viewModel)
        }
        viewModel.view = viewController
        return viewController!
    }
}
