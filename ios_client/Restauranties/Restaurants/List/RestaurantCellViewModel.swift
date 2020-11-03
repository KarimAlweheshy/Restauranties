//
//  RestaurantCellViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation

protocol RestaurantCellViewModel {
    func configure(cell: RestaurantListCell)
}

final class RestaurantCellNormalViewModel {

}

// MARK: - RestaurantCellViewModel
extension RestaurantCellNormalViewModel: RestaurantCellViewModel {
    func configure(cell: RestaurantListCell) {
        
    }
}
