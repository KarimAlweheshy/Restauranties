//
//  SceneSessionHandler.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import FirebaseUI

final class SceneSessionHandler {
    var window: UIWindow?
    
    private let windowScene: UIWindowScene
    private var authListener: AuthStateDidChangeListenerHandle?
    private var currentUser: User?

    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }

    deinit {
        guard let authListener = authListener else { return }
        Auth.auth().removeStateDidChangeListener(authListener)
    }
}

// MARK: - Public APIs

extension SceneSessionHandler {
    func listenToSessionChanges() {
        authListener = Auth.auth().addStateDidChangeListener { [unowned self] (auth, user) in
            self.setCorrectRoot(for: user)
        }
    }

    func startSession() {
        if let user = Auth.auth().currentUser {
            setCorrectRoot(for: user)
        } else {
            presentAuthViewController()
        }
    }
}

// MARK: - Private Methods

extension SceneSessionHandler {
    private func setCorrectRoot(for user: User?) {
        if let user = user {
            guard user != currentUser else { return }
            self.currentUser = user
            presentMainViewController(for: user)
        } else {
            presentAuthViewController()
        }
    }

    private func presentMainViewController(for user: User) {
        let viewController = HomeViewController.make(user: user)
        present(rootViewController: viewController)
    }

    private func presentAuthViewController() {
        guard let authUI = FUIAuth.defaultAuthUI() else { fatalError() }

        let emailAuthProvider = FUIEmailAuth(
            authAuthUI: authUI,
            signInMethod: EmailPasswordAuthSignInMethod,
            forceSameDevice: false,
            allowNewEmailAccounts: true,
            actionCodeSetting: ActionCodeSettings()
        )
        authUI.providers = [emailAuthProvider, FUIOAuth.appleAuthProvider()]
        authUI.shouldHideCancelButton = true

        let authViewController = authUI.authViewController()
        present(rootViewController: authViewController)
    }

    private func present(rootViewController: UIViewController) {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }

}
