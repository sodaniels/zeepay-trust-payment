//
//  SelectTypeDescriptionsViewController.swift
//  Example
//

import UIKit

final class SelectTypeDescriptionsViewController: BaseViewController<SelectTypeDescriptionsView, SelectTypeDescriptionsViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case didTapNextButton([TypeDescription])
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = Localizable.SelectTypeDescriptionsViewController.title.text
        customView.tableView.register(dequeueableCell: TypeDescriptionsCell.self)
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        customView.nextButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            let selectedTypeDescriptions = self.viewModel.selectedTypeDescriptions.flatMap(\.typeDescriptions)
            self.eventTriggered?(.didTapNextButton(selectedTypeDescriptions))
        }

        viewModel.didToggleSelection = { [weak self] nextButtonShouldBeEnabled in
            guard let self = self else { return }
            self.customView.nextButton.isEnabled = nextButtonShouldBeEnabled
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
}

private extension Localizable {
    enum SelectTypeDescriptionsViewController: String, Localized {
        case title
    }
}
