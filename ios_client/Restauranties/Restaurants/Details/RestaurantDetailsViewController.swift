//
//  RestaurantDetailsViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/10/20.
//

import UIKit

protocol RestaurantDetailsView: AnyObject {
    func reload()
    func popRateFormViewController()
    func showLoading(_ isLoading: Bool)
}

final class RestaurantDetailsViewController: UIViewController {
    private let viewModel: RestaurantDetailsViewModel

    @IBOutlet private var restaurantNameLabel: UILabel!
    @IBOutlet private var restaurantTotalRatingsLabel: UILabel!
    @IBOutlet private var restaurantAverageRatingsLabel: UILabel!

    @IBOutlet private var tableView: UITableView!
    private lazy var dataSource = makeDataSource()

    init?(coder: NSCoder, viewModel: RestaurantDetailsViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
}

// MARK: - Actions

extension RestaurantDetailsViewController {
    @IBAction private func didTapRate() {
        let viewModel = self.viewModel.ratingFormViewModel()
        let viewController = RatingFormViewControllerFactory().make(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func didPullToRefresh() {
        viewModel.refresh()
    }
}

// MARK: - RestaurantDetailsView

extension RestaurantDetailsViewController: RestaurantDetailsView {
    func reload() {
        dataSource.apply(viewModel.ratingsSnapshot())
        refreshHeader()
    }

    func popRateFormViewController() {
        navigationController?.popViewController(animated: true)
    }

    func showLoading(_ isLoading: Bool) {
        let refreshControl = tableView.refreshControl
        _ = isLoading
            ? refreshControl?.beginRefreshing()
            : refreshControl?.endRefreshing()
    }
}

// MARK: - UITableViewDelegate

extension RestaurantDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard viewModel.canDeleteRatings() else { return nil }
        return UISwipeActionsConfiguration(
            actions: [
                UIContextualAction(
                    style: .destructive,
                    title: "Delete"
                ) { [weak viewModel] _, _, completionHandler in
                    viewModel?.didTapDeleteRating(at: indexPath)
                    completionHandler(true)
                }
            ]
        )
    }
}

// MARK: - RestaurantRatingCellDelegate

extension RestaurantDetailsViewController: RestaurantRatingCellDelegate {
    func didTapReplyButton(for cell: RestaurantRatingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let alertController = UIAlertController(
            title: "Add Reply",
            message: "Reply to rating",
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = "Reply"
        }
        let confirmAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { _ in
            guard
                let textField = alertController.textFields?.first,
                let reply = textField.text,
                !reply.isEmpty
            else { return }
            self.viewModel.didAddReplyForRating(reply: reply, at: indexPath)
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Private Methods

extension RestaurantDetailsViewController {
    private func setupUI() {
        tableView.dataSource = dataSource

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
        refreshHeader()
        if !viewModel.canShowRateButton() {
            navigationItem.rightBarButtonItems = []
        }
    }

    private func refreshHeader() {
        restaurantNameLabel.text = viewModel.restaurantName()
        restaurantAverageRatingsLabel.text = viewModel.restaurantAverageRatingsString()
        restaurantTotalRatingsLabel.text = viewModel.restaurantTotalRatingsString()
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, RestaurantRatingCellViewModelWrapper> {
        EditableRowDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, wrapper in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "RestaurantRatingCell",
                    for: indexPath
                ) as! RestaurantRatingCell

                cell.delegate = self
                wrapper.cellViewModel.configure(cell: cell)

                return cell
            }
        )
    }
}
