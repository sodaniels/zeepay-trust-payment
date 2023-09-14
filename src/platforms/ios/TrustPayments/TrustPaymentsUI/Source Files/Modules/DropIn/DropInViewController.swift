//
//  DropInViewController.swift
//  TrustPaymentsUI
//

#if !COCOAPODS
    import TrustPayments3DSecure
    import TrustPaymentsCore
#endif
import UIKit

@objc public protocol DropInController: UIPresentable {
    @objc var viewController: UIViewController { get }
    @objc var viewInstance: DropInViewProtocol { get }
    @objc func updateJWT(newValue: String)
    @objc func `continue`()
}

final class DropInViewController: BaseViewController<DropInViewProtocol, DropInViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case transactionResponseClosure([String], TPAdditionalTransactionResult?, APIClientError?)
        case payButtonTappedClosureBeforeTransaction(DropInController)
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    var keyboard = KeyboardHelper()
    lazy var screenshot = ScreenshotHelper(topView: self.view)

    private let semaphore = DispatchSemaphore(value: 0)

    // MARK: Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenshot.register(coveringStyle: .image(view.asHierarchyImage()))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screenshot.unregister()
    }

    deinit {
        keyboard.unregister()
    }

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        customView.setupView { [weak self] view in
            guard let self = self else { return }
            guard let dropInView = view as? DropInView else { return }
            dropInView.cardNumberInput.isHidden = self.viewModel.isCardNumberFieldHidden
            dropInView.cvvInput.isHidden = self.viewModel.isCVVFieldHidden
            dropInView.expiryDateInput.isHidden = self.viewModel.isExpiryDateFieldHidden
            dropInView.payButton.isHidden = self.viewModel.isPayButtonHidden
            dropInView.applePayButton = self.viewModel.applePayConfiguration?.payButton
            dropInView.zipButton.isHidden = self.viewModel.isZipButtonHidden
            dropInView.ataButton.isHidden = self.viewModel.isATAButtonHidden
            (dropInView.cvvInput as? CVVInputView)?.cardType = self.viewModel.cardType
            dropInView.applePayButton?.accessibilityIdentifier = "applePay"
        }
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

                let dispatchQueue = DispatchQueue(label: "payButtonTappedClosureBeforeTransaction")
                dispatchQueue.async { [unowned self] in
                    DispatchQueue.main.async {
                        self.eventTriggered?(.payButtonTappedClosureBeforeTransaction(self))
                    }

                    self.semaphore.wait()

                    DispatchQueue.main.async {
                        self.viewModel.performTransaction(cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate)
                    }
                }
            }
        }
        customView.applePayButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.viewModel.performApplePayAuthorization()
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

        viewModel.transactionResponseClosure = { [weak self] jwt, transactionResult, error in
            guard let self = self else { return }
            self.customView.payButton.stopProcessing()
            self.customView.zipButton.stopProcessing()
            self.customView.ataButton.stopProcessing()
            self.eventTriggered?(.transactionResponseClosure(jwt, transactionResult, error))
        }
    }

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {
        keyboard.register(target: self)
    }
}

// MARK: Handling appearance/disappearance of keyboard

extension DropInViewController: KeyboardHelperDelegate {
    func keyboardChanged(size: CGSize, animationDuration: TimeInterval, isHidden: Bool) {
        (customView as? DropInView)?.adjustContentInsets(
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

extension DropInViewController: DropInController {
    var viewController: UIViewController {
        self
    }

    var viewInstance: DropInViewProtocol {
        customView
    }

    func updateJWT(newValue: String) {
        viewModel.updateJWT(newValue: newValue)
    }

    func `continue`() {
        semaphore.signal()
    }
}
