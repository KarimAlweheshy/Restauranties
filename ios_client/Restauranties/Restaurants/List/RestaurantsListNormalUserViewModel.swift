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

    private let user: User
    private let collectionReference: CollectionReference

    private var restaurants = [Restaurant]() { didSet { view?.reload() } }

    init(collectionReference: CollectionReference, user: User) {
        self.collectionReference = collectionReference
        self.user = user
    }
}

// MARK: - RestaurantsListViewModel

extension RestaurantsListRaterViewModel: RestaurantsListViewModel {
    func viewDidLoad() {
        collectionReference.getDocuments(source: .default) { [weak self] snapshot, error in
            let restaurants = snapshot?.documents.compactMap { data -> Restaurant? in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: data.data(), options: .fragmentsAllowed) else {
                    return nil
                }
                return try? JSONDecoder().decode(Restaurant.self, from: jsonData)
            }
            self?.restaurants = restaurants ?? []
        }
    }

    func numberOfRows() -> Int {
        restaurants.count
    }

    func cellViewModel(for indexPath: IndexPath) -> RestaurantCellViewModel {
        RestaurantCellNormalViewModel()
    }
}
