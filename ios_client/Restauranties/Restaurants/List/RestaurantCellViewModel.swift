//
//  RestaurantCellViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation

protocol RestaurantCellViewModel {
    var hashValue: Int { get }
    func configure(cell: RestaurantListCell)
}
