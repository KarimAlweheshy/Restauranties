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

    init(service: RestaurantsBackendService) {
        self.service = service
    }
}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelOwnerStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func refreshRestaurants() -> AnyPublisher<[Restaurant], Error> {
        service.getMyRestaurants(filter: nil)
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
        let restaurantsService = RestaurantsBackendFirebaseService(
            env: FirebaseReleaseHTTPEnvironment(),
            authenticator: FirebaseHTTPAuthenticator()
        )
        let ratingsService = RatingsBackendFirebaseService(
            env: FirebaseReleaseHTTPEnvironment(),
            authenticator: FirebaseHTTPAuthenticator()
        )
        return RestaurantDetailsDefaultViewModel(
            restaurantsService: restaurantsService,
            ratingsService: ratingsService,
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
