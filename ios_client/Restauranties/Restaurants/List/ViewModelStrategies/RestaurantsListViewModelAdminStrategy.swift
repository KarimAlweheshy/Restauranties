//
//  RestaurantsListViewModelAdminStrategy.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/14/20.
//

import Foundation
import Combine

final class RestaurantsListViewModelAdminStratey {
    private let service: RestaurantsBackendService
    private var cancellable: AnyCancellable?

    init(service: RestaurantsBackendService) {
        self.service = service
    }
}

// MARK: - RestaurantsListViewModelStratey

extension RestaurantsListViewModelAdminStratey: RestaurantsListViewModelStratey {
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel {
        RestaurantCellDefaultViewModel(restaurant: restaurant)
    }

    func refreshRestaurants(completionHandler: @escaping (Result<[Restaurant], Error>) -> Void) {
        cancellable?.cancel()
        cancellable = service.getAllRestaurants(
            filter: nil,
            completionHandler: completionHandler
        )
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

