//
//  RestaurantsListViewModelAdminStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation

final class RestaurantsListViewModelAdminStratey {}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelAdminStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func httpsCallableData() -> [String : Any] {
        [String: Any]()
    }

    func httpsCallablePath() -> String {
        "allRestaurants"
    }

    func shouldShowAddRestaurant() -> Bool {
        false
    }

    func shouldShowFilterRestaurant() -> Bool {
        false
    }

    func tabBarSystemImageName() -> String {
        "doc.badge.gearshape.fill"
    }

    func title() -> String {
        "Restaurants"
    }

    func viewModel(for selectedRestaurant: Restaurant) -> RestaurantDetailsViewModel {
        RestaurantDetailsRaterViewModel(
            restaurant: selectedRestaurant,
            userRight: .admin
        )
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelAdminStratey {
    func filters() -> [String] {
        fatalError()
    }

    func selectedFilterIndex() -> Int? {
        fatalError()
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelAdminStratey {
    func didSelectFilter(at row: Int?) {
        fatalError()
    }
}

