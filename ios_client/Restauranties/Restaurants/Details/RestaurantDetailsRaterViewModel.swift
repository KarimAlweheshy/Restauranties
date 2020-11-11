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
    private let restaurant: Restaurant
    private var ratings = [Rating]()

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }
}

// MARK: - RestaurantDetailsViewModel

extension RestaurantDetailsRaterViewModel: RestaurantDetailsViewModel {
    func viewDidLoad() {
        Functions.functions().httpsCallable("restaurantRatings").call(["restaurantID": restaurant.id]) { [weak self] result, error in
            guard let self = self else { return }
            defer { self.view?.reload() }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard
                let data = result?.data,
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
                let restaurants = try? decoder.decode([Rating].self, from: jsonData)
            else { return self.ratings = [] }
            self.ratings = restaurants
        }
    }

    func restaurantAverageRatingsString() -> String {
        guard restaurant.totalRatings > 0 else { return "Not enough data to show"}
        return "\(restaurant.averageRating)"
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

    func ratingCellViewModel(for indexPath: IndexPath) -> RestaurantRatingCellViewModel {
        let rating = ratings[indexPath.row]
        return RestaurantRatingCellRaterViewModel(rating: rating)
    }
}
