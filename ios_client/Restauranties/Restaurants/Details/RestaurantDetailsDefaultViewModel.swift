//
//  RestaurantDetailsDefaultViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation
import Firebase
import Combine

final class RestaurantDetailsDefaultViewModel {
    weak var view: RestaurantDetailsView?
    private let userRight: UserRight
    private let restaurantsService: RestaurantsBackendService
    private var restaurant: Restaurant
    private var ratings = [Rating]()
    private var disposables = Set<AnyCancellable>()

    init(
        restaurantsService: RestaurantsBackendService,
        restaurant: Restaurant,
        userRight: UserRight
    ) {
        self.restaurantsService = restaurantsService
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
        let viewModel = RatingFormRatingViewModel(restaurant: restaurant)
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
        let callable = Functions.functions().httpsCallable("replyToRating")
        let rating = ratings[indexPath.row]
        callable.call(["id": rating.id, "reply": reply]) { [weak self] result, error in
            guard let self = self, error == nil else { return }
            self.refresh()
        }
    }

    func didTapDeleteRating(at indexPath: IndexPath) {
        let callable = Functions.functions().httpsCallable("deleteRating")
        let rating = ratings[indexPath.row]
        callable.call(["id": rating.id]) { [weak self] result, error in
            guard let self = self, error == nil else { return }
            self.refresh()
        }
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
        let callable = Functions.functions().httpsCallable("restaurantRatings")
        callable.call(["restaurantID": restaurant.id]) { [weak self] result, error in
            guard let self = self else { return }
            defer {
                self.view?.showLoading(false)
                self.view?.reload()
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard
                let data = result?.data,
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
                let ratings = try? decoder.decode([Rating].self, from: jsonData)
            else { return self.ratings = [] }
            self.ratings = ratings
        }
    }

    private func refreshRestaurant() {
        let cancellable = restaurantsService.restaurantDetails(restaurantID: restaurant.id) { [weak self] result in
            guard let self = self else { return }
            defer { self.view?.reload() }
            guard let restaurant = try? result.get() else { return }
            self.restaurant = restaurant
        }
        disposables.insert(cancellable)
    }
}
