//
//  RestaurantsListViewModelOwnerStratey.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation
import Combine

final class RestaurantsListViewModelOwnerStratey {
    private let service: RestaurantsBackendService
    private var selectedFilter: String? = nil
    private var cancellable: AnyCancellable?

    init(service: RestaurantsBackendService) {
        self.service = service
    }
}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelOwnerStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func refreshRestaurants(completionHandler: @escaping (Result<[Restaurant], Error>) -> Void) {
        cancellable?.cancel()
        cancellable = service.getMyRestaurants(
            filter: filter(),
            completionHandler: completionHandler
        )
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
        let service = RestaurantsBackendFirebaseService(
            env: FirebaseReleaseHTTPEnvironment(),
            authenticator: FirebaseHTTPAuthenticator()
        )
        return RestaurantDetailsDefaultViewModel(
            restaurantsService: service,
            restaurant: selectedRestaurant,
            userRight: .restaurantOwner
        )
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListViewModelOwnerStratey {
    func filters() -> [String] {
        MyRestaurantsFilter.allCases.compactMap { $0.rawValue }
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

// MARK: - Private Methods

extension RestaurantsListViewModelOwnerStratey {
    private func filter() -> MyRestaurantsFilter? {
        guard let selectedFilter = selectedFilter else { return nil }
        return MyRestaurantsFilter(rawValue: selectedFilter)
    }
}
