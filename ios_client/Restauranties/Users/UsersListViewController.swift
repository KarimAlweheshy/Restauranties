//
//  UsersListViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/3/20.
//

import UIKit
import FirebaseFunctions

final class UsersListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private var users = [UserAccount]()

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
        let callable = Functions.functions().httpsCallable("deleteUser")
        callable.call(["uid": user.uid]) { [weak self] result, error in
            guard let self = self else { return }
            self.refresh()
        }
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
        Functions.functions().httpsCallable("getAllUsers").call() { [weak self] result, error in
            guard let self = self else { return }
            self.tableView.refreshControl?.endRefreshing()
            guard
                let data = result?.data,
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
                let users = try? JSONDecoder().decode([UserAccount].self, from: jsonData)
            else { return self.users = [] }
            self.users = users
            self.tableView.reloadData()
        }
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
