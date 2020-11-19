//
//  File.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation
import AWSLambdaRuntime

enum Handler: String {

    case create
    case update
    case delete
    case read
    case list

    static var current: Handler? {
        guard let handler = Lambda.env("_HANDLER") else {
            return nil
        }
        return Handler(rawValue: handler)
    }
}
