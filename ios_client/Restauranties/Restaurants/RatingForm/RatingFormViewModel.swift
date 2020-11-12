//
//  RatingFormViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/11/20.
//

import Foundation
import Firebase

protocol RatingFormRatingViewModelDelegate: AnyObject {
    func didFinish()
}

protocol RatingFormViewModel: AnyObject {
    var view: RatingFormView? { get set }
    
    func viewDidLoad()
    func didTapDone()
    func didChange(visitDate: Date)
    func didChange(comment: String)
    func didChange(stars: Int)
}

final class RatingFormRatingViewModel {
    weak var view: RatingFormView?
    weak var delegate: RatingFormRatingViewModelDelegate?

    private let restaurant: Restaurant

    private var stars = 5
    private var comment: String?
    private var visitDate = Date()

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }
}

// MARK: - RatingFormViewModel

extension RatingFormRatingViewModel: RatingFormViewModel {
    func viewDidLoad() {

    }

    func didTapDone() {
        guard
            let comment = comment,
            comment.count > 0
        else { return }
        view?.showLoading(true)
        Functions
            .functions()
            .httpsCallable("addRating")
            .call([
                "restaurantID": restaurant.id,
                "visitDate": visitDate.timeIntervalSince1970,
                "stars": stars,
                "comment": comment
            ]
            ) { [weak delegate, weak view] result, error in
                view?.showLoading(false)
                guard error == nil else { return }
                delegate?.didFinish()
            }
    }

    func didChange(stars: Int) {
        self.stars = stars + 1
    }

    func didChange(comment: String) {
        self.comment = comment
    }

    func didChange(visitDate: Date) {
        self.visitDate = visitDate
    }
}
