//
//  RestaurantsListRaterViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation
import Firebase

final class RestaurantsListRaterViewModel {
    weak var view: RestaurantsListView?

    private var restaurants = [Restaurant]() { didSet { view?.reload() } }
    private var selectedFilter: String? = nil
}

// MARK: - RestaurantsListViewModel

extension RestaurantsListRaterViewModel: RestaurantsListViewModel {
    func viewDidLoad() {
        var data: [String: Any]?
        if let selectedFilter = selectedFilter {
            data = ["filter": selectedFilter]
        }
        Functions.functions().httpsCallable("allRestaurants").call(data) { [weak self] result, error in
            guard let self = self else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard
                let data = result?.data,
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
                let restaurants = try? decoder.decode([Restaurant].self, from: jsonData)
            else { return self.restaurants = [] }
            self.restaurants = restaurants
            self.view?.reload()
        }
    }

    func shouldShowFilterRestaurant() -> Bool {
        true
    }

    func filtersDataSource() -> RestaurantsFilterDataSource {
        self
    }

    func filtersDelegate() -> RestaurantsFilterDelegate? {
         self
    }

    func numberOfRows() -> Int {
        restaurants.count
    }

    func cellViewModel(for indexPath: IndexPath) -> RestaurantCellViewModel {
        RestaurantCellNormalViewModel(restaurant: restaurants[indexPath.row])
    }

    func shouldShowAddRestaurant() -> Bool {
        false
    }

    func title() -> String {
        "Restaurants"
    }

    func tabBarSystemImageName() -> String {
        "flag.fill"
    }

    func viewModelForSelectedRestaurant(at indexPath: IndexPath) -> RestaurantDetailsViewModel {
        let restaurant = restaurants[indexPath.row]
        return RestaurantDetailsRaterViewModel(restaurant: restaurant)
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListRaterViewModel: RestaurantsFilterDataSource {
    func filters() -> [String] {
        ["1", "2", "3", "4", "5"]
    }

    func selectedFilterIndex() -> Int? {
        guard let selectedFilter = selectedFilter else { return nil }
        return filters().firstIndex(of: selectedFilter)
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListRaterViewModel: RestaurantsFilterDelegate {
    func didSelectFilter(at row: Int?) {
        defer { viewDidLoad() }
        guard let row = row else { return selectedFilter = nil }
        selectedFilter = filters()[row]
    }
}
