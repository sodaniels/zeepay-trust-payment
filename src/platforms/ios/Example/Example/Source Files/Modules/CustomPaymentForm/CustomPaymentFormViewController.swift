//
//  CustomPaymentFormViewController.swift
//  Example
//

import UIKit

final class CustomPaymentFormViewController: BaseViewController<CustomPaymentFormView, CustomPaymentFormViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case transactionCompleted
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    var keyboard = KeyboardHelper()

    // MARK: Lifecycle

    deinit {
        keyboard.unregister()
    }

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = Localizable.CustomPaymentFormViewController.title.text
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        customView.payButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            let isFormValid = self.viewModel.validateForm(view: self.customView)
            if isFormValid {
                self.customView.payButton.startProcessing()
                let cardNumber = self.customView.cardNumberInput.cardNumber
                let cvv = self.customView.cvvInput.cvv
                let expiryDate = self.customView.expiryDateInput.expiryDate

                self.viewModel.performTransaction(cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate)
            }
        }
        customView.zipButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.customView.zipButton.startProcessing()
            self.viewModel.performZIPTransaction()
        }
        customView.ataButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.customView.ataButton.startProcessing()
            self.viewModel.performATATransaction()
        }

        viewModel.handleResponseClosure = { [weak self] jwt, _, error in
            guard let self = self else { return }
            self.customView.payButton.stopProcessing()
            self.customView.zipButton.stopProcessing()
            self.customView.ataButton.stopProcessing()
            guard let error = error else {
                guard let tpResponses = try? TPHelper.getTPResponses(jwt: jwt) else { return }
                guard let firstTPError = tpResponses.compactMap(\.tpError).first else {
                    self.showAlert(message: Localizable.CustomPaymentFormViewController.successfulPayment.text) { [weak self] _ in
                        guard let self = self else { return }
                        self.eventTriggered?(.transactionCompleted)
                    }
                    return
                }

                if case let TPError.invalidField(errorCode, _) = firstTPError {
                    switch errorCode {
                    case .invalidPAN: self.customView.cardNumberInput.showHideError(show: true)
                    case .invalidCVV: self.customView.cvvInput.showHideError(show: true)
                    case .invalidExpiryDate: self.customView.expiryDateInput.showHideError(show: true)
                    default: break
                    }
                }

                self.showAlert(message: firstTPError.humanReadableDescription, completionHandler: nil)
                return
            }

            self.showAlert(message: error.humanReadableDescription, completionHandler: nil)
        }
    }

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {
        keyboard.register(target: self)
    }

    // MARK: Alerts

    /// shows an alert
    /// - Parameters:
    ///   - message: alert message
    ///   - completionHandler: Closure triggered when the alert button is pressed
    private func showAlert(message: String, completionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizable.Alerts.okButton.text, style: .default, handler: completionHandler))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Handling appearance/disappearance of keyboard

extension CustomPaymentFormViewController: KeyboardHelperDelegate {
    func keyboardChanged(size: CGSize, animationDuration: TimeInterval, isHidden: Bool) {
        customView.adjustContentInsets(
            UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: isHidden ? 0 : size.height,
                right: 0
            )
        )
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

private extension Localizable {
    enum CustomPaymentFormViewController: String, Localized {
        case title
        case successfulPayment
    }
}
