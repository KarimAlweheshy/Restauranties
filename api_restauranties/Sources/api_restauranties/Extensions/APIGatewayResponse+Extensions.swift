//
//  File.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation
import AWSLambdaEvents

extension APIGateway.Response {

    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        var convertor = DateToISO8601Convertor()
        encoder.dateEncodingStrategy = .formatted(convertor.formatter)
        return encoder
    }()

    public static let defaultHeaders = [
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST,PUT,DELETE",
        "Access-Control-Allow-Credentials": "true",
    ]

    public init(with error: Error, statusCode: AWSLambdaEvents.HTTPResponseStatus) {
        self.init(
            statusCode: statusCode,
            headers: APIGateway.Response.defaultHeaders,
            multiValueHeaders: nil,
            body: "{\"error\":\"\(String(describing: error))\"}",
            isBase64Encoded: false
        )
    }

    public init<Out: Encodable>(with object: Out, statusCode: AWSLambdaEvents.HTTPResponseStatus) {
        var body: String = "{}"
        if let data = try? Self.jsonEncoder.encode(object) {
            body = String(data: data, encoding: .utf8) ?? body
        }
        self.init(
            statusCode: statusCode,
            headers: APIGateway.Response.defaultHeaders,
            multiValueHeaders: nil,
            body: body,
            isBase64Encoded: false
        )
    }
}
