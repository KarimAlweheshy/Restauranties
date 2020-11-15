//
//  RestaurantRatingCellRaterViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/15/20.
//

import Foundation

final class RestaurantRatingCellRaterViewModel {
    private let rating: Rating

    init(rating: Rating) {
        self.rating = rating
    }
}

// MARK: - RestaurantRatingCellViewModel

extension RestaurantRatingCellRaterViewModel: RestaurantRatingCellViewModel {
    var hashValue: Int {
        rating.hashValue
    }

    func configure(cell: RestaurantRatingCell) {
        cell.commentLabel.text = "Comment: \(rating.comment)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.dateOfVisitLabel.text = dateFormatter.string(from: rating.visitDate)
        cell.usernameLabel.text = rating.username
        cell.userImageView.image = ImageWithInitialsGenerator().generate(for: rating.username)
        cell.ratingLabel.text = "Rating: \(rating.stars)\\5"
        if let reply = rating.reply {
            cell.replyLabel.text = "Reply: \(reply)"
        } else {
            cell.replyLabel.text = "No reply yet"
        }
        cell.replyButton.isHidden = true
    }
}
