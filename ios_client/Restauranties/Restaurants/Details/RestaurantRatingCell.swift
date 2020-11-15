//
//  RestaurantRatingCell.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import UIKit

protocol RestaurantRatingCellDelegate: AnyObject {
    func didTapReplyButton(for cell: RestaurantRatingCell)
}

final class RestaurantRatingCell: UITableViewCell {
    weak var delegate: RestaurantRatingCellDelegate?

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    @IBOutlet var dateOfVisitLabel: UILabel!
    @IBOutlet var replyButton: UIButton!

    @IBAction private func didTapReplyButton() {
        delegate?.didTapReplyButton(for: self)
    }
}
