//
//  WalletViewController.swift
//  Example
//

import UIKit

final class WalletViewController: BaseViewController<WalletView, WalletViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case didTapNextButton(CardType)
        case didTapAddPaymentMethod
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = Localizable.WalletViewController.title.text
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        customView.nextButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            guard let cardType = self.viewModel.getSelectedCardType else { return }
            self.eventTriggered?(.didTapNextButton(cardType))
        }

        customView.cardFromWalletSelected = { [weak self] card in
            guard let self = self else { return }
            self.viewModel.cardSelected(card)
        }

        customView.cardFromWalletRemoved = { [weak self] card in
            guard let self = self else { return }
            self.viewModel.cardRemoved(card)
        }

        customView.addNewPaymentMethod = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapAddPaymentMethod)
        }
    }

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {}

    /// Reloads tableView with newly added card reference
    /// - Parameter cardReference: new card reference
    func reloadCards(cardReference: TPCardReference?) {
        viewModel.addNewCard(cardReference)
        customView.reloadCards()
    }
}

private extension Localizable {
    enum WalletViewController: String, Localized {
        case title
    }
}
