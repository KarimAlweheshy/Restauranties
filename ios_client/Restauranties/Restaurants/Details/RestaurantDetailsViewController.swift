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
}

final class RestaurantDetailsViewController: UIViewController {
    private let viewModel: RestaurantDetailsViewModel

    @IBOutlet private var restaurantNameLabel: UILabel!
    @IBOutlet private var restaurantTotalRatingsLabel: UILabel!
    @IBOutlet private var restaurantAverageRatingsLabel: UILabel!

    @IBOutlet private var tableView: UITableView!

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
}

// MARK: - RestaurantDetailsView

extension RestaurantDetailsViewController: RestaurantDetailsView {
    func reload() {
        tableView.reloadData()
    }

    func popRateFormViewController() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RestaurantDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRatingCells()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantRatingCell", for: indexPath) as! RestaurantRatingCell
        let cellViewModel = viewModel.ratingCellViewModel(for: indexPath)
        cellViewModel.configure(cell: cell)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RestaurantDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

// MARK: - Private Methods

extension RestaurantDetailsViewController {
    private func setupUI() {
        restaurantNameLabel.text = viewModel.restaurantName()
        restaurantAverageRatingsLabel.text = viewModel.restaurantAverageRatingsString()
        restaurantTotalRatingsLabel.text = viewModel.restaurantTotalRatingsString()
    }
}
