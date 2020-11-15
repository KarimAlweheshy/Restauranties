//
//  RestaurantsListDefaultViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation
import Firebase

protocol RestaurantsListViewModelStratey: RestaurantsFilterDataSource, RestaurantsFilterDelegate {
    func shouldShowFilterRestaurant() -> Bool
    func cellViewModel(for restaurant: Restaurant) -> RestaurantCellViewModel
    func shouldShowAddRestaurant() -> Bool
    func title() -> String
    func tabBarSystemImageName() -> String
    func viewModel(for selectedRestaurant: Restaurant) -> RestaurantDetailsViewModel
    func httpsCallablePath() -> String
    func httpsCallableData() -> [String: Any]
}

final class RestaurantsListDefaultViewModel {
    weak var view: RestaurantsListView?

    private let strategy: RestaurantsListViewModelStratey
    private var restaurants = [Restaurant]() { didSet { view?.reload() } }
    private var selectedFilter: String? = nil

    init(strategy: RestaurantsListViewModelStratey) {
        self.strategy = strategy
    }
}

// MARK: - RestaurantsListViewModel

extension RestaurantsListDefaultViewModel: RestaurantsListViewModel {
    func refresh() {
        view?.showLoading(true)
        let path = strategy.httpsCallablePath()
        let callable = Functions.functions().httpsCallable(path)
        callable.call(strategy.httpsCallableData()) { [weak self] result, error in
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

    func shouldShowFilterRestaurant() -> Bool {
        strategy.shouldShowFilterRestaurant()
    }

    func filtersDataSource() -> RestaurantsFilterDataSource {
        strategy
    }

    func filtersDelegate() -> RestaurantsFilterDelegate? {
        self
    }

    func shouldShowAddRestaurant() -> Bool {
        strategy.shouldShowAddRestaurant()
    }

    func title() -> String {
        strategy.title()
    }

    func tabBarSystemImageName() -> String {
        strategy.tabBarSystemImageName()
    }

    func viewModelForSelectedRestaurant(at indexPath: IndexPath) -> RestaurantDetailsViewModel {
        strategy.viewModel(for: restaurants[indexPath.row])
    }

    func restaurantsSnapshot() -> NSDiffableDataSourceSnapshot<Int, RestaurantCellViewModelWrapper> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RestaurantCellViewModelWrapper>()
        snapshot.appendSections([0])
        let wrappers = restaurants.compactMap { restaurant -> RestaurantCellViewModelWrapper in
            let viewModel = RestaurantCellDefaultViewModel(restaurant: restaurant)
            return RestaurantCellViewModelWrapper(cellViewModel: viewModel)
        }
        snapshot.appendItems(wrappers, toSection: 0)
        return snapshot
    }
}

// MARK: - RestaurantsFilterDataSource

extension RestaurantsListDefaultViewModel: RestaurantsFilterDelegate {
    func didSelectFilter(at row: Int?) {
        strategy.didSelectFilter(at: row)
        refresh()
    }
}
