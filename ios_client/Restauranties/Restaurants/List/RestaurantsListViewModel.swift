//
//  RestaurantsListViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation
import Firebase

protocol RestaurantsListViewModel {
    func viewDidLoad()
    func numberOfRows() -> Int
    func cellViewModel(for indexPath: IndexPath) -> RestaurantCellViewModel
}

final class RestaurantsListNormalUserViewModel {
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

extension RestaurantsListNormalUserViewModel: RestaurantsListViewModel {
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
