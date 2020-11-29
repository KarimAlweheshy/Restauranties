//
//  RestaurantDetailsDefaultViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation
import UIKit
import Combine

final class RestaurantDetailsDefaultViewModel {
    weak var view: RestaurantDetailsView?
    private let userRight: UserRight
    private let restaurantsService: RestaurantsBackendService
    private let ratingsService: RatingsBackendService

    private var restaurant: Restaurant
    private var ratings = [Rating]()
    private var disposables = Set<AnyCancellable>()

    init(
        restaurantsService: RestaurantsBackendService,
        ratingsService: RatingsBackendService,
        restaurant: Restaurant,
        userRight: UserRight
    ) {
        self.restaurantsService = restaurantsService
        self.ratingsService = ratingsService
        self.restaurant = restaurant
        self.userRight = userRight
    }
}

// MARK: - RestaurantDetailsViewModel

extension RestaurantDetailsDefaultViewModel: RestaurantDetailsViewModel {
    func viewDidLoad() {
        refresh()
    }

    func ratingFormViewModel() -> RatingFormViewModel {
        let viewModel = RatingFormRatingViewModel(
            service: ratingsService,
            restaurant: restaurant
        )
        viewModel.delegate = self
        return viewModel
    }

    func restaurantAverageRatingsString() -> String {
        guard restaurant.totalRatings > 0 else { return "Not enough data to show"}
        let avgRating = String(format: "%.2f", restaurant.averageRating)
        return "\(avgRating)//5"
    }

    func restaurantTotalRatingsString() -> String {
        guard restaurant.totalRatings > 0 else { return "Not enough data to show"}
        return "\(restaurant.totalRatings)"
    }

    func restaurantName() -> String {
        "\(restaurant.name)"
    }

    func numberOfRatingCells() -> Int {
        ratings.count
    }

    func canDeleteRatings() -> Bool {
        userRight == .admin
    }
    
    func canShowRateButton() -> Bool {
        userRight == .rater
    }

    func didAddReplyForRating(reply: String, at indexPath: IndexPath) {
        let rating = ratings[indexPath.row]
        ratingsService
            .reply(ratingID: rating.id, reply: reply)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: self?.refresh()
                    case .failure: break
                    }
                }, receiveValue: { _ in }
            ).store(in: &disposables)
    }

    func didTapDeleteRating(at indexPath: IndexPath) {
        let rating = ratings[indexPath.row]
        ratingsService
            .delete(ratingID: rating.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: self?.refresh()
                    case .failure: break
                    }
                }, receiveValue: { _ in }
            ).store(in: &disposables)
    }

    func refresh() {
        refreshRatings()
        refreshRestaurant()
    }

    func ratingsSnapshot() -> NSDiffableDataSourceSnapshot<Int, RestaurantRatingCellViewModelWrapper> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RestaurantRatingCellViewModelWrapper>()
        snapshot.appendSections([0])
        let wrappers = ratings.compactMap { rating -> RestaurantRatingCellViewModelWrapper in
            let viewModel: RestaurantRatingCellViewModel = self.userRight == .restaurantOwner ? RestaurantRatingCellOwnerViewModel(rating: rating) : RestaurantRatingCellRaterViewModel(rating: rating)
            return RestaurantRatingCellViewModelWrapper(cellViewModel: viewModel)
        }
        snapshot.appendItems(wrappers, toSection: 0)
        return snapshot
    }
}

// MARK: - RatingFormViewModelDelegate

extension RestaurantDetailsDefaultViewModel: RatingFormRatingViewModelDelegate {
    func didFinish() {
        refresh()
        view?.popRateFormViewController()
    }
}

// MARK: - Private Methods

extension RestaurantDetailsDefaultViewModel {
    private func refreshRatings() {
        view?.showLoading(true)
        ratingsService
            .getRatings(restaurantID: restaurant.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure: self?.ratings = []
                    case .finished: break
                    }
                    self?.view?.showLoading(false)
                    self?.view?.reload()
                }, receiveValue: { [weak self] ratings in
                    self?.ratings = ratings
                }
            ).store(in: &disposables)
    }

    private func refreshRestaurant() {
        restaurantsService
            .restaurantDetails(restaurantID: restaurant.id)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.view?.reload()
                },
                receiveValue: { [weak self] restaurant in
                    self?.restaurant = restaurant
                }
            ).store(in: &disposables)
    }
}
