//
//  RestaurantRatingCellViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation

protocol RestaurantRatingCellViewModel {
    func configure(cell: RestaurantRatingCell)
}

final class RestaurantRatingCellRaterViewModel {
    private let rating: Rating

    init(rating: Rating) {
        self.rating = rating
    }
}

// MARK: - RestaurantRatingCellViewModel

extension RestaurantRatingCellRaterViewModel: RestaurantRatingCellViewModel {
    func configure(cell: RestaurantRatingCell) {

    }
}
