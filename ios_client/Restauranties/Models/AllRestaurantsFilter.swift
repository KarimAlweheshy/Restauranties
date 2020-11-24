//
//  AllRestaurantsFilter.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation

enum AllRestaurantsFilter: String, CaseIterable {
    case oneStar = "One Star"
    case twoStars = "Two Stars"
    case threeStars = "Three Stars"
    case fourStars = "Four Stars"
    case fiveStars = "Five Stars"

    var starsNumber: Int {
        switch self {
        case .oneStar: return 1
        case .twoStars: return 2
        case .threeStars: return 3
        case .fourStars: return 4
        case .fiveStars: return 5
        }
    }
}
