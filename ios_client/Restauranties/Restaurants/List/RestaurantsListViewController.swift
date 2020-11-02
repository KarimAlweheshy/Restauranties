//
//  RestaurantsListViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import Firebase

final class RestaurantsListViewController: UIViewController {
    private let collectionReference: CollectionReference
    private let user: User

    init?(coder: NSCoder, collectionReference: CollectionReference, user: User) {
        self.collectionReference = collectionReference
        self.user = user
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionReference.getDocuments(source: .default) { snapshot, error in
            let restaurants = snapshot?.documents.compactMap { data -> Restaurant? in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: data.data(), options: .fragmentsAllowed) else {
                    return nil
                }
                return try? JSONDecoder().decode(Restaurant.self, from: jsonData)
            }
            print(restaurants ?? [])
        }
    }
}

// MARK: - Factory

extension RestaurantsListViewController {
    static func make(collectionReference: CollectionReference, user: User) -> RestaurantsListViewController {
        let storyboard = UIStoryboard(name: "RestaurantsList", bundle: nil)
        let viewController: RestaurantsListViewController? = storyboard.instantiateInitialViewController { coder in
            RestaurantsListViewController(coder: coder, collectionReference: collectionReference, user: user)
        }
        return viewController!
    }
}
