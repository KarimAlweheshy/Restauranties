//
//  RestaurantsListViewModelOwnerStratey.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation

final class RestaurantsListViewModelOwnerStratey {}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelOwnerStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func httpsCallableData() -> [String : Any] {
        [String: Any]()
    }

    func httpsCallablePath() -> String {
        "myRestaurants"
    }

    func shouldShowAddRestaurant() -> Bool {
        true
    }

    func shouldShowFilterRestaurant() -> Bool {
        false
    }

    func tabBarSystemImageName() -> String {
        "books.vertical.fill"
    }

    func title() -> String {
        "My Restaurants"
    }

    func viewModel(for selectedRestaurant: Restaurant) -> RestaurantDetailsViewModel {
        RestaurantDetailsDefaultViewModel(
            restaurant: selectedRestaurant,
            userRight: .restaurantOwner
        )
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelOwnerStratey {
    func filters() -> [String] {
        fatalError()
    }

    func selectedFilterIndex() -> Int? {
        fatalError()
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelOwnerStratey {
    func didSelectFilter(at row: Int?) {
        fatalError()
    }
}

