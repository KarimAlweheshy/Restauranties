//
//  RestaurantCellViewModelWrapper.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/15/20.
//

import Foundation

struct RestaurantCellViewModelWrapper: Hashable {
    let cellViewModel: RestaurantCellViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(cellViewModel.hashValue)
    }

    static func == (
        lhs: RestaurantCellViewModelWrapper,
        rhs: RestaurantCellViewModelWrapper
    ) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
