//
//  RestaurantRatingCellViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation

protocol RestaurantRatingCellViewModel {
    var hashValue: Int { get }
    func configure(cell: RestaurantRatingCell)
}
