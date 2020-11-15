//
//  RestaurantsListViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation
import UIKit

protocol RestaurantsListViewModel {
    func title() -> String
    func tabBarSystemImageName() -> String
    func shouldShowAddRestaurant() -> Bool
    func shouldShowFilterRestaurant() -> Bool
    func refresh()

    func filtersDataSource() -> RestaurantsFilterDataSource
    func filtersDelegate() -> RestaurantsFilterDelegate?

    func viewModelForSelectedRestaurant(at: IndexPath) -> RestaurantDetailsViewModel

    func restaurantsSnapshot() -> NSDiffableDataSourceSnapshot<Int, RestaurantCellViewModelWrapper>
}
