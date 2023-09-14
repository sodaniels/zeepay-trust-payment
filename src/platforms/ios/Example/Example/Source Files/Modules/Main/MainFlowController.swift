//
//  MainFlowController.swift
//  Example
//

import TrustPayments3DSecure
import TrustPaymentsCard
import TrustPaymentsCore
import TrustPaymentsUI
import UIKit

enum CustomViewType {
    case saveCard
    case addTip
    case jwtUpdates
}

// swiftlint:disable type_body_length
final class MainFlowController: BaseNavigationFlowController {
    // MARK: - Properties:

    private var mainViewModel: MainViewModel?

    // MARK: Initalization

    /// Initializes an instance of the receiver.
    ///
    /// - Parameter appFoundation: Provides easy access to common dependencies
    override init(appFoundation: AppFoundation) {
        super.init(appFoundation: appFoundation)
        set(setupMainScreen())
    }

    // MARK: Functions

    /// Function called to setup Main Screen
    ///
    /// - Returns: Object of MainViewController
    // swiftlint:disable cyclomatic_complexity
    private func setupMainScreen() -> UIViewController {
        let viewItems = [
            MainViewModel.Section.onSDK(rows:
                [
                    MainViewModel.Row.performAuthRequestInBackground,
                    MainViewModel.Row.presentSingleInputComponents,
                    MainViewModel.Row.presentPayByCardForm,
                    MainViewModel.Row.showDropInControllerNo3DSecure,
                    MainViewModel.Row.showDropInControllerWithCustomView,
                    MainViewModel.Row.payByCardFromParentReference,
                    MainViewModel.Row.performAccountCheck,
                    MainViewModel.Row.performAccountCheckWithAuth,
                    MainViewModel.Row.subscriptionOnTPEngine,
                    MainViewModel.Row.subscriptionOnMerchantEngine,
                    MainViewModel.Row.payFillCVV,
                    MainViewModel.Row.showDropInControllerWithRiskDec,
                    MainViewModel.Row.showDropInControllerWithCustomViewAndTip,
                    MainViewModel.Row.applePay,
                    MainViewModel.Row.applePayWithTypeDescriptionSelection,
                    MainViewModel.Row.showDropInControllerWithJWTUpdates,
                    MainViewModel.Row.dropInControllerWithCardTypesToBypass,
                    MainViewModel.Row.showDropInControllerWithZIP,
                    MainViewModel.Row.showDropInControllerWithATA,
                    MainViewModel.Row.showStyleManagerInitView,
                    MainViewModel.Row.showDarkModeStyleManagerInitView,
                    MainViewModel.Row.performThreeDQueryV2AndLaterAuth,
                    MainViewModel.Row.performThreeDQueryV1AndLaterAuth,
                    MainViewModel.Row.performAccountCheckThreeDQueryV2AndLaterAuth,
                    MainViewModel.Row.performAccountCheckThreeDQueryV1AndLaterAuth,
                    MainViewModel.Row.performAuthZIP,
                    MainViewModel.Row.performAuthATA
                ]),
            MainViewModel.Section.onMerchant(rows:
                [
                    MainViewModel.Row.presentWalletForm,
                    MainViewModel.Row.presentWalletWithCardTypesToBypass,
                    MainViewModel.Row.presentAddCardForm,
                    MainViewModel.Row.payByCustomForm,
                    MainViewModel.Row.merchantApplePay
                ])
        ]
        do {
            mainViewModel = MainViewModel(transactionManager: nil, items: viewItems)
        } catch {
            AppLog.log(error.localizedDescription)
            mainViewModel = MainViewModel(transactionManager: nil, items: viewItems)
        }
        let mainViewController = MainViewController(view: MainView(), viewModel: mainViewModel!)
        mainViewController.eventTriggered = { [unowned self] event in
            switch event {
            case .didTapShowSingleInputViews:
                self.showSingleInputViewsScreen()
            case let .didTapShowDropInController(jwt, apmsConfiguration):
                self.showDropInViewController(jwt: jwt, customViewType: nil, apmsConfiguration: apmsConfiguration)
            case let .didTapShowDropInControllerNoThreeDQuery(jwt, apmConfiguration):
                self.showDropInViewController(jwt: jwt, customViewType: nil, apmsConfiguration: apmConfiguration)
            case let .didTapAddCard(jwt):
                self.showAddCardView(jwt: jwt)
            case .payWithWalletRequest:
                self.showWalletView(isCardTypesBypassFlow: false)
            case .didTapPresentWalletWithCardTypesToBypass:
                self.showCardTypesSelection(nextButtonShouldBeEnabled: true) { [unowned self] cardTypes in
                    self.showWalletView(cardTypesToBypass: cardTypes, isCardTypesBypassFlow: true)
                }
            case let .didTapShowDropInControllerWithCustomView(jwt):
                self.showDropInViewController(jwt: jwt, customViewType: .saveCard, apmsConfiguration: nil)
            case let .didTapShowDropInControllerSaveCardFillCVV(jwt):
                self.showDropInViewController(jwt: jwt, customViewType: nil, visibleFields: [.cvv3])
            case let .didTapPayByCustomForm(jwt):
                self.showCustomForm(jwt: jwt)
            case let .didTapShowDropInControllerWithApplePay(jwt, applePayConfig):
                self.showDropInViewController(jwt: jwt, customViewType: nil, applePayConfiguration: applePayConfig)
            case .didTapShowDropInWithApplePayAndTypeDescriptions:
                self.showTypeDescriptionsSelection(excluding: [[.accountCheck]]) { [unowned self] typeDescriptions in
                    var jwt: String!
                    let applePayConfig: TPApplePayConfiguration?
                    if typeDescriptions.contains(.subscription) {
                        let data = self.mainViewModel?.getApplePayJWTAndConfiguration(typeDescriptions: typeDescriptions, shouldAddSubscriptionData: true)
                        jwt = data?.jwt
                        applePayConfig = data?.config
                    } else {
                        let data = self.mainViewModel?.getApplePayJWTAndConfiguration(typeDescriptions: typeDescriptions, shouldAddSubscriptionData: false)
                        jwt = data?.jwt
                        applePayConfig = data?.config
                    }
                    self.showDropInViewController(jwt: jwt, customViewType: nil, applePayConfiguration: applePayConfig)
                }
            case let .didTapShowDropInControllerWithCustomViewAndTip(baseAmount, jwt):
                self.showDropInViewController(baseAmount: baseAmount, jwt: jwt, customViewType: .addTip)
            case let .didTapShowDropInControllerWithRiskDec(jwt):
                self.showDropInViewController(jwt: jwt, customViewType: nil)
            case let .didTapShowDropInControllerWithJWTUpdates(baseAmount, jwt):
                self.showDropInViewController(baseAmount: baseAmount, jwt: jwt, customViewType: .jwtUpdates)
            case .didTapShowMerchantApplePay:
                self.showMerchantApplePay()
            case .didTapShowDropInControllerWithCardTypesToBypass:
                self.showCardTypesSelection(nextButtonShouldBeEnabled: false) { [unowned self] cardTypes in
                    guard let jwt = self.mainViewModel?.getJwtTokenWithoutCardData(typeDescriptions: [.threeDQuery, .auth, .riskDec], cardTypesToBypass: cardTypes) else { return }
                    self.showDropInViewController(jwt: jwt, customViewType: nil)
                }
            case let .didTapShowDropInControllerWithZIP(jwt, apmConfiguration):
                self.showDropInViewController(jwt: jwt, customViewType: nil, apmsConfiguration: apmConfiguration)
            case let .didTapShowDropInControllerWithATA(jwt, apmConfiguration):
                self.showDropInViewController(jwt: jwt, customViewType: nil, apmsConfiguration: apmConfiguration)
            case let .didTapShowStyleManagerInitializationView(jwt):
                self.showStyleManagerInitializationView(jwt: jwt, isDarkModeConfiguration: false)
            case let .didTapShowDarkModeStyleManagerInitializationView(jwt):
                self.showStyleManagerInitializationView(jwt: jwt, isDarkModeConfiguration: true)
            }
        }
        return mainViewController
    }

    // swiftlint:enable cyclomatic_complexity

    func showSingleInputViewsScreen() {
        let inputViewStyleManager = InputViewStyleManager.defaultLight()

        let inputViewDarkModeStyleManager = InputViewStyleManager(titleColor: UIColor.white,
                                                                  textFieldBorderColor: UIColor.white.withAlphaComponent(0.8),
                                                                  textFieldBackgroundColor: .clear,
                                                                  textColor: .white,
                                                                  placeholderColor: UIColor.white.withAlphaComponent(0.8),
                                                                  errorColor: UIColor.red,
                                                                  textFieldImageColor: .white,
                                                                  titleFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                  textFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                  placeholderFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                  errorFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                                  textFieldImage: nil,
                                                                  titleSpacing: 5,
                                                                  errorSpacing: 3,
                                                                  textFieldHeightMargins: HeightMargins(top: 10, bottom: 10),
                                                                  textFieldBorderWidth: 1,
                                                                  textFieldCornerRadius: 6)
        // swiftlint:enable line_length
        let vc = SingleInputViewsController(view: SingleInputView(inputViewStyleManager: inputViewStyleManager, darkModeInputViewStyleManager: inputViewDarkModeStyleManager), viewModel: SingleInputViewsModel())
        push(vc, animated: true)
    }

    // swiftlint:disable cyclomatic_complexity
    func showDropInViewController(baseAmount: Int? = nil, jwt: String, customViewType: CustomViewType?, visibleFields: [DropInViewVisibleFields] = DropInViewVisibleFields.default, applePayConfiguration: TPApplePayConfiguration? = nil, apmsConfiguration: TPAPMConfiguration? = nil, stylesManagerConfiguration: StylesManagerConfiguration? = nil, darkModeStylesManagerConfiguration: StylesManagerConfiguration? = nil) {
        // swiftlint:disable line_length
        let inputViewStyleManager = stylesManagerConfiguration?.inputViewStyleManager ?? InputViewStyleManager.defaultLight()

        let payButtonStyleManager = stylesManagerConfiguration?.payButtonStyleManager ?? PayButtonStyleManager.defaultLight()

        let dropInViewStyleManager = stylesManagerConfiguration?.dropInViewStyleManager ?? DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager,
                                                                                                                  requestButtonStyleManager: payButtonStyleManager,
                                                                                                                  zipButtonStyleManager: ZIPButtonStyleManager.light(),
                                                                                                                  ataButtonStyleManager: ATAButtonStyleManager.light(),
                                                                                                                  backgroundColor: .white,
                                                                                                                  spacingBetweenInputViews: 25,
                                                                                                                  insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35))

        let inputViewDarkModeStyleManager = darkModeStylesManagerConfiguration?.inputViewStyleManager ?? InputViewStyleManager.defaultDark()

        let payButtonDarkModeStyleManager = darkModeStylesManagerConfiguration?.payButtonStyleManager ?? PayButtonStyleManager.defaultDark()

        let dropInViewDarkModeStyleManager = darkModeStylesManagerConfiguration?.dropInViewStyleManager ?? DropInViewStyleManager(inputViewStyleManager: inputViewDarkModeStyleManager,
                                                                                                                                  requestButtonStyleManager: payButtonDarkModeStyleManager,
                                                                                                                                  zipButtonStyleManager: ZIPButtonStyleManager.dark(),
                                                                                                                                  ataButtonStyleManager: ATAButtonStyleManager.dark(),
                                                                                                                                  backgroundColor: .black,
                                                                                                                                  spacingBetweenInputViews: 25,
                                                                                                                                  insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35))

        let toolbarStyleManager = stylesManagerConfiguration?.toolbarStyleManager ?? CardinalToolbarStyleManager(textColor: .black, textFont: nil, backgroundColor: .white, headerText: "Trust payment checkout", buttonText: nil)
        let labelStyleManager = stylesManagerConfiguration?.labelStyleManager ?? CardinalLabelStyleManager(textColor: .gray, textFont: nil, headingTextColor: .black, headingTextFont: nil)

        let verifyButtonStyleManager = stylesManagerConfiguration?.verifyButtonStyleManager ?? CardinalButtonStyleManager(textColor: .white, textFont: nil, backgroundColor: .black, cornerRadius: 6)
        let continueButtonStyleManager = stylesManagerConfiguration?.continueButtonStyleManager ?? CardinalButtonStyleManager(textColor: .white, textFont: nil, backgroundColor: .black, cornerRadius: 6)
        let resendButtonStyleManager = stylesManagerConfiguration?.resendButtonStyleManager ?? CardinalButtonStyleManager(textColor: .black, textFont: nil, backgroundColor: nil, cornerRadius: 0)
        let textBoxStyleManager = stylesManagerConfiguration?.textBoxStyleManager ?? CardinalTextBoxStyleManager(textColor: .black, textFont: nil, borderColor: .black, cornerRadius: 6, borderWidth: 1)

        let cardinalStyleManager = CardinalStyleManager(toolbarStyleManager: toolbarStyleManager,
                                                        labelStyleManager: labelStyleManager,
                                                        verifyButtonStyleManager: verifyButtonStyleManager,
                                                        continueButtonStyleManager: continueButtonStyleManager,
                                                        resendButtonStyleManager: resendButtonStyleManager,
                                                        textBoxStyleManager: textBoxStyleManager)

        let toolbarDarkModeStyleManager = darkModeStylesManagerConfiguration?.toolbarStyleManager ?? CardinalToolbarStyleManager(textColor: .white, textFont: nil, backgroundColor: .black, headerText: "Trust payment checkout", buttonText: nil)
        let labelDarkModeStyleManager = darkModeStylesManagerConfiguration?.labelStyleManager ?? CardinalLabelStyleManager(textColor: .gray, textFont: nil, headingTextColor: .white, headingTextFont: nil)

        let verifyButtonDarkModeStyleManager = darkModeStylesManagerConfiguration?.verifyButtonStyleManager ?? CardinalButtonStyleManager(textColor: .black, textFont: nil, backgroundColor: .white, cornerRadius: 6)
        let continueButtonDarkModeStyleManager = darkModeStylesManagerConfiguration?.continueButtonStyleManager ?? CardinalButtonStyleManager(textColor: .black, textFont: nil, backgroundColor: .white, cornerRadius: 6)
        let resendButtonDarkModeStyleManager = darkModeStylesManagerConfiguration?.resendButtonStyleManager ?? CardinalButtonStyleManager(textColor: .white, textFont: nil, backgroundColor: nil, cornerRadius: 0)
        let textBoxDarkModeStyleManager = darkModeStylesManagerConfiguration?.textBoxStyleManager ?? CardinalTextBoxStyleManager(textColor: .white, textFont: nil, borderColor: .white, cornerRadius: 6, borderWidth: 1)

        let cardinalDarkModeStyleManager = CardinalStyleManager(toolbarStyleManager: toolbarDarkModeStyleManager,
                                                                labelStyleManager: labelDarkModeStyleManager,
                                                                verifyButtonStyleManager: verifyButtonDarkModeStyleManager,
                                                                continueButtonStyleManager: continueButtonDarkModeStyleManager,
                                                                resendButtonStyleManager: resendButtonDarkModeStyleManager,
                                                                textBoxStyleManager: textBoxDarkModeStyleManager)

        // custom view provided from example app
        var customDropInView: DropInViewProtocol?

        switch customViewType {
        case .saveCard:
            customDropInView = DropInCustomViewWithSaveCardOption(dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager)
        case .addTip:
            customDropInView = DropInCustomViewWithTipOption(dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager, tipAmount: 150, baseAmount: baseAmount ?? 1050)
        case .jwtUpdates:
            customDropInView = DropInCustomViewWithPayloadParameters(dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager, baseAmount: baseAmount ?? 1050)
        case .none:
            break
        }
        do {
            let dropInVC = try ViewControllerFactory.shared.dropInViewController(jwt: jwt,
                                                                                 customDropInView: customDropInView,
                                                                                 visibleFields: visibleFields,
                                                                                 applePayConfiguration: applePayConfiguration,
                                                                                 apmsConfiguration: apmsConfiguration,
                                                                                 dropInViewStyleManager: dropInViewStyleManager,
                                                                                 dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager,
                                                                                 cardinalStyleManager: cardinalStyleManager,
                                                                                 cardinalDarkModeStyleManager: cardinalDarkModeStyleManager,
                                                                                 payButtonTappedClosureBeforeTransaction: { [unowned self] controller in

                                                                                     switch customViewType {
                                                                                     case .saveCard:
                                                                                         // updates JWT with credentialsonfile flag
                                                                                         let storeCard = (customDropInView as? DropInCustomViewWithSaveCardOption)!.isSaveCardSelected
                                                                                         guard let requesttypedescriptions = jwt.requesttypedescriptions else { return }
                                                                                         let typeDescriptions = requesttypedescriptions.compactMap { TypeDescription(rawValue: $0) }
                                                                                         guard let updatedJWT = self.mainViewModel?.getJwtTokenWithoutCardData(typeDescriptions: typeDescriptions, storeCard: storeCard, parentTransactionReference: jwt.parentReference) else { return }
                                                                                         // update vc with new jwt
                                                                                         controller.updateJWT(newValue: updatedJWT)
                                                                                     case .addTip:
                                                                                         // updates JWT with base amount
                                                                                         let baseAmount = (customDropInView as? DropInCustomViewWithTipOption)!.baseAmount
                                                                                         guard let requesttypedescriptions = jwt.requesttypedescriptions else { return }
                                                                                         let typeDescriptions = requesttypedescriptions.compactMap { TypeDescription(rawValue: $0) }
                                                                                         guard let updatedJWT = self.mainViewModel?.getJwtTokenWithoutCardData(typeDescriptions: typeDescriptions, parentTransactionReference: jwt.parentReference, baseAmount: baseAmount) else { return }
                                                                                         // update vc with new jwt
                                                                                         controller.updateJWT(newValue: updatedJWT)
                                                                                     case .jwtUpdates:
                                                                                         guard let customDropInViewWithPayloadParameters = customDropInView as? DropInCustomViewWithPayloadParameters else { return }

                                                                                         let isBaseAmountType = customDropInViewWithPayloadParameters.selectedAmountType == .baseAmount
                                                                                         let baseAmount = isBaseAmountType ? Int(customDropInViewWithPayloadParameters.amountValue) : nil
                                                                                         let mainAmount = !isBaseAmountType ? Double(customDropInViewWithPayloadParameters.amountValue) : nil

                                                                                         let currencyValue = customDropInViewWithPayloadParameters.selectedCurrentType.rawValue

                                                                                         let billingData = BillingData(firstName: customDropInViewWithPayloadParameters.billingFirstNameValue,
                                                                                                                       lastName: customDropInViewWithPayloadParameters.billingSecondNameValue,
                                                                                                                       street: customDropInViewWithPayloadParameters.billingAddressValue,
                                                                                                                       town: customDropInViewWithPayloadParameters.billingCityValue,
                                                                                                                       county: customDropInViewWithPayloadParameters.billingCountyValue,
                                                                                                                       countryIso2a: customDropInViewWithPayloadParameters.billingCountryIsoValue,
                                                                                                                       postcode: customDropInViewWithPayloadParameters.billingZipCodeValue)

                                                                                         let deliveryData = DeliveryData(customerprefixname: nil,
                                                                                                                         customerfirstname: customDropInViewWithPayloadParameters.deliveryFirstNameValue,
                                                                                                                         customermiddlename: nil,
                                                                                                                         customerlastname: customDropInViewWithPayloadParameters.deliverySecondNameValue,
                                                                                                                         customersuffixname: nil,
                                                                                                                         customerstreet: customDropInViewWithPayloadParameters.deliveryAddressValue,
                                                                                                                         customertown: customDropInViewWithPayloadParameters.deliveryCityValue,
                                                                                                                         customercounty: customDropInViewWithPayloadParameters.deliveryCountyValue,
                                                                                                                         customercountryiso2a: customDropInViewWithPayloadParameters.deliveryCountryIsoValue,
                                                                                                                         customerpostcode: customDropInViewWithPayloadParameters.deliveryZipCodeValue,
                                                                                                                         customeremail: nil,
                                                                                                                         customertelephone: nil)

                                                                                         guard let requesttypedescriptions = jwt.requesttypedescriptions else { return }
                                                                                         let typeDescriptions = requesttypedescriptions.compactMap { TypeDescription(rawValue: $0) }
                                                                                         guard let updatedJWT = self.mainViewModel?.getJwtTokenWithPayloadParameters(typeDescriptions: typeDescriptions,
                                                                                                                                                                     parentTransactionReference: jwt.parentReference,
                                                                                                                                                                     currency: currencyValue,
                                                                                                                                                                     baseAmount: baseAmount,
                                                                                                                                                                     mainAmount: mainAmount,
                                                                                                                                                                     billingData: billingData,
                                                                                                                                                                     deliveryData: deliveryData) else { return }
                                                                                         // update vc with new jwt
                                                                                         controller.updateJWT(newValue: updatedJWT)
                                                                                     case .none:
                                                                                         break
                                                                                     }

                                                                                     // If this block is handled, further calls in the transaction flow are suspended, which gives the possibility to call asynchronous methods here, e.g. to update the JWT token. To resume operation, call continue() method.
                                                                                     controller.continue()

                                                                                 }, transactionResponseClosure: { [unowned self] jwt, _, error in
                                                                                     let isVerified = !jwt.map { JWTHelper.verifyJwt(jwt: $0, secret: self.appFoundation.keys.jwtSecretKey) }.contains(false)
                                                                                     AppLog.log("JWT verification status: \(isVerified)")
                                                                                     guard let error = error else {
                                                                                         guard let tpResponses = try? TPHelper.getTPResponses(jwt: jwt) else { return }
                                                                                         let cardReference = tpResponses.last?.cardReference
                                                                                         let transactionReference = tpResponses.last?.customerOutput?.transactionReference ?? ""
                                                                                         let tdqTransRef = tpResponses.compactMap { $0.responseObjects.first(where: { $0.requestTypeDescription(contains: TypeDescription.threeDQuery) }) }.first?.transactionReference ?? ""
                                                                                         let riskDecResponse = tpResponses.compactMap { $0.responseObjects.first(where: { $0.requestTypeDescription(contains: TypeDescription.riskDec) }) }.first
                                                                                         guard let firstTPError = tpResponses.compactMap(\.tpError).first else {
                                                                                             AppLog.log("fraudcontrolshieldstatuscode " + (riskDecResponse?.fraudControlShieldStatusCode ?? .empty))
                                                                                             AppLog.log("fraudcontrolresponsecode " + (riskDecResponse?.fraudControlResponseCode ?? .empty))

                                                                                             if (customDropInView as? DropInCustomViewWithSaveCardOption)?.isSaveCardSelected ?? false {
                                                                                                 Wallet.shared.add(card: cardReference)
                                                                                             }
                                                                                             self.showAlert(controller: self.navigationController, title: LocalizableKeys.DropInViewController.successfulPayment.localizedStringOrEmpty, message: "transaction reference: \(transactionReference)") { _ in
                                                                                                 self.navigationController.popViewController(animated: true)
                                                                                             }
                                                                                             return
                                                                                         }

                                                                                         if case let TPError.invalidField(errorCode, localizedError) = firstTPError {
                                                                                             AppLog.log("RESPONSEVALIDATIONERROR.INVALIDFIELD: code: \(errorCode.rawValue), message: \(localizedError ?? errorCode.message)")
                                                                                         }

                                                                                         if case let TPError.gatewayError(errorCode, error) = firstTPError {
                                                                                             AppLog.log("GATEWAYERROR: responseErrorCode: \(errorCode.rawValue)), errorCode: \((error as NSError).code) message: \(error.localizedDescription)")
                                                                                         }

                                                                                         self.showAlert(controller: self.navigationController,
                                                                                                        title: firstTPError.humanReadableDescription,
                                                                                                        message: "transaction reference: \(tdqTransRef)") { _ in }
                                                                                         return
                                                                                     }
                                                                                     self.showAlert(controller: self.navigationController, message: error.humanReadableDescription) { _ in }
                                                                                 })

            push(dropInVC.viewController, animated: true)
        } catch {
            showAlert(controller: navigationController, message: error.localizedDescription, completionHandler: nil)
        }
    }

    // swiftlint:enable cyclomatic_complexity

    func showAddCardView(jwt: String) {
        do {
            let transactionManager = try PaymentTransactionManager(jwt: jwt)

            let inputViewDarkModeStyleManager = InputViewStyleManager.defaultDark()
            inputViewDarkModeStyleManager.titleColor = UIColor.white
            inputViewDarkModeStyleManager.textFieldBorderColor = UIColor.white.withAlphaComponent(0.8)
            inputViewDarkModeStyleManager.textColor = UIColor.white
            inputViewDarkModeStyleManager.placeholderColor = UIColor.white.withAlphaComponent(0.8)
            inputViewDarkModeStyleManager.textFieldImageColor = UIColor.white

            let addCardButtonDarkModeStyleManager = PayButtonStyleManager.defaultDark()
            addCardButtonDarkModeStyleManager.titleColor = UIColor.black
            addCardButtonDarkModeStyleManager.enabledBackgroundColor = UIColor.white
            addCardButtonDarkModeStyleManager.spinnerStyle = .gray
            addCardButtonDarkModeStyleManager.spinnerColor = .black

            let dropInViewDarkModeStyleManager = DropInViewStyleManager(inputViewStyleManager: inputViewDarkModeStyleManager,
                                                                        requestButtonStyleManager: addCardButtonDarkModeStyleManager,
                                                                        zipButtonStyleManager: nil,
                                                                        ataButtonStyleManager: nil,
                                                                        backgroundColor: .black,
                                                                        spacingBetweenInputViews: 25,
                                                                        insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35))

            let inputViewStyleManager = InputViewStyleManager.defaultLight()
            let addCardButtonStyleManager = AddCardButtonStyleManager.default()
            let dropInViewStyleManager = DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager,
                                                                requestButtonStyleManager: addCardButtonStyleManager,
                                                                zipButtonStyleManager: nil,
                                                                ataButtonStyleManager: nil,
                                                                backgroundColor: .white,
                                                                spacingBetweenInputViews: 25,
                                                                insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35))

            let viewController = AddCardViewController(view: AddCardView(dropInViewStyleManager: dropInViewStyleManager, darkModekStyleManager: dropInViewDarkModeStyleManager),
                                                       viewModel: AddCardViewModel(transactionManager: transactionManager,
                                                                                   jwt: jwt))
            viewController.eventTriggered = { [weak self] event in
                switch event {
                case let .added(cardReference):
                    Wallet.shared.add(card: cardReference)
                    if let walletViewController = self?.navigationController.viewControllers.first(where: { $0 is WalletViewController }) as? WalletViewController {
                        walletViewController.reloadCards(cardReference: cardReference)
                        self?.navigationController.popToViewController(ofClass: WalletViewController.self)
                        return
                    }
                    self?.navigationController.popViewController(animated: true)
                }
            }
            push(viewController, animated: true)
        } catch {
            showAlert(controller: navigationController, message: error.localizedDescription, completionHandler: nil)
        }
    }

    func showWalletView(cardTypesToBypass: [CardType]? = nil, isCardTypesBypassFlow: Bool) {
        let cards = Wallet.shared.allCards
        let viewItems = [
            WalletViewModel.Section.paymentMethods(rows: cards.map { WalletViewModel.Row.cardReference($0) }),
            WalletViewModel.Section.addMethod(showHeader: !cards.isEmpty, rows: [WalletViewModel.Row.addCard(title: Localizable.WalletViewModel.addPaymentMethod.text)])
        ]
        let viewModel = WalletViewModel(items: viewItems)
        let view = WalletView()
        view.dataSource = viewModel
        let viewController = WalletViewController(view: view, viewModel: viewModel)
        viewController.eventTriggered = { [weak self] event in
            switch event {
            case let .didTapNextButton(cardType):
                guard let jwt = viewModel.getJwtTokenWithSelectedCardReference(cardTypesToBypass: cardTypesToBypass) else { return }
                let visibleFields = cardType == .amex ? [DropInViewVisibleFields.cvv4] : [.cvv3]
                self?.showDropInViewController(jwt: jwt, customViewType: nil, visibleFields: visibleFields)
            case .didTapAddPaymentMethod:
                if isCardTypesBypassFlow {
                    self?.showCardTypesSelection(nextButtonShouldBeEnabled: true, nextButtonTapClosure: { [weak self] cardTypes in
                        guard let jwt = viewModel.getJwtTokenWithoutCardData(storeCard: true, typeDescriptions: [.threeDQuery, .accountCheck], cardTypesToBypass: cardTypes) else { return }
                        self?.showAddCardView(jwt: jwt)
                    })
                } else {
                    guard let jwt = viewModel.getJwtTokenWithoutCardData(storeCard: true, typeDescriptions: [.accountCheck]) else { return }
                    self?.showAddCardView(jwt: jwt)
                }
            }
        }
        push(viewController, animated: true)
    }

    func showCustomForm(jwt: String) {
        do {
            let transactionManager = try PaymentTransactionManager(jwt: jwt)
            let viewController = CustomPaymentFormViewController(view: CustomPaymentFormView(),
                                                                 viewModel: CustomPaymentFormViewModel(transactionManager: transactionManager,
                                                                                                       jwt: jwt))
            viewController.eventTriggered = { [weak self] event in
                switch event {
                case .transactionCompleted:
                    self?.navigationController.popViewController(animated: true)
                }
            }
            push(viewController, animated: true)
        } catch {
            showAlert(controller: navigationController, message: error.localizedDescription, completionHandler: nil)
        }
    }

    func showMerchantApplePay() {
        do {
            let transactionManager = try PaymentTransactionManager(jwt: .empty)
            let viewController = ApplePayViewController(view: ApplePayView(), viewModel: ApplePayViewModel(transactionManager: transactionManager))

            viewController.eventTriggered = { [weak self] event in
                switch event {
                case .transactionCompleted:
                    self?.navigationController.popViewController(animated: true)
                }
            }
            push(viewController, animated: true)
        } catch {
            showAlert(controller: navigationController, message: error.localizedDescription, completionHandler: nil)
        }
    }

    func showCardTypesSelection(nextButtonShouldBeEnabled: Bool, nextButtonTapClosure: @escaping ([CardType]) -> Void) {
        let viewController = SelectCardTypesViewController(view: SelectCardTypesView(), viewModel: SelectCardTypesViewModel(nextButtonShouldBeEnabled: nextButtonShouldBeEnabled))

        viewController.eventTriggered = { event in
            switch event {
            case let .didTapNextButton(cardTypes):
                nextButtonTapClosure(cardTypes)
            }
        }

        push(viewController, animated: true)
    }

    func showStyleManagerInitializationView(jwt: String, isDarkModeConfiguration: Bool) {
        let inputViewStyleManager = isDarkModeConfiguration ? InputViewStyleManager.defaultDark() : InputViewStyleManager.defaultLight()

        let payButtonStyleManager = isDarkModeConfiguration ? PayButtonStyleManager.defaultDark() : PayButtonStyleManager.defaultLight()

        let dropInViewStyleManager = isDarkModeConfiguration ? DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager, requestButtonStyleManager: payButtonStyleManager, zipButtonStyleManager: nil, ataButtonStyleManager: nil, backgroundColor: .black, spacingBetweenInputViews: 25, insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35)) : DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager, requestButtonStyleManager: payButtonStyleManager, zipButtonStyleManager: nil, ataButtonStyleManager: nil, backgroundColor: .white, spacingBetweenInputViews: 25, insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35))

        let cardinalDefaultFont = CardinalFont(name: "TimesNewRomanPSMT", size: 17)
        let toolbarStyleManager = isDarkModeConfiguration ? CardinalToolbarStyleManager(textColor: .white, textFont: cardinalDefaultFont, backgroundColor: .black, headerText: "Trust payment checkout", buttonText: "Cancel") : CardinalToolbarStyleManager(textColor: .black, textFont: cardinalDefaultFont, backgroundColor: .white, headerText: "Trust payment checkout", buttonText: "Cancel")
        let labelStyleManager = isDarkModeConfiguration ? CardinalLabelStyleManager(textColor: .gray, textFont: cardinalDefaultFont, headingTextColor: .white, headingTextFont: cardinalDefaultFont) : CardinalLabelStyleManager(textColor: .gray, textFont: cardinalDefaultFont, headingTextColor: .black, headingTextFont: cardinalDefaultFont)

        let verifyButtonStyleManager = isDarkModeConfiguration ? CardinalButtonStyleManager(textColor: .black, textFont: cardinalDefaultFont, backgroundColor: .white, cornerRadius: 6) : CardinalButtonStyleManager(textColor: .white, textFont: cardinalDefaultFont, backgroundColor: .black, cornerRadius: 6)
        let continueButtonStyleManager = isDarkModeConfiguration ? CardinalButtonStyleManager(textColor: .black, textFont: cardinalDefaultFont, backgroundColor: .white, cornerRadius: 6) : CardinalButtonStyleManager(textColor: .white, textFont: cardinalDefaultFont, backgroundColor: .black, cornerRadius: 6)
        let resendButtonStyleManager = isDarkModeConfiguration ? CardinalButtonStyleManager(textColor: .white, textFont: cardinalDefaultFont, backgroundColor: .black, cornerRadius: 0) : CardinalButtonStyleManager(textColor: .black, textFont: cardinalDefaultFont, backgroundColor: .white, cornerRadius: 0)
        let textBoxStyleManager = isDarkModeConfiguration ? CardinalTextBoxStyleManager(textColor: .white, textFont: cardinalDefaultFont, borderColor: .white, cornerRadius: 6, borderWidth: 1) : CardinalTextBoxStyleManager(textColor: .black, textFont: cardinalDefaultFont, borderColor: .black, cornerRadius: 6, borderWidth: 1)

        let rowClosure: ((Mirror.Child) -> StyleManagerInitializationViewModel.Row?) = { child in
            let title = child.label ?? .empty
            if let color = child.value as? UIColor {
                return StyleManagerInitializationViewModel.UIColorRow(title: title, color: color)
            }
            if let font = child.value as? UIFont {
                return StyleManagerInitializationViewModel.UIFontRow(title: title, font: font)
            }
            if let float = child.value as? CGFloat {
                return StyleManagerInitializationViewModel.CGFloatRow(title: title, size: float)
            }
            if let margin = child.value as? HeightMargins {
                return StyleManagerInitializationViewModel.HeightMarginsRow(title: title, size: margin)
            }
            if let edge = child.value as? UIEdgeInsets {
                return StyleManagerInitializationViewModel.UIEdgeInsetsRow(title: title, edgeInsets: edge)
            }
            if let string = child.value as? String {
                return StyleManagerInitializationViewModel.StringRow(title: title, text: string)
            }
            if let cardinalFont = child.value as? CardinalFont {
                return StyleManagerInitializationViewModel.CardinalFontRow(title: title, font: cardinalFont)
            }
            return nil
        }

        let dropInStyleManagerMirror = Mirror(reflecting: dropInViewStyleManager)
        let dropInStyleManagerRows: [StyleManagerInitializationViewModel.Row] = dropInStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let inputViewStyleManagerMirror = Mirror(reflecting: inputViewStyleManager)
        let inputViewStyleManagerRows: [StyleManagerInitializationViewModel.Row] = inputViewStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let payButtonStyleManagerMirror = Mirror(reflecting: payButtonStyleManager).superclassMirror!
        let payButtonStyleManagerRows: [StyleManagerInitializationViewModel.Row] = payButtonStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let toolbarStyleManagerMirror = Mirror(reflecting: toolbarStyleManager)
        let toolbarStyleManagerRows: [StyleManagerInitializationViewModel.Row] = toolbarStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let labelStyleManagerMirror = Mirror(reflecting: labelStyleManager)
        let labelStyleManagerRows: [StyleManagerInitializationViewModel.Row] = labelStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let verifyButtonStyleManagerMirror = Mirror(reflecting: verifyButtonStyleManager)
        let verifyButtonStyleManagerRows: [StyleManagerInitializationViewModel.Row] = verifyButtonStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let continueButtonStyleManagerMirror = Mirror(reflecting: continueButtonStyleManager)
        let continueButtonStyleManagerRows: [StyleManagerInitializationViewModel.Row] = continueButtonStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let resendButtonStyleManagerMirror = Mirror(reflecting: resendButtonStyleManager)
        let resendButtonStyleManagerRows: [StyleManagerInitializationViewModel.Row] = resendButtonStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let textBoxStyleManagerMirror = Mirror(reflecting: textBoxStyleManager)
        let textBoxStyleManagerRows: [StyleManagerInitializationViewModel.Row] = textBoxStyleManagerMirror.children.compactMap {
            rowClosure($0)
        }

        let viewItems = [
            StyleManagerInitializationViewModel.Section.dropInStyleManager(rows:
                dropInStyleManagerRows),
            StyleManagerInitializationViewModel.Section.inputViewStyleManager(rows: inputViewStyleManagerRows),
            StyleManagerInitializationViewModel.Section.payButtonStyleManager(rows: payButtonStyleManagerRows),
            StyleManagerInitializationViewModel.Section.toolbarStyleManager(rows: toolbarStyleManagerRows),
            StyleManagerInitializationViewModel.Section.labelStyleManager(rows: labelStyleManagerRows),
            StyleManagerInitializationViewModel.Section.verifyButtonStyleManager(rows: verifyButtonStyleManagerRows),
            StyleManagerInitializationViewModel.Section.continueButtonStyleManager(rows: continueButtonStyleManagerRows),
            StyleManagerInitializationViewModel.Section.resendButtonStyleManager(rows: resendButtonStyleManagerRows),
            StyleManagerInitializationViewModel.Section.textBoxStyleManager(rows: textBoxStyleManagerRows)
        ]

        let stylesManagerConfiguration = StylesManagerConfiguration(inputViewStyleManager: inputViewStyleManager, dropInViewStyleManager: dropInViewStyleManager, payButtonStyleManager: payButtonStyleManager, toolbarStyleManager: toolbarStyleManager, labelStyleManager: labelStyleManager, verifyButtonStyleManager: verifyButtonStyleManager, continueButtonStyleManager: continueButtonStyleManager, resendButtonStyleManager: resendButtonStyleManager, textBoxStyleManager: textBoxStyleManager)

        let viewController = StyleManagerInitializationViewController(view: StyleManagerInitializationView(), viewModel: StyleManagerInitializationViewModel(items: viewItems, isDarkModeConfiguration: isDarkModeConfiguration, stylesManagerConfiguration: stylesManagerConfiguration))

        viewController.eventTriggered = { event in
            switch event {
            case let .didTapNextButton(stylesManagerConfiguration):
                self.showDropInViewController(jwt: jwt, customViewType: nil, stylesManagerConfiguration: isDarkModeConfiguration ? nil : stylesManagerConfiguration, darkModeStylesManagerConfiguration: isDarkModeConfiguration ? stylesManagerConfiguration : nil)
            }
        }

        push(viewController, animated: true)
    }

    func showTypeDescriptionsSelection(excluding combinations: Set<[TypeDescription]>, nextButtonTapClosure: @escaping ([TypeDescription]) -> Void) {
        let viewController = SelectTypeDescriptionsViewController(view: SelectTypeDescriptionsView(), viewModel: SelectTypeDescriptionsViewModel(excluding: combinations))

        viewController.eventTriggered = { event in
            switch event {
            case let .didTapNextButton(typeDescriptions):
                nextButtonTapClosure(typeDescriptions)
            }
        }

        push(viewController, animated: true)
    }

    private func showAlert(controller: UIViewController, title: String? = nil, message: String, completionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizable.Alerts.okButton.text, style: .default, handler: completionHandler))
        controller.present(alert, animated: true, completion: nil)
    }
}

// swiftlint:enable type_body_length

private extension Localizable {
    enum WalletViewModel: String, Localized {
        case addPaymentMethod
    }
}
