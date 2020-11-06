//
//  RestaurantsFilterViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/6/20.
//

import UIKit

protocol RestaurantsFilterDataSource: AnyObject {
    func filters() -> [String]
    func selectedFilterIndex() -> Int?
}

protocol RestaurantsFilterDelegate: AnyObject {
    func didSelectFilter(at row: Int?)
}

final class RestaurantsFilterViewController: UIViewController {
    weak var delegate: RestaurantsFilterDelegate?

    private unowned let dataSource: RestaurantsFilterDataSource

    init?(coder: NSCoder, dataSource: RestaurantsFilterDataSource) {
        self.dataSource = dataSource
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource

extension RestaurantsFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.filters().count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantFilterCell", for: indexPath)
        if indexPath.row == dataSource.filters().count {
            cell.textLabel?.text = "No Filter"
            cell.accessoryType = dataSource.selectedFilterIndex() == nil ? .checkmark : .none
        } else {
            cell.textLabel?.text = dataSource.filters()[indexPath.row]
            cell.accessoryType = dataSource.selectedFilterIndex() == indexPath.row ? .checkmark : .none
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RestaurantsFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectFilter(at: indexPath.row == dataSource.filters().count ? nil : indexPath.row)
        tableView.reloadData()
    }
}

// MARK: - Actions

extension RestaurantsFilterViewController {
    @IBAction private func didTapDone() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Factory
extension RestaurantsFilterViewController {
    class func make(dataSource: RestaurantsFilterDataSource) -> RestaurantsFilterViewController {
        let storyboard = UIStoryboard(name: "RestaurantsFilter", bundle: nil)
        let viewController: RestaurantsFilterViewController? = storyboard.instantiateInitialViewController { coder in
            RestaurantsFilterViewController(coder: coder, dataSource: dataSource)
        }
        return viewController!
    }
}
