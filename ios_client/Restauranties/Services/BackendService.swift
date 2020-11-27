//
//  BackendService.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation

protocol BackendService {
    var env: HTTPEnvironment { get }
    var authenticator: HTTPAuthenticator { get }
}

extension BackendService {
    func url(
        httpMethod: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpBody: Data? = nil
    ) -> URLRequest {
        var components = URLComponents()
        components.scheme = env.scheme
        components.host = env.host
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else { fatalError() }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        authenticator.addAuthentication(to: &request)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
