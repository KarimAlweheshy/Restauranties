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
        let user = users[indexPath.row]
        guard user.claims?["admin"] != true else { return nil }
        return UISwipeActionsConfiguration(
            actions: [
                UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                    Functions.functions().httpsCallable("deleteUser").call(["uid": user.uid]) { [weak self] result, error in
                        completion(error == nil)
                        guard let self = self else { return }
                        self.users.remove(at: indexPath.row)
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                        self.tableView.endUpdates()
                    }
                }
            ]
        )
    }
}
