//
//  HTTPError.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation

struct HTTPError: Error {
    let statusCode: Int
    let data: Data

    var failureReason: String? {
        String(data: data, encoding: .utf8)
    }
    
    var localizedError: String {
        HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}
