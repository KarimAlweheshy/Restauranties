//
//  RestaurantListOwnerViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation
import Firebase

final class RestaurantsListOwnerViewModel {
    weak var view: RestaurantsListView?

    private var restaurants = [Restaurant]() { didSet { view?.reload() } }
}

// MARK: - RestaurantsListViewModel

extension RestaurantsListOwnerViewModel: RestaurantsListViewModel {
    func refresh() {
        Functions.functions().httpsCallable("myRestaurants").call() { [weak self] result, error in
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
                let restaurants = try? decoder.decode([Restaurant].self, from: jsonData)
            else { return self.restaurants = [] }
            self.restaurants = restaurants
        }
    }

    func numberOfRows() -> Int {
        restaurants.count
    }

    func shouldShowFilterRestaurant() -> Bool {
        false
    }

    func filtersDataSource() -> RestaurantsFilterDataSource {
        fatalError("Not implemented")
    }

    func filtersDelegate() -> RestaurantsFilterDelegate? {
         nil
    }

    func cellViewModel(for indexPath: IndexPath) -> RestaurantCellViewModel {
        RestaurantCellNormalViewModel(restaurant: restaurants[indexPath.row])
    }

    func shouldShowAddRestaurant() -> Bool {
        true
    }

    func title() -> String {
        "My Restaurants"
    }

    func tabBarSystemImageName() -> String {
        "books.vertical.fill"
    }

    func viewModelForSelectedRestaurant(at indexPath: IndexPath) -> RestaurantDetailsViewModel {
        let restaurant = restaurants[indexPath.row]
        return RestaurantDetailsRaterViewModel(
            restaurant: restaurant,
            isUserRater: false
        )
    }
}
