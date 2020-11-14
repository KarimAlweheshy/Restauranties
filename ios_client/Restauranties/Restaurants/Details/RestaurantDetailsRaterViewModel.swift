//
//  RestaurantDetailsRaterViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation
import Firebase

final class RestaurantDetailsRaterViewModel {
    weak var view: RestaurantDetailsView?
    private let userRight: UserRight
    private var restaurant: Restaurant
    private var ratings = [Rating]()

    init(restaurant: Restaurant, userRight: UserRight) {
        self.restaurant = restaurant
        self.userRight = userRight
    }
}

// MARK: - RestaurantDetailsViewModel

extension RestaurantDetailsRaterViewModel: RestaurantDetailsViewModel {
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

    func didTapDeleteRating(at indexPath: IndexPath) {
        let callable = Functions.functions().httpsCallable("deleteRating")
        let rating = ratings[indexPath.row]
        callable.call(["id": rating.id]) { [weak self] result, error in
            guard let self = self, error == nil else { return }
            self.ratings.remove(at: indexPath.row)
            self.view?.reload()
        }
    }

    func ratingCellViewModel(for indexPath: IndexPath) -> RestaurantRatingCellViewModel {
        let rating = ratings[indexPath.row]
        return RestaurantRatingCellRaterViewModel(rating: rating)
    }

    func refresh() {
        refreshRatings()
        refreshRestaurant()
    }
}

// MARK: - RatingFormViewModelDelegate

extension RestaurantDetailsRaterViewModel: RatingFormRatingViewModelDelegate {
    func didFinish() {
        refresh()
        view?.popRateFormViewController()
    }
}

// MARK: - Private Methods

extension RestaurantDetailsRaterViewModel {
    private func refreshRatings() {
        view?.showLoading(true)
        Functions.functions().httpsCallable("restaurantRatings").call(["restaurantID": restaurant.id]) { [weak self] result, error in
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
        Functions.functions().httpsCallable("restaurantDetails").call(["restaurantID": restaurant.id]) { [weak self] result, error in
            guard let self = self else { return }
            defer { self.view?.reload() }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard
                let data = result?.data,
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
                let restaurant = try? decoder.decode(Restaurant.self, from: jsonData)
            else { return }
            self.restaurant = restaurant
        }
    }
}
