//
//  FirebaseHTTPAuthenticator.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/23/20.
//

import Foundation
import FirebaseAuth
import OSLog

final class FirebaseHTTPAuthenticator: HTTPAuthenticator {
    private var token: String?
    private var listener: IDTokenDidChangeListenerHandle?

    init() {
        listener = Auth.auth().addIDTokenDidChangeListener { [weak self] auth, user in
            self?.refetchToken()
        }
    }

    deinit {
        guard let listener = listener else { return }
        Auth.auth().removeIDTokenDidChangeListener(listener)
    }

    func addAuthentication(to request: inout URLRequest) {
        defer { refetchToken() }
        guard let token = token else { return }
        request.addValue(
            token,
            forHTTPHeaderField: "authorization"
        )
    }
}

// MARK: - Private Methods

extension FirebaseHTTPAuthenticator {
    private func refetchToken() {
        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard error == nil else {
                let logger = OSLog(
                    subsystem: Bundle.main.bundleIdentifier!,
                    category: "authenticator"
                )
                os_log(
                    "Error authenticating",
                    log: logger,
                    type: .error
                )
                self?.refetchToken()
                return
            }
            self?.token = token
        }
    }
}
