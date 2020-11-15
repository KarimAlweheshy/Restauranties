//
//  RestaurantRatingCellViewModelWrapper.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/15/20.
//

import Foundation

struct RestaurantRatingCellViewModelWrapper: Hashable {
    let cellViewModel: RestaurantRatingCellViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(cellViewModel.hashValue)
    }

    static func == (
        lhs: RestaurantRatingCellViewModelWrapper,
        rhs: RestaurantRatingCellViewModelWrapper
    ) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
