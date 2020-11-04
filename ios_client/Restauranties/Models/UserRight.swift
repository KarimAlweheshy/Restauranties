//
//  UserRight.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import Foundation

enum UserRight {
    case unknown
    case rater
    case admin
    case restaurantOwner

    init(claims: [String: Any]) {
        let isAdmin = claims["admin"] as? Bool == true
        let isOwner = claims["owner"] as? Bool == true
        self = isAdmin ? .admin : isOwner ? .restaurantOwner : .rater
    }
}
