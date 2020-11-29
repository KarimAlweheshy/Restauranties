//
//  RatingFormViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/11/20.
//

import Foundation
import Combine

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

    private let service: RatingsBackendService
    private let restaurant: Restaurant

    private var stars = 5
    private var comment: String?
    private var visitDate = Date()
    private var disposables = Set<AnyCancellable>()

    init(
        service: RatingsBackendService,
        restaurant: Restaurant
    ) {
        self.service = service
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
        let cancellable = service
            .create(
                restaurantID: restaurant.id,
                visitDate: visitDate,
                comment: comment,
                stars: stars
            ).sink(
                receiveCompletion: { [weak delegate, weak view] completion in
                    switch completion {
                    case .finished: delegate?.didFinish()
                    case .failure: break
                    }
                    view?.showLoading(false)
                },receiveValue: { _ in }
            )
        disposables.insert(cancellable)
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
