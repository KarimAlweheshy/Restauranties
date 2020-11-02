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
    private let collectionReference: CollectionReference
    private var authListener: AuthStateDidChangeListenerHandle?

    init(
        windowScene: UIWindowScene,
        collectionReference: CollectionReference
    ) {
        self.windowScene = windowScene
        self.collectionReference = collectionReference
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
            self.setCorrectRoot(for: user, collectionReference: self.collectionReference)
        }
    }

    func startSession() {
        guard Auth.auth().currentUser == nil else { return }
        presentAuthViewController()
    }
}

// MARK: - Private Methods

extension SceneSessionHandler {
    private func setCorrectRoot(for user: User?, collectionReference: CollectionReference) {
        if let user = user {
            presentMainViewController(for: user, collectionReference: collectionReference)
        } else {
            presentAuthViewController()
        }
    }

    private func presentMainViewController(for user: User, collectionReference: CollectionReference) {
        let viewController = HomeViewController.make(user: user, collectionReference: collectionReference)
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
