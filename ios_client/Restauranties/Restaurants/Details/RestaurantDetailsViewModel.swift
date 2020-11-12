//
//  RestaurantDetailsViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation

protocol RestaurantDetailsViewModel: AnyObject {
    var view: RestaurantDetailsView? { get set }
    
    func viewDidLoad()
    
    func restaurantAverageRatingsString() -> String
    func restaurantTotalRatingsString() -> String
    func restaurantName() -> String
    func ratingFormViewModel() -> RatingFormViewModel
    
    func numberOfRatingCells() -> Int
    func ratingCellViewModel(for indexPath: IndexPath) -> RestaurantRatingCellViewModel
}
