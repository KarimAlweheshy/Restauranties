//
//  RestaurantDetailsViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation

protocol RestaurantDetailsViewModel {
    func viewDidLoad()
    
    func restaurantAverageRatingsString() -> String
    func restaurantTotalRatingsString() -> String
    func restaurantName() -> String
    
    func numberOfRatingCells() -> Int
    func ratingCellViewModel(for indexPath: IndexPath) -> RestaurantRatingCellViewModel
}
