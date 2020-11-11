//
//  Rating.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation

struct Rating: Codable {
    let stars: Int
    let comment: String
    let dateOfVisit: Date
    let creationDate: Date
}
