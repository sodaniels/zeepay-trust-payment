//
//  SelectCardTypesViewController.swift
//  Example
//

import UIKit

final class SelectCardTypesViewController: BaseViewController<SelectCardTypesView, SelectCardTypesViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case didTapNextButton([CardType])
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = Localizable.SelectCardTypesViewController.title.text
        customView.tableView.register(dequeueableCell: CardTypeCell.self)
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        customView.nextButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            let selectedCardTypes = self.viewModel.selectedCardTypes.map(\.cardType)
            self.eventTriggered?(.didTapNextButton(selectedCardTypes))
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
        customView.tableView.accessibilityIdentifier = "supportedCardTypes"
    }
}

private extension Localizable {
    enum SelectCardTypesViewController: String, Localized {
        case title
    }
}
