//
//  RestaurantsListViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/2/20.
//

import UIKit

protocol RestaurantsListView: AnyObject {
    func reload()
    func showLoading(_ isLoading: Bool)
}

final class RestaurantsListViewController: UIViewController {
    private let viewModel: RestaurantsListViewModel

    @IBOutlet private var tableView: UITableView!
    private lazy var dataSource = makeDataSource()

    init?(coder: NSCoder, viewModel: RestaurantsListViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        title = viewModel.title()
        tabBarItem.image = UIImage(systemName: viewModel.tabBarSystemImageName())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
}

// MARK: - RestaurantsListView

extension RestaurantsListViewController: RestaurantsListView {
    func reload() {
        dataSource.apply(viewModel.restaurantsSnapshot())
    }

    func showLoading(_ isLoading: Bool) {
        let refreshControl = tableView.refreshControl
        _ = isLoading
            ? refreshControl?.beginRefreshing()
            : refreshControl?.endRefreshing()
    }
}

// MARK: - UITableViewDelegate

extension RestaurantsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.viewModel.viewModelForSelectedRestaurant(at: indexPath)
        let viewController = RestaurantDetailsViewControllerFactory().make(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Actions

extension RestaurantsListViewController {
    @objc private func didPullToRefresh() {
        viewModel.refresh()
    }

    @objc private func didTapAddNewRestaurant() {
        let viewController = RestaurantFormViewControllerFactory().makeNewRestaurant()
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    @objc private func didTapFilter() {
        let viewController = RestaurantsFilterViewController.make(dataSource: viewModel.filtersDataSource())
        viewController.delegate = viewModel.filtersDelegate()
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}

// MARK: - Private Methods

extension RestaurantsListViewController {
    private func setupUI() {
        tableView.dataSource = dataSource
        var barButtonItems = navigationItem.rightBarButtonItems ?? []
        if viewModel.shouldShowAddRestaurant() {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddNewRestaurant))
            barButtonItems += [barButtonItem]
        }
        if viewModel.shouldShowFilterRestaurant() {
            let barButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(didTapFilter))
            barButtonItems += [barButtonItem]
        }
        navigationItem.rightBarButtonItems = barButtonItems

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
    }

    func makeDataSource() -> UITableViewDiffableDataSource<Int, RestaurantCellViewModelWrapper> {
        EditableRowDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, wrapper in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "RestaurantListCell",
                    for: indexPath
                ) as! RestaurantListCell

                wrapper.cellViewModel.configure(cell: cell)

                return cell
            }
        )
    }
}
