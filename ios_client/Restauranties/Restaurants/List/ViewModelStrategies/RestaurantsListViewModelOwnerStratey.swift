//
//  RestaurantsListViewModelOwnerStratey.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation

final class RestaurantsListViewModelOwnerStratey {
    private var selectedFilter: String? = nil
}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelOwnerStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func httpsCallableData() -> [String : Any]? {
        guard
            let selectedFilter = selectedFilter,
            let index = filters().firstIndex(of: selectedFilter)
        else {
            return nil
        }
        return ["filterPendingReply": index == 0 ? true : false]
    }

    func httpsCallablePath() -> String {
        "myRestaurants"
    }

    func shouldShowAddRestaurant() -> Bool {
        true
    }

    func shouldShowFilterRestaurant() -> Bool {
        true
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
        ["Replies Missing", "Replied To All"]
    }

    func selectedFilterIndex() -> Int? {
        guard let selectedFilter = selectedFilter else { return nil }
        return filters().firstIndex(of: selectedFilter)
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelOwnerStratey {
    func didSelectFilter(at row: Int?) {
        guard let row = row else { return selectedFilter = nil }
        selectedFilter = filters()[row]
    }
}

