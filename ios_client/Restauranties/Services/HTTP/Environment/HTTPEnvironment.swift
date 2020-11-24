//
//  HTTPEnvironment.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation

protocol HTTPEnvironment {
    var scheme: String { get }
    var host: String { get }
}
