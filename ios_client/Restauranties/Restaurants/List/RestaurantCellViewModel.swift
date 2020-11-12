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

struct RestaurantCellNormalViewModel {
    let restaurant: Restaurant
}

// MARK: - RestaurantCellViewModel
extension RestaurantCellNormalViewModel: RestaurantCellViewModel {
    func configure(cell: RestaurantListCell) {
        let avgRating = String(format: "%.2f", restaurant.averageRating)
        cell.averageRatingsLabel.text = "Rating: \(avgRating)/5.0"
        cell.nameLabel.text = restaurant.name
        cell.numberOfRatingsLabel.text = "Total ratings: \(restaurant.totalRatings)"
        if restaurant.totalRatings == 0 {
            cell.numberOfRatingsLabel.text = "Not enough data to show ratings"
            cell.averageRatingsLabel.isHidden = true
        }
        cell.restaurantImageView.image = ImageWithInitialsGenerator().generate(for: restaurant.name)
    }
}
