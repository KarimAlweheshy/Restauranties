//
//  RestaurantsListViewModelRaterStratey.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation
import Combine

final class RestaurantsListViewModelRaterStratey {
    private let service: RestaurantsBackendService
    private var selectedFilter: String? = nil
    private var cancellable: AnyCancellable?

    init(service: RestaurantsBackendService) {
        self.service = service
    }
}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelRaterStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func refreshRestaurants(
        completionHandler: @escaping (Result<[Restaurant], Error>) -> Void
    ) {
        cancellable?.cancel()
        cancellable = service.getAllRestaurants(
            filter: filter(),
            completionHandler: completionHandler
        )
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
        AllRestaurantsFilter.allCases.compactMap { $0.rawValue }
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

// MARK: - Private Methods

extension RestaurantsListViewModelRaterStratey {
    private func filter() -> AllRestaurantsFilter? {
        guard let selectedFilter = selectedFilter else { return nil }
        return AllRestaurantsFilter(rawValue: selectedFilter)
    }
}

