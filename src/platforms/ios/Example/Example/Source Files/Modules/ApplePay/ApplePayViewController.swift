//
//  ApplePayViewController.swift
//  Example
//

import PassKit

final class ApplePayViewController: BaseViewController<ApplePayView, ApplePayViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case transactionCompleted
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        customView.payButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            guard let request = self.viewModel.applePayRequest else { return }
            guard let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
            applePayVC.delegate = self
            self.present(applePayVC, animated: true)
        }

        viewModel.handleResponseClosure = { [weak self] jwt, _, error in
            guard let self = self else { return }
            guard let error = error else {
                guard let tpResponses = try? TPHelper.getTPResponses(jwt: jwt) else { return }
                guard let firstTPError = tpResponses.compactMap(\.tpError).first else {
                    self.showAlert(message: Localizable.Alerts.successfulPayment.text) { [weak self] _ in
                        guard let self = self else { return }
                        self.eventTriggered?(.transactionCompleted)
                    }
                    return
                }

                if case let TPError.invalidField(errorCode, _) = firstTPError {
                    switch errorCode {
                    case .invalidPAN:
                        AppLog.log("Most likely the payment token from Apple Pay is empty. Make sure to run this example on a physical device")
                    default: break
                    }
                }

                self.showAlert(message: firstTPError.humanReadableDescription, completionHandler: nil)
                return
            }

            self.showAlert(message: error.humanReadableDescription, completionHandler: nil)
        }
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

// MARK: PKPaymentAuthorizationViewControllerDelegate

extension ApplePayViewController: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler _: @escaping (PKPaymentAuthorizationResult) -> Void) {
        viewModel.performRequest(with: payment)
        controller.dismiss(animated: true)
    }
}
