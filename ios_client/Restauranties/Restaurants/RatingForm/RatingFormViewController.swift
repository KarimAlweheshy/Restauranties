//
//  RatingFormViewController.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/11/20.
//

import UIKit

final class RatingFormViewController: UIViewController {
    private let viewModel: RatingFormViewModel

    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var commentTextView: UITextView!
    @IBOutlet private var starsTextField: UITextField!
    @IBOutlet private var starsPicker: UIPickerView!

    init?(coder: NSCoder, viewModel: RatingFormViewModel) {
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

extension RatingFormViewController {
    @IBAction private func didChangeDate() {
        viewModel.didChange(visitDate: datePicker.date)
    }

    @IBAction private func didChangeDone() {
        viewModel.didTapDone()
    }
}

// MARK: - UITextViewDelegate

extension RatingFormViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.didChange(comment: textView.text)
    }
}

// MARK: - UIPickerViewDelegate

extension RatingFormViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        starsTextField.text = self.pickerView(
            pickerView,
            titleForRow: row,
            forComponent: component
        )
        viewModel.didChange(stars: row)
    }
}

// MARK: - UIPickerViewDataSource

extension RatingFormViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        5
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        row == 1 ? "1 star" : "\(row + 1) stars"
    }
}

// MARK: - Private Methods

extension RatingFormViewController {
    private func setupUI() {
        starsTextField.inputView = starsPicker
        starsTextField.text = pickerView(starsPicker, titleForRow: 4, forComponent: 0)
        starsPicker.selectRow(4, inComponent: 0, animated: false)

        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        commentTextView.layer.cornerRadius = 3

        datePicker.maximumDate = Date()
    }
}
