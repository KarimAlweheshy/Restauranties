//
//  UserAccount.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import Foundation

struct UserAccount: Codable {
    let claims: [String: Bool]?
    let creationDate: String // formatted
    let email: String
    let isVerified: Bool
    let photoURL: URL?
    let uid: String
    let username: String
}
