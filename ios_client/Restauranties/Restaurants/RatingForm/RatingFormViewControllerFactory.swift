//
//  RatingFormViewControllerFactory.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/11/20.
//

import UIKit

final class RatingFormViewControllerFactory {
    func make(viewModel: RatingFormViewModel) -> RatingFormViewController {
        let storyboard = UIStoryboard(name: "RatingForm", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController { coder -> RatingFormViewController? in
            RatingFormViewController(coder: coder, viewModel: viewModel)
        }
        return viewController!
    }
}
