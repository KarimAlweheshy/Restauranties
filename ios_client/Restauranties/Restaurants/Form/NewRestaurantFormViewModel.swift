//
//  NewRestaurantFormViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation
import Combine

final class NewRestaurantFormViewModel: RestaurantFormViewModel {
    weak var view: RestaurantFormView?
    private let service: RestaurantsBackendService
    private var disposables = Set<AnyCancellable>()

    private var name = ""

    init(service: RestaurantsBackendService) {
        self.service = service
    }

    func didTapDone() {
        guard name.count > 2 else { return }
        view?.enableDoneButton(false)
        let cancellable = service.createNewRestaurant(name: name) { [weak self] result in
            self?.view?.enableDoneButton(true)
            switch result {
            case .failure: break
            case .success: self?.view?.didFinish()
            }
        }
        disposables.insert(cancellable)
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
