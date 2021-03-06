//
//  Rating.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import Foundation

struct Rating: Codable, Equatable, Hashable {
    let id: String
    let stars: Int
    let comment: String
    let username: String
    let photoURL: URL?
    let visitDate: Date
    let creationDate: Date
    let reply: String?
}
