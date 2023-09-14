//
//  MainViewController.swift
//  Example
//

import TrustPaymentsCore
import UIKit

final class MainViewController: BaseViewController<MainView, MainViewModel> {
    /// Enum describing events that can be triggered by this controller
    // swiftlint:disable identifier_name
    enum Event {
        case didTapShowSingleInputViews
        case didTapShowDropInController(String, TPAPMConfiguration?)
        case didTapAddCard(String)
        case payWithWalletRequest
        case didTapPresentWalletWithCardTypesToBypass
        case didTapShowDropInControllerNoThreeDQuery(String, TPAPMConfiguration?)
        case didTapShowDropInControllerWithCustomView(String)
        case didTapShowDropInControllerSaveCardFillCVV(String)
        case didTapPayByCustomForm(String)
        case didTapShowDropInControllerWithApplePay(String, TPApplePayConfiguration?)
        case didTapShowDropInWithApplePayAndTypeDescriptions
        case didTapShowDropInControllerWithCustomViewAndTip(Int, String)
        case didTapShowDropInControllerWithRiskDec(String)
        case didTapShowDropInControllerWithJWTUpdates(Int, String)
        case didTapShowMerchantApplePay
        case didTapShowDropInControllerWithCardTypesToBypass
        case didTapShowDropInControllerWithZIP(String, TPAPMConfiguration?)
        case didTapShowDropInControllerWithATA(String, TPAPMConfiguration?)
        case didTapShowStyleManagerInitializationView(String)
        case didTapShowDarkModeStyleManagerInitializationView(String)
    }

    // swiftlint:enable identifier_name

    private var transparentNavigationBar: TransparentNavigationBar? { navigationController?.navigationBar as? TransparentNavigationBar }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        view.accessibilityIdentifier = "home/view/main"

        // Trust Payments logo in navigation bar
        let imageView = UIImageView(image: UIImage(named: "trustPaymentsLogo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView

        customView.dataSource = viewModel
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    // swiftlint:disable cyclomatic_complexity
    override func setupCallbacks() {
        customView.makeAuthRequestButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.viewModel.makeAuthCall()
        }
        customView.showSingleInputViewsButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapShowSingleInputViews)
        }
        customView.showDropInControllerButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            let apmsConfiguration = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 10, zipMaxAmount: 100)
            self.eventTriggered?(.didTapShowDropInController(jwt, apmsConfiguration))
        }
        customView.accountCheckRequest = { [weak self] in
            guard let self = self else { return }
            self.viewModel.makeAccountCheckRequest()
        }
        customView.accountCheckWithAuthRequest = { [weak self] in
            guard let self = self else { return }
            self.viewModel.makeAccountCheckWithAuthRequest()
        }
        customView.addCardReferenceRequest = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.accountCheck], storeCard: true) else { return }
            self.eventTriggered?(.didTapAddCard(jwt))
        }
        customView.payWithWalletRequest = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.payWithWalletRequest)
        }
        customView.presentWalletWithCardTypesToBypass = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapPresentWalletWithCardTypesToBypass)
        }
        customView.showDropInControllerNoThreeDQuery = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.auth]) else { return }
            let apmConfiguration = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 10, zipMaxAmount: 100)
            self.eventTriggered?(.didTapShowDropInControllerNoThreeDQuery(jwt, apmConfiguration))
        }
        customView.showDropInControllerWithCustomView = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            self.eventTriggered?(.didTapShowDropInControllerWithCustomView(jwt))
        }
        customView.payByCardFromParentReference = { [weak self] in
            guard let self = self else { return }
            self.viewModel.payByCardFromParentReference()
        }
        customView.subscriptionOnTPEngineRequest = { [weak self] in
            self?.viewModel.performSubscriptionOnTPEngine()
        }
        customView.subscriptionOnMerchantEngineRequest = { [weak self] in
            self?.viewModel.performSubscriptionOnMerchantEngine()
        }
        customView.showMoreInformation = { [weak self] infoString in
            self?.showAlert(message: infoString)
        }
        customView.payFillCVV = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithParentReference(typeDescriptions: [.threeDQuery, .auth]) else { return }
            self.eventTriggered?(.didTapShowDropInControllerSaveCardFillCVV(jwt))
        }
        customView.payByCustomForm = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            self.eventTriggered?(.didTapPayByCustomForm(jwt))
        }
        customView.showDropInControllerWithApplePay = { [weak self] in
            guard let self = self else { return }
            guard let data = self.viewModel.getApplePayJWTAndConfiguration(typeDescriptions: [.threeDQuery, .auth]) else { return }
            self.eventTriggered?(.didTapShowDropInControllerWithApplePay(data.jwt, data.config))
        }
        customView.applePayWithTypeDescriptionSelection = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapShowDropInWithApplePayAndTypeDescriptions)
        }
        customView.showDropInControllerWithCustomViewAndTip = { [weak self] in
            guard let self = self else { return }
            let baseAmount = 1050
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth], baseAmount: baseAmount) else { return }
            self.eventTriggered?(.didTapShowDropInControllerWithCustomViewAndTip(baseAmount, jwt))
        }
        customView.showDropInControllerWithRiskDec = { [weak self] in
            guard let self = self else { return }
            self.showAlertWithTextField(message: Localizable.MainViewController.enterBaseAmount.text) { baseAmount in
                guard let baseAmount = baseAmount, let intBaseAmount = Int(baseAmount) else { return }
                guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth, .riskDec], baseAmount: intBaseAmount) else { return }
                self.eventTriggered?(.didTapShowDropInControllerWithRiskDec(jwt))
            }
        }
        customView.showDropInControllerWithJWTUpdates = { [weak self] in
            guard let self = self else { return }
            let baseAmount = 1050
            guard let jwt = self.viewModel.getJwtTokenWithPayloadParameters(typeDescriptions: [.threeDQuery, .auth], baseAmount: baseAmount) else { return }
            self.eventTriggered?(.didTapShowDropInControllerWithJWTUpdates(baseAmount, jwt))
        }
        customView.showDropInControllerWithCardTypesToBypass = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapShowDropInControllerWithCardTypesToBypass)
        }
        customView.showDropInControllerWithZIP = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            let apmsConfiguration = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 10, zipMaxAmount: 100)
            self.eventTriggered?(.didTapShowDropInControllerWithZIP(jwt, apmsConfiguration))
        }
        customView.showDropInControllerWithATA = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            let apmsConfiguration = TPAPMConfiguration(supportedAPMs: [.ata])
            self.eventTriggered?(.didTapShowDropInControllerWithATA(jwt, apmsConfiguration))
        }
        customView.showMerchantApplePay = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapShowMerchantApplePay)
        }
        customView.showStyleManagerInitializationView = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            self.eventTriggered?(.didTapShowStyleManagerInitializationView(jwt))
        }
        customView.showDarkModeStyleManagerInitializationView = { [weak self] in
            guard let self = self else { return }
            guard let jwt = self.viewModel.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth]) else { return }
            self.eventTriggered?(.didTapShowDarkModeStyleManagerInitializationView(jwt))
        }
        customView.performThreeDQueryV2AndLaterAuth = { [weak self] in
            self?.viewModel.performRequestWithTypeDescriptionsAndLaterAuth(typeDescriptions: [.threeDQuery], isThreeDVersionOne: false)
        }
        customView.performThreeDQueryV1AndLaterAuth = { [weak self] in
            self?.viewModel.performRequestWithTypeDescriptionsAndLaterAuth(typeDescriptions: [.threeDQuery], isThreeDVersionOne: true)
        }
        customView.performAccountCheckThreeDQueryV2AndLaterAuth = {
            self.viewModel.performRequestWithTypeDescriptionsAndLaterAuth(typeDescriptions: [.accountCheck, .threeDQuery], isThreeDVersionOne: false)
        }
        customView.performAccountCheckThreeDQueryV1AndLaterAuth = {
            self.viewModel.performRequestWithTypeDescriptionsAndLaterAuth(typeDescriptions: [.accountCheck, .threeDQuery], isThreeDVersionOne: true)
        }
        customView.performAuthZIP = { [weak self] in
            guard let self = self else { return }
            self.viewModel.performAuthUsingAPM(.zip)
        }
        customView.performAuthATA = { [weak self] in
            guard let self = self else { return }
            self.viewModel.performAuthUsingAPM(.ata)
        }

        viewModel.showAuthSuccess = { [weak self] _ in
            guard let self = self else { return }
            self.customView.showLoader(show: false)
            self.showAlert(message: "successful payment")
        }

        viewModel.showRequestSuccess = { [weak self] _ in
            guard let self = self else { return }
            self.customView.showLoader(show: false)
            self.showAlert(message: "The request has been successfully completed")
        }

        viewModel.showAuthError = { [weak self] error in
            guard let self = self else { return }
            self.customView.showLoader(show: false)
            self.showAlert(message: error)
        }

        viewModel.showLoader = { [weak self] show in
            guard let self = self else { return }
            self.customView.showLoader(show: show)
        }

        StyleManager.shared.highlightViewsValueChanged = { [weak self] _ in
            self?.customView.highlightIfNeeded(unhighlightColor: UIColor.clear, unhighlightBorderWith: 0)
        }
    }

    // swiftlint:enable cyclomatic_complexity

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {}

    // MARK: Helpers

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizable.Alerts.okButton.text, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func showAlertWithTextField(message: String, completionHandler: ((String?) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = "1050"
            textField.keyboardType = .numberPad
        }

        alert.addAction(
            UIAlertAction(
                title: Localizable.Alerts.okButton.text,
                style: .default,
                handler: { [weak alert] _ in
                    let textField = alert?.textFields?[0]
                    completionHandler?(textField?.text)
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }
}

private extension Localizable {
    enum MainViewController: String, Localized {
        case title
        case enterBaseAmount
    }
}
