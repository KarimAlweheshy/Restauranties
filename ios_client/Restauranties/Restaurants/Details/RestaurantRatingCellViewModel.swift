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
        cell.commentLabel.text = "Comment: \(rating.comment)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.dateOfVisitLabel.text = dateFormatter.string(from: rating.visitDate)
        cell.usernameLabel.text = rating.username
        cell.userImageView.image = ImageWithInitialsGenerator().generate(for: rating.username)
        cell.ratingLabel.text = "Rating: \(rating.stars)\\5"
    }
}
