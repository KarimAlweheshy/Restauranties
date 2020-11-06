//
//  EditRestaurantFormViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation

final class EditRestaurantFormViewModel: RestaurantFormViewModel {
    weak var view: RestaurantFormView?

    private var restaurant: Restaurant
    private var name: String

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.name = restaurant.name
    }

    func didTapDone() {

    }

    func didUpdate(name: String) {
        self.name = name
    }

    func doneButtonTitle() -> String {
        "Update"
    }

    func title() -> String {
        "Edit Restaurant"
    }
}
