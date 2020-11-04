//
//  RestaurantsListViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation

protocol RestaurantsListViewModel {
    func title() -> String
    func tabBarSystemImageName() -> String
    func shouldShowAddRestaurant() -> Bool
    func viewDidLoad()
    func numberOfRows() -> Int
    func cellViewModel(for indexPath: IndexPath) -> RestaurantCellViewModel
}
