//
//  Restaurant.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation

public struct Restaurant: Codable {
    public var createdAt: Date?
    public var updatedAt: Date?

    public let id: String
    public let ownerID: String
    public let name: String
    public let noReplyCount: Int?
    public let averageRating: Int
    public let totalRatingCount: Int
}
