//
//  RestaurantsListViewModelRaterStratey.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation

final class RestaurantsListViewModelRaterStratey {
    private var selectedFilter: String? = nil
}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelRaterStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func httpsCallableData() -> [String : Any]? {
        guard let selectedFilter = selectedFilter else { return nil }
        return ["filter": selectedFilter]
    }

    func httpsCallablePath() -> String {
        "allRestaurants"
    }

    func shouldShowAddRestaurant() -> Bool {
        false
    }

    func shouldShowFilterRestaurant() -> Bool {
        true
    }

    func tabBarSystemImageName() -> String {
        "flag.fill"
    }

    func title() -> String {
        "Restaurants"
    }

    func viewModel(for selectedRestaurant: Restaurant) -> RestaurantDetailsViewModel {
        RestaurantDetailsDefaultViewModel(
            restaurant: selectedRestaurant,
            userRight: .rater
        )
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelRaterStratey {
    func filters() -> [String] {
        ["1", "2", "3", "4", "5"]
    }

    func selectedFilterIndex() -> Int? {
        guard let selectedFilter = selectedFilter else { return nil }
        return filters().firstIndex(of: selectedFilter)
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelRaterStratey {
    func didSelectFilter(at row: Int?) {
        guard let row = row else { return selectedFilter = nil }
        selectedFilter = filters()[row]
    }
}

