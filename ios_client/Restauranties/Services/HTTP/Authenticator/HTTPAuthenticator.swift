//
//  HTTPAuthenticator.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation

protocol HTTPAuthenticator {
    func addAuthentication(to: inout URLRequest)
}
