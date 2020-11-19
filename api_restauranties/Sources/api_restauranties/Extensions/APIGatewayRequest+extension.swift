//
//  File.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation
import AWSLambdaEvents

enum APIGatewayRequestError: Error {
    case missingBody
}

extension APIGateway.Request {
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        var convertor = DateToISO8601Convertor()
        decoder.dateDecodingStrategy = .formatted(convertor.formatter)
        return decoder
    }()

    func bodyObject<D: Decodable>() throws -> D {
        guard let jsonData = body?.data(using: .utf8) else {
            throw APIGatewayRequestError.missingBody
        }
        let object = try APIGateway.Request.jsonDecoder.decode(D.self, from: jsonData)
        return object
    }
}
