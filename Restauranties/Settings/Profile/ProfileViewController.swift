//
//  ProfileViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController {
    private let user: User

    @IBOutlet private var userImageView: UIImageView!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var isVerifiedImageView: UIImageView!

    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
}

// MARK: - Factory Methods

extension ProfileViewController {
    static func make(user: User) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewController: ProfileViewController? = storyboard.instantiateInitialViewController { coder in
            ProfileViewController(coder: coder, user: user)
        }
        return viewController!
    }
}

// MARK: - Actions

extension ProfileViewController {
    @IBAction private func didTapSignOut() {
        try? Auth.auth().signOut()
    }
}

// MARK: - Private Methods

extension ProfileViewController {
    private func setupUI() {
        userNameLabel.text = user.displayName
        emailLabel.text = user.email
        setupUserImage()
        isVerifiedImageView.image = UIImage(systemName: user.isEmailVerified ? "checkmark.seal" : "xmark.seal")
    }

    private func setupUserImage() {
        let firstNameInitial = user.displayName?.split(separator: " ").first?.first
        let lastNameInitial = user.displayName?.split(separator: " ").last?.first

        let lblNameInitialize = UILabel()
        lblNameInitialize.font = .boldSystemFont(ofSize: 80)
        lblNameInitialize.frame.size = CGSize(width: 160.0, height: 160.0)
        lblNameInitialize.textColor = .darkText
        lblNameInitialize.text = String(firstNameInitial!) + String(lastNameInitial!)
        lblNameInitialize.textAlignment = .center
        lblNameInitialize.backgroundColor = .secondarySystemBackground
        lblNameInitialize.layer.cornerRadius = 80.0

        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        userImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
