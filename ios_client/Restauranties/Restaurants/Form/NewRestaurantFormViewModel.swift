//
//  NewRestaurantFormViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation
import Firebase

final class NewRestaurantFormViewModel: RestaurantFormViewModel {
    weak var view: RestaurantFormView?

    private var name = ""

    func didTapDone() {
        guard name.count > 2 else { return }
        Functions.functions().httpsCallable("addRestaurant").call(["name": name]) { result, error in
            print(result)
            print(error)
        }
    }

    func didUpdate(name: String) {
        self.name = name
    }

    func doneButtonTitle() -> String {
        "Save"
    }

    func title() -> String {
        "New Restaurant"
    }
}
