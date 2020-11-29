//
//  UsersListViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit
import Combine

final class UsersListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let service: UsersBackendService
    private var users = [UserAccount]()
    private var disposables = Set<AnyCancellable>()

    init?(coder: NSCoder, service: UsersBackendService) {
        self.service = service
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tabBarItem.image = UIImage(systemName: "chart.bar.doc.horizontal.fill")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refresh()
    }
}

// MARK: - Actions
extension UsersListViewController {
    @objc private func didPullToRefresh() {
        refresh()
    }
}

// MARK: - UITableViewDataSource

extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserAccountCell", for: indexPath) as! UserAccountCell
        let user = users[indexPath.row]
        cell.usernameLabel.text = user.username
        cell.userCreationLabel.text = user.creationDate
        cell.isVerifiedImageView.image = UIImage(systemName: user.isVerified ? "checkmark.seal" : "xmark.seal")
        cell.userImageView.image = ImageWithInitialsGenerator().generate(for: user.username)
        let userRight = UserRight(claims: user.claims ?? [:])
        setup(cell: cell, for: userRight)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(
            actions: [
                UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                    defer { completion(true) }
                    let user = self.users[indexPath.row]
                    let right = user.claims.map(UserRight.init(claims:))
                    guard right != .admin else { return self.showCannotDeleteAdmin() }

                    let message = right == .rater
                        ? "Deleting this user will result in deletion of all his ratings"
                        : "Deleting this user will result in deletion of all his restaurants and their ratings"
                    self.showDeleteUserAlert(message: message) {
                        self.delete(user)
                    }
                }
            ]
        )
    }
}

// MARK: - Private Methods
extension UsersListViewController {
    private func showDeleteUserAlert(
        message: String,
        deleteAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Delete User",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in deleteAction() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func delete(_ user: UserAccount) {
        service
            .delete(user: user)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.refresh()
                }
            ).store(in: &disposables)
    }

    private func showCannotDeleteAdmin() {
        let alert = UIAlertController(
            title: "Delete User",
            message: "Cannot delete an Admin from API",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in }))
        present(alert, animated: true, completion: nil)
    }

    private func setupUI() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
    }

    private func refresh() {
        tableView.refreshControl?.beginRefreshing()
        service
            .getUsers()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .failure: self.users = []
                    case .finished: break
                    }
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                },
                receiveValue: { [weak self] result in
                    self?.users = result
                }
            ).store(in: &disposables)
    }

    private func setup(
        cell: UserAccountCell,
        for userRight: UserRight
    ) {
        switch userRight {
        case .admin:
            cell.userRightLabel.text = "Admin"
            cell.userRightLabel.textColor = .systemPurple
        case .restaurantOwner:
            cell.userRightLabel.text = "Owner"
            cell.userRightLabel.textColor = .systemGreen
        case .rater:
            cell.userRightLabel.text = "Rater"
            cell.userRightLabel.textColor = .systemYellow
        case .unknown: fatalError()
        }
    }
}
