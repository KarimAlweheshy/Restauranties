//
//  RestaurantFormViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation

protocol RestaurantFormViewModel {
    func title() -> String
    func doneButtonTitle() -> String
    func didTapDone()
    func didUpdate(name: String)
}
