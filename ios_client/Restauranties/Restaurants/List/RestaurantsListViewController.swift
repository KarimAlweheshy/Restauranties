//
//  RestaurantsListViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit

protocol RestaurantsListView: NSObjectProtocol {
    func reload()
}

final class RestaurantsListViewController: UIViewController {
    private let viewModel: RestaurantsListViewModel

    @IBOutlet private var tableView: UITableView!

    init?(coder: NSCoder, viewModel: RestaurantsListViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }
}

// MARK: - RestaurantsListView

extension RestaurantsListViewController: RestaurantsListView {
    func reload() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension RestaurantsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListCell", for: indexPath) as! RestaurantListCell
        viewModel.cellViewModel(for: indexPath).configure(cell: cell)
        return cell
    }
}
