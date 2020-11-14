//
//  RestaurantDetailsViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation
import UIKit

protocol RestaurantDetailsViewModel: AnyObject {
    var view: RestaurantDetailsView? { get set }
    
    func viewDidLoad()
    func refresh()

    func didTapDeleteRating(at indexPath: IndexPath)
    func canDeleteRatings() -> Bool
    func canShowRateButton() -> Bool
    func restaurantAverageRatingsString() -> String
    func restaurantTotalRatingsString() -> String
    func restaurantName() -> String
    func ratingFormViewModel() -> RatingFormViewModel
    
    func ratingsSnapshot() -> NSDiffableDataSourceSnapshot<Int, RestaurantRatingCellViewModelWrapper>
}
