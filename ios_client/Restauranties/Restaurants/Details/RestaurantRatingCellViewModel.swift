//
//  RestaurantRatingCellViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
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

protocol RestaurantRatingCellViewModel {
    var hashValue: Int { get }
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
    var hashValue: Int {
        rating.id.hash
    }

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
