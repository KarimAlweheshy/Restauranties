//
//  HTTPResponseParser.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation

struct HTTPResponseParser {
    func dataOrError(data: Data?, response: URLResponse) throws -> Data? {
        guard let response = response as? HTTPURLResponse else {
            fatalError("Support only http")
        }
        if !(200..<300).contains(response.statusCode) {
            throw HTTPError(
                statusCode: response.statusCode,
                data: data
            )
        }
        return data
    }

    func voidOrError(data: Data?, response: URLResponse) throws {
        guard
            let response = response as? HTTPURLResponse,
            !(200..<300).contains(response.statusCode)
        else {
            fatalError("Support only http")
        }
        throw HTTPError(
            statusCode: response.statusCode,
            data: data
        )
    }
}
