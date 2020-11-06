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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Functions.functions().httpsCallable("getAllUsers").call() { [weak self] result, error in
            guard let self = self else { return }
            guard
                let data = result?.data,
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
                let users = try? JSONDecoder().decode([UserAccount].self, from: jsonData)
            else { return self.users = [] }
            self.users = users
            self.tableView.reloadData()
        }
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
        switch UserRight(claims: user.claims ?? [:]) {
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
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(
            actions: [
                UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                    let user = self.users[indexPath.row]
                    let right = user.claims.map(UserRight.init(claims:))
                    guard right != .admin else { self.showCannotDeleteAdmin(); return completion(true) }

                    let message = right == .rater
                        ? "Deleting this user will result in deletion of all his ratings"
                        : "Deleting this user will result in deletion of all his restaurants and their ratings"
                    self.showDeleteUserAlert(message: message) {
                        Functions.functions().httpsCallable("deleteUser").call(["uid": user.uid]) { [weak self] result, error in
                            guard let self = self else { return }
                            self.users.remove(at: indexPath.row)
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: .left)
                            self.tableView.endUpdates()
                        }
                    } cancelAction: {
                        completion(true)
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
        deleteAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Delete User",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in deleteAction() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in cancelAction() }))
        present(alert, animated: true, completion: nil)
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
}
