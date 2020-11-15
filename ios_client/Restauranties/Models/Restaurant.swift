//
//  Restaurant.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import Foundation

struct Restaurant: Codable, Hashable {
    let id: String
    let name: String
    let phone: String?
    let imageURL: URL?
    let categories: [String]?
    let ownerID: String
    let totalRatings: Int
    let averageRating: Double
    let creationDate: Date
    let modificationDate: Date
}
