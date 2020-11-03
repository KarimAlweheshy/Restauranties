//
//  ProfileViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit

final class ProfileViewController: UIViewController {
    private var viewModel: ProfileViewModel

    @IBOutlet private var userImageView: UIImageView!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var userTypeLabel: UILabel!
    @IBOutlet private var isVerifiedImageView: UIImageView!

    @IBOutlet private var changeUserRightContainer: UIView!
    @IBOutlet private var changeUserRightButton: UIButton!
    @IBOutlet private var changeUserRightLoadingView: UIActivityIndicatorView!

    init?(coder: NSCoder, viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
}

// MARK: - Actions

extension ProfileViewController {
    @IBAction private func didTapSignOut() {
        viewModel.didTapSignOut()
    }

    @IBAction private func didTapBecomeOwner() {
        showChangeRightButtonLoading(true)
        viewModel.didTapChangeRightAction { [weak self] in
            guard let self = self else { return }
            self.refreshView()
        }
    }
}

// MARK: - Private Methods

extension ProfileViewController {
    private func refreshView() {
        userNameLabel.text = viewModel.displayName
        emailLabel.text = viewModel.userEmail
        userImageView.image = ImageWithInitialsGenerator().generate(for: viewModel.displayName ?? "")
        isVerifiedImageView.image = UIImage(systemName: viewModel.isEmailVerified ? "checkmark.seal" : "xmark.seal")

        viewModel.refreshedViewModel { [weak self] viewModel in
            guard let self = self else { return }
            self.showChangeRightButtonLoading(false)
            self.viewModel = viewModel
            self.changeUserRightContainer.isHidden = viewModel.isChangeUserRightContainerHidden
            self.userTypeLabel.text = viewModel.userType
            self.changeUserRightButton.setTitle(viewModel.changeUserRightButtonText, for: .normal)
        }
    }

    private func showChangeRightButtonLoading(_ isLoading: Bool) {
        changeUserRightButton.isEnabled = !isLoading
        _ = isLoading ? changeUserRightLoadingView.startAnimating() : changeUserRightLoadingView.stopAnimating()
    }
}
