//
//  RestaurantFormViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/4/20.
//

import UIKit

protocol RestaurantFormView: AnyObject {
    func enableDoneButton(_ isEnabled: Bool)
}

final class RestaurantFormViewController: UIViewController {
    private let viewModel: RestaurantFormViewModel

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var doneBarButtonItem: UIBarButtonItem!

    init?(coder: NSCoder, viewModel: RestaurantFormViewModel) {
        self.viewModel = viewModel

        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - RestaurantFormView

extension RestaurantFormViewController: RestaurantFormView {
    func enableDoneButton(_ isEnabled: Bool) {
        doneBarButtonItem.isEnabled = isEnabled
    }
}

// MARK: - Actions
extension RestaurantFormViewController {
    @IBAction private func didChange(textfield: UITextField) {
        viewModel.didUpdate(name: textfield.text ?? "")
    }

    @IBAction private func didTapDone() {
        viewModel.didTapDone()
    }
}
