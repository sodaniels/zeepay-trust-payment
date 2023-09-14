//
//  FontPickerViewController.swift
//  Example
//

import UIKit

final class FontPickerViewController: BaseViewController<FontPickerView, FontPickerViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case didFontSelect(String)
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = Localizable.FontPickerViewController.title.text
        customView.tableView.register(dequeueableCell: FontCell.self)
        setupBarButtons()
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        viewModel.didFontSelect = { [weak self] fontName in
            guard let self = self else { return }
            self.eventTriggered?(.didFontSelect(fontName))
            self.dismiss(animated: true)
        }
    }

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {
        customView.tableView.rowHeight = UITableView.automaticDimension
        customView.tableView.estimatedRowHeight = 44
        customView.tableView.allowsMultipleSelection = true
        customView.tableView.dataSource = viewModel
        customView.tableView.delegate = viewModel
    }

    /// Set up top navigation bar buttons
    private func setupBarButtons() {
        let cancelBarButton = UIBarButtonItem(title: Localizable.FontPickerViewController.cancelButton.text, style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        navigationItem.rightBarButtonItem = cancelBarButton
    }

    /// Action triggered after tapping cancel bar button
    @objc private func cancelBarButtonTapped() {
        dismiss(animated: true)
    }
}

private extension Localizable {
    enum FontPickerViewController: String, Localized {
        case title
        case cancelButton
    }
}
