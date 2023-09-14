//
//  MainViewModel.swift
//  Example
//

import Foundation
import PassKit
import SwiftJWT
import TrustPaymentsCard
import TrustPaymentsCore
import TrustPaymentsUI

protocol MainViewModelDataSource: AnyObject {
    func row(at index: IndexPath) -> MainViewModel.Row?
    func numberOfSections() -> Int
    func numberOfRows(at section: Int) -> Int
    func title(for section: Int) -> String?
    func detailInformationForRow(at index: IndexPath) -> String?
}

// swiftlint:disable type_body_length
final class MainViewModel {
    // MARK: Properties

    private var commonBillingData: BillingData {
        BillingData(firstName: "Trust",
                    lastName: "Payments",
                    street: "1 Royal Exchange",
                    town: "London",
                    county: "England",
                    countryIso2a: "GB",
                    postcode: "EC3V 3DG",
                    email: "example@mail.com",
                    premise: "34")
    }
    
    private var commonDeliveryData: DeliveryData {
        DeliveryData(customerfirstname: "Trust",
                     customerlastname: "Payments",
                     customerstreet: "1 Royal Exchange",
                     customertown: "London",
                     customercounty: "England",
                     customercountryiso2a: "GB",
                     customerpostcode: "EC3V 3DG",
                     customeremail: "example@mail.com",
                     customerpremise: "34")
    }

    /// Stores Sections and rows representing the main view
    private var items: [Section]

    private var paymentTransactionManager: PaymentTransactionManager?

    /// Keys for certain scheme
    private let keys = ApplicationKeys(keys: ExampleKeys())

    private var shouldAddSubscriptionDataForApplePayJWT: Bool = false
    private var typeDescForApplePayJwt: [TypeDescription] = []

    var showAuthSuccess: ((ResponseSettleStatus) -> Void)?
    var showRequestSuccess: ((TypeDescription?) -> Void)?
    var showAuthError: ((String) -> Void)?
    var showLoader: ((Bool) -> Void)?

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    init(transactionManager: PaymentTransactionManager?, items: [Section]) {
        self.items = items
        paymentTransactionManager = transactionManager
    }

    // MARK: Functions

    /// Returns JWT without card data as a String
    func getJwtTokenWithoutCardData(typeDescriptions: [TypeDescription], cardTypesToBypass: [CardType]? = nil, storeCard: Bool = false, parentTransactionReference: String? = nil, baseAmount: Int = 1050) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let cardTypesToBypass = cardTypesToBypass?.map(\.stringValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: baseAmount,
                                              parenttransactionreference: parentTransactionReference,
                                              credentialsonfile: storeCard ? "1" : parentTransactionReference != nil ? "2" : nil,
                                              billingData: commonBillingData,
                                              deliveryData: commonDeliveryData))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    /// Returns JWT with payload parameters
    func getJwtTokenWithPayloadParameters(typeDescriptions: [TypeDescription], parentTransactionReference: String? = nil, currency: String = "GBP", baseAmount: Int? = nil, mainAmount: Double? = nil, billingData: BillingData? = nil, deliveryData: DeliveryData? = nil) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: currency,
                                              baseamount: baseAmount,
                                              mainamount: mainAmount,
                                              parenttransactionreference: parentTransactionReference,
                                              credentialsonfile: parentTransactionReference != nil ? "2" : nil,
                                              billingData: billingData,
                                              deliveryData: deliveryData))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    /// Performs an AUTH request with card data
    func makeAuthCall() {
        let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              locale: "en_GB",
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4111111111111111",
                                              expirydate: "12/2022",
                                              cvv: "123"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }
        performTransaction(with: jwt)
    }

    /// Performs Account check with card data
    func makeAccountCheckRequest() {
        let typeDescriptions = [TypeDescription.accountCheck].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4111111111111111",
                                              expirydate: "12/2022",
                                              cvv: "123"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }
        performTransaction(with: jwt)
    }

    /// Performs AUTH request without card data
    /// uses previous card reference
    func makeAccountCheckWithAuthRequest() {
        let typeDescriptions = [TypeDescription.accountCheck].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4111111111111111",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              credentialsonfile: "1"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }
        performTransaction(with: jwt) { [weak self] cardReference, _ in
            guard let self = self else { return }
            guard let transactionReference = cardReference.transactionReference else {
                self.showAuthError?("Missing parent transaction reference")
                return
            }
            let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
            let claim = TPClaims(iss: self.keys.merchantUsername,
                                 iat: Date(timeIntervalSinceNow: 0),
                                 payload: Payload(requesttypedescriptions: typeDescriptions,
                                                  accounttypedescription: "ECOM",
                                                  sitereference: self.keys.merchantSiteReference,
                                                  currencyiso3a: "GBP",
                                                  baseamount: 1100,
                                                  parenttransactionreference: transactionReference,
                                                  credentialsonfile: "2"))
            guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: self.keys.jwtSecretKey) else { return }
            self.performTransaction(with: jwt)
        }
    }

    func performSubscriptionOnTPEngine() {
        let typeDescriptions = [TypeDescription.accountCheck, .subscription].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 199,
                                              pan: "4111111111111111",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              subscriptiontype: "RECURRING",
                                              subscriptionfinalnumber: "12",
                                              subscriptionunit: "MONTH",
                                              subscriptionfrequency: "1",
                                              subscriptionnumber: "1",
                                              credentialsonfile: "1"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }

        performTransaction(with: jwt)
    }

    func performSubscriptionOnMerchantEngine() {
        let typeDescriptions = [TypeDescription.accountCheck].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1050,
                                              pan: "4111111111111111",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              subscriptiontype: "RECURRING",
                                              subscriptionnumber: "1",
                                              credentialsonfile: "1"))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }

        performTransaction(with: jwt, responseHandler: { [weak self] (cardReference: TPCardReference, _) in
            guard let self = self else { return }
            guard let transactionReference = cardReference.transactionReference else {
                self.showAuthError?("Missing parent transaction reference")
                return
            }
            let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
            let claim = TPClaims(iss: self.keys.merchantUsername,
                                 iat: Date(timeIntervalSinceNow: 0),
                                 payload: Payload(requesttypedescriptions: typeDescriptions,
                                                  accounttypedescription: "RECUR",
                                                  sitereference: self.keys.merchantSiteReference,
                                                  parenttransactionreference: transactionReference,
                                                  subscriptiontype: "RECURRING",
                                                  subscriptionnumber: "2",
                                                  credentialsonfile: "2"))
            guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: self.keys.jwtSecretKey) else { return }
            self.performTransaction(with: jwt)
        })
    }

    func payByCardFromParentReference() {
        let typeDescriptions = [TypeDescription.threeDQuery, .auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 199,
                                              parenttransactionreference: "59-9-99169",
                                              credentialsonfile: "2"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }

        performTransaction(with: jwt, card: Card(cardNumber: nil, cvv: CVV(rawValue: "123"), expiryDate: nil))
    }

    func performRequestWithTypeDescriptionsAndLaterAuth(typeDescriptions: [TypeDescription], isThreeDVersionOne: Bool) {
        let pan = isThreeDVersionOne ? "5200000000000007" : "4000000000002008"
        guard let jwt = getJwtTokenWith(typeDescriptions: typeDescriptions, pan: pan, expirydate: "12/2022", cvv: "123") else { return }

        performTransaction(with: jwt, responseHandler: { [weak self] cardReference, transactionResult in
            guard let self = self else { return }
            guard let transactionReference = cardReference.transactionReference else {
                self.showAuthError?("Missing parent transaction reference")
                return
            }
            guard let threeDResponse = transactionResult else {
                self.showAuthError?("Missing threeDResponse object")
                return
            }

            guard let jwt = self.getAuthJwtTokenWith(parentReference: transactionReference, threedresponse: isThreeDVersionOne ? nil : threeDResponse.threeDResponse, pares: isThreeDVersionOne ? threeDResponse.pares : nil) else { return }
            self.performTransaction(with: jwt)
        })
    }

    func getJwtTokenWithParentReference(typeDescriptions: [TypeDescription]) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1050,
                                              parenttransactionreference: "57-9-106428",
                                              credentialsonfile: "2"))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    func performAuthUsingAPM(_ apm: APM) {
        let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              locale: "en_GB",
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              billingData: commonBillingData,
                                              deliveryData: commonDeliveryData))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return }
        if paymentTransactionManager == nil {
            // Did not create the PaymentTransactionManager instance before
            do {
                paymentTransactionManager = try PaymentTransactionManager(jwt: jwt)
            } catch {
                showAuthError?(error.localizedDescription)
                return
            }
        }
        showLoader?(true)
        paymentTransactionManager?.performAPMTransaction(jwt: jwt, apm: apm, transactionResponseClosure: { jwt, _, error in
            self.showLoader?(false)

            guard let error = error else {
                guard let tpResponses = try? TPHelper.getTPResponses(jwt: jwt) else { return }
                guard let firstTPError = tpResponses.compactMap(\.tpError).first else {
                    self.showRequestSuccess?(nil)
                    return
                }
                self.showAuthError?(firstTPError.humanReadableDescription)
                return
            }

            self.showAuthError?(error.humanReadableDescription)
        })
    }
    
    private func getJwtTokenWith(typeDescriptions: [TypeDescription], pan: String, expirydate: String, cvv: String) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1050,
                                              pan: pan,
                                              expirydate: expirydate,
                                              cvv: cvv))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    private func getAuthJwtTokenWith(parentReference: String, threedresponse: String? = nil, pares: String? = nil) -> String? {
        let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1050,
                                              parenttransactionreference: parentReference,
                                              credentialsonfile: "2",
                                              threedresponse: threedresponse,
                                              pares: pares))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    func getApplePayJWTAndConfiguration(typeDescriptions: [TypeDescription], payment: PKPayment? = nil, shouldAddSubscriptionData: Bool = false) -> (jwt: String, walletToken: String?, config: TPApplePayConfiguration?)? {
        shouldAddSubscriptionDataForApplePayJWT = shouldAddSubscriptionData
        typeDescForApplePayJwt = typeDescriptions

        // swiftlint:disable line_length
        let billingContact = payment?.billingContact
        let billingData = BillingData(prefixName: billingContact?.name?.namePrefix,
                                      firstName: billingContact?.name?.givenName,
                                      middleName: billingContact?.name?.middleName,
                                      lastName: billingContact?.name?.familyName,
                                      suffixName: billingContact?.name?.nameSuffix,
                                      street: billingContact?.postalAddress?.street,
                                      town: billingContact?.postalAddress?.city,
                                      county: billingContact?.postalAddress?.state,
                                      countryIso2a: billingContact?.postalAddress?.isoCountryCode,
                                      postcode: billingContact?.postalAddress?.postalCode,
                                      email: billingContact?.emailAddress,
                                      telephone: billingContact?.phoneNumber?.stringValue,
                                      premise: nil)

        let shippingContact = payment?.shippingContact
        let deliveryData = DeliveryData(customerprefixname: shippingContact?.name?.namePrefix, customerfirstname: shippingContact?.name?.givenName, customermiddlename: shippingContact?.name?.middleName, customerlastname: shippingContact?.name?.familyName, customersuffixname: shippingContact?.name?.nameSuffix, customerstreet: shippingContact?.postalAddress?.street, customertown: shippingContact?.postalAddress?.city, customercounty: shippingContact?.postalAddress?.state, customercountryiso2a: shippingContact?.postalAddress?.isoCountryCode, customerpostcode: shippingContact?.postalAddress?.postalCode, customeremail: shippingContact?.emailAddress, customertelephone: shippingContact?.phoneNumber?.stringValue)
        // swiftlint:enable line_length

        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 299,
                                              subscriptiontype: shouldAddSubscriptionData ? "RECURRING" : nil,
                                              subscriptionfinalnumber: shouldAddSubscriptionData ? "12" : nil,
                                              subscriptionunit: shouldAddSubscriptionData ? "MONTH" : nil,
                                              subscriptionfrequency: shouldAddSubscriptionData ? "1" : nil,
                                              subscriptionnumber: shouldAddSubscriptionData ? "1" : nil,
                                              credentialsonfile: shouldAddSubscriptionData ? "1" : nil,
                                              billingData: billingData,
                                              deliveryData: deliveryData))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        if let payment = payment {
            return (jwt, payment.stringRepresentation, nil)
        }
        // minimum number of parameters
        let req = PKPaymentRequest()
        req.supportedNetworks = [.visa, .masterCard, .amex]
        req.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]
        req.merchantIdentifier = "merchant.ios.trustpayments.test"
        req.countryCode = "GB"
        req.currencyCode = "GBP"

        // optional fields
        req.requiredBillingContactFields = [.emailAddress, .name, .phoneNumber, .postalAddress]
        req.requiredShippingContactFields = [.emailAddress, .name, .phoneNumber, .postalAddress]
        let standardShippingMethod = PKShippingMethod(label: "Standard", amount: 1.0)
        standardShippingMethod.identifier = "standardShippingMethod"
        standardShippingMethod.detail = "5-9 days"
        let expressShippingMethod = PKShippingMethod(label: "Express", amount: 100.0)
        expressShippingMethod.identifier = "expressShippingMethod"
        expressShippingMethod.detail = "1-2 days"
        req.shippingMethods = [standardShippingMethod, expressShippingMethod]
        let item = PKPaymentSummaryItem(label: "Item 1", amount: 1.99)
        req.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Shipping", amount: standardShippingMethod.amount),
            item,
            PKPaymentSummaryItem(label: "Total", amount: standardShippingMethod.amount.adding(item.amount))
        ]

        let config = TPApplePayConfiguration(handler: self,
                                             request: req,
                                             buttonStyle: .black,
                                             buttonDarkModeStyle: .white,
                                             buttonType: .plain)
        return (jwt, nil, config)
    }

    private func performTransaction(with jwt: String, card: Card? = nil, responseHandler: ((_ cardReference: TPCardReference, _ transactionResult: TPAdditionalTransactionResult?) -> Void)? = nil) {
        if paymentTransactionManager == nil {
            // Did not create the PaymentTransactionManager instance before
            do {
                paymentTransactionManager = try PaymentTransactionManager(jwt: jwt)
            } catch {
                showAuthError?(error.localizedDescription)
                return
            }
        }
        showLoader?(true)

        paymentTransactionManager?.performTransaction(jwt: jwt, card: card, transactionResponseClosure: { [unowned self] jwt, transactionResult, error in
            self.showLoader?(false)

            guard let error = error else {
                guard let tpResponses = try? TPHelper.getTPResponses(jwt: jwt) else { return }
                let threeDQueryResponse = tpResponses.compactMap { $0.responseObjects.first(where: { $0.requestTypeDescription(contains: TypeDescription.threeDQuery) }) }.first
                let cardReference = threeDQueryResponse?.cardReference ?? tpResponses.last?.cardReference

                guard let firstTPError = tpResponses.compactMap(\.tpError).first else {
                    if let customResponseHandler = responseHandler, let cardRef = cardReference {
                        customResponseHandler(cardRef, transactionResult)
                    } else {
                        self.showRequestSuccess?(nil)
                    }
                    return
                }

                self.showAuthError?(firstTPError.humanReadableDescription)
                return
            }

            self.showAuthError?(error.humanReadableDescription)
        })
    }
}

// MARK: MainViewModelDataSource

extension MainViewModel: MainViewModelDataSource {
    func row(at index: IndexPath) -> Row? {
        items[index.section].rows[index.row]
    }

    func numberOfSections() -> Int {
        items.count
    }

    func numberOfRows(at section: Int) -> Int {
        items[section].rows.count
    }

    func title(for section: Int) -> String? {
        items[section].title
    }

    func detailInformationForRow(at index: IndexPath) -> String? {
        items[index.section].rows[index.row].detailInformation
    }
}

extension MainViewModel {
    enum Row {
        case performAuthRequestInBackground
        case presentSingleInputComponents
        case presentPayByCardForm
        case performAccountCheck
        case performAccountCheckWithAuth
        case presentAddCardForm
        case presentWalletForm
        case presentWalletWithCardTypesToBypass
        case showDropInControllerWithCustomView
        case showDropInControllerNo3DSecure
        case payByCardFromParentReference
        case subscriptionOnTPEngine
        case subscriptionOnMerchantEngine
        case payFillCVV
        case payByCustomForm
        case applePay
        case showDropInControllerWithCustomViewAndTip
        case showDropInControllerWithRiskDec
        case showDropInControllerWithJWTUpdates
        case merchantApplePay
        case dropInControllerWithCardTypesToBypass
        case showDropInControllerWithZIP
        case showDropInControllerWithATA
        case showStyleManagerInitView
        case showDarkModeStyleManagerInitView
        case applePayWithTypeDescriptionSelection
        case performThreeDQueryV2AndLaterAuth
        case performThreeDQueryV1AndLaterAuth
        // swiftlint:disable:next identifier_name
        case performAccountCheckThreeDQueryV2AndLaterAuth
        // swiftlint:disable:next identifier_name
        case performAccountCheckThreeDQueryV1AndLaterAuth
        case performAuthZIP
        case performAuthATA

        var title: String {
            switch self {
            case .performAuthRequestInBackground:
                return Localizable.MainViewModel.makeAuthRequestButton.text
            case .presentSingleInputComponents:
                return Localizable.MainViewModel.showSingleInputViewsButton.text
            case .presentPayByCardForm:
                return Localizable.MainViewModel.showDropInControllerButton.text
            case .performAccountCheck:
                return Localizable.MainViewModel.makeAccountCheckRequestButton.text
            case .performAccountCheckWithAuth:
                return Localizable.MainViewModel.makeAccountCheckWithAuthRequestButton.text
            case .presentAddCardForm:
                return Localizable.MainViewModel.addCardReferenceButton.text
            case .presentWalletForm:
                return Localizable.MainViewModel.payWithWalletButton.text
            case .presentWalletWithCardTypesToBypass:
                return Localizable.MainViewModel.presentWalletWithCardTypesToBypass.text
            case .subscriptionOnTPEngine:
                return Localizable.MainViewModel.subscriptionOnTPEngine.text
            case .subscriptionOnMerchantEngine:
                return Localizable.MainViewModel.subscriptionOnMerchantEngine.text
            case .showDropInControllerNo3DSecure:
                return Localizable.MainViewModel.showDropInControllerNo3DSecure.text
            case .showDropInControllerWithCustomView:
                return Localizable.MainViewModel.showDropInControllerWithCustomView.text
            case .payByCardFromParentReference:
                return Localizable.MainViewModel.payByCardFromParentReference.text
            case .payFillCVV:
                return Localizable.MainViewModel.payFillCVV.text
            case .payByCustomForm:
                return Localizable.MainViewModel.payByCustomForm.text
            case .applePay:
                return Localizable.MainViewModel.applePay.text
            case .showDropInControllerWithCustomViewAndTip:
                return Localizable.MainViewModel.showDropInControllerWithCustomViewAndTip.text
            case .showDropInControllerWithRiskDec:
                return Localizable.MainViewModel.showDropInControllerWithRiskDec.text
            case .showDropInControllerWithJWTUpdates:
                return Localizable.MainViewModel.showDropInControllerWithJWTUpdates.text
            case .merchantApplePay:
                return Localizable.MainViewModel.applePay.text
            case .dropInControllerWithCardTypesToBypass:
                return Localizable.MainViewModel.dropInControllerWithCardTypesToBypass.text
            case .showDropInControllerWithZIP:
                return Localizable.MainViewModel.showDropInControllerWithZIP.text
            case .showDropInControllerWithATA:
                return Localizable.MainViewModel.showDropInControllerWithATA.text
            case .showStyleManagerInitView:
                return Localizable.MainViewModel.showStyleManagerInitView.text
            case .showDarkModeStyleManagerInitView:
                return Localizable.MainViewModel.showDarkModeStyleManagerInitView.text
            case .applePayWithTypeDescriptionSelection:
                return Localizable.MainViewModel.applePayWithTypeDescriptionSelection.text
            case .performThreeDQueryV2AndLaterAuth:
                return Localizable.MainViewModel.performThreeDQueryV2AndLaterAuth.text
            case .performThreeDQueryV1AndLaterAuth:
                return Localizable.MainViewModel.performThreeDQueryV1AndLaterAuth.text
            case .performAccountCheckThreeDQueryV2AndLaterAuth:
                return Localizable.MainViewModel.performAccountCheckThreeDQueryV2AndLaterAuth.text
            case .performAccountCheckThreeDQueryV1AndLaterAuth:
                return Localizable.MainViewModel.performAccountCheckThreeDQueryV1AndLaterAuth.text
            case .performAuthZIP:
                return Localizable.MainViewModel.performAuthZIP.text
            case .performAuthATA:
                return Localizable.MainViewModel.performAuthATA.text
            }
        }

        var hasDetailedInfo: Bool {
            detailInformation != nil
        }

        var detailInformation: String? {
            switch self {
            case .performAuthRequestInBackground:
                return """
                Performs AUTH request to the EU gateway:

                accounttypedescription: "ECOM"
                currencyiso3a: "GBP"
                baseamount: 1100
                pan: "4111111111111111"
                expirydate: "12/2022"
                securitycode: "123"
                """
            case .subscriptionOnTPEngine:
                return """
                Performs ACCOUNTCHECK & SUBSCRIPTION request to the EU gateway:

                accounttypedescription: "ECOM"
                currencyiso3a: "GBP"
                baseamount: 199
                pan: "4111111111111111"
                expirydate: "12/2022"
                securitycode: "123"
                subscriptiontype: "RECURRING"
                subscriptionfinalnumber: "12"
                subscriptionunit: "MONTH"
                subscriptionfrequency: "1"
                subscriptionnumber: "1"
                """
            case .subscriptionOnMerchantEngine:
                return """
                Performs AUTH request to the EU gateway:

                accounttypedescription: "RECUR"
                currencyiso3a: "GBP"
                baseamount: 199
                securitycode: "123"
                parenttransactionreference: "58-9-53270"
                subscriptiontype: "RECURRING"
                subscriptionnumber: "2"

                Make sure the parent transaction is valid
                """
            case .performThreeDQueryV2AndLaterAuth:
                return """
                Performs THREEDQUERY request to the EU gateway:
                currencyiso3a: "GBP"
                baseamount: 150
                pan: "4000000000002008"
                expirydate: "12/2022"
                securitycode: "123"

                After a successful THREEDQUERY request - performs AUTH request to the EU gateway (as a separate, later transaction):
                currencyiso3a: "GBP"
                baseamount: 150
                parenttransactionreference: "(property from THREEDQUERY response object)"
                threedresponse: "(property from THREEDQUERY response object)"
                """
            case .performThreeDQueryV1AndLaterAuth:
                return """
                Performs THREEDQUERY request to the EU gateway:
                currencyiso3a: "GBP"
                baseamount: 150
                pan: "5200000000000007"
                expirydate: "12/2022"
                securitycode: "123"

                After a successful THREEDQUERY request - performs AUTH request to the EU gateway (as a separate, later transaction):
                currencyiso3a: "GBP"
                baseamount: 150
                parenttransactionreference: "(property from THREEDQUERY response object)"
                pares: "(property from THREEDQUERY response object)"
                """
            case .performAccountCheckThreeDQueryV2AndLaterAuth:
                return """
                Performs ACCOUNTCHECK & THREEDQUERY request to the EU gateway:
                currencyiso3a: "GBP"
                baseamount: 150
                pan: "4000000000002008"
                expirydate: "12/2022"
                securitycode: "123"

                After a successful request - performs AUTH request to the EU gateway (as a separate, later transaction):
                currencyiso3a: "GBP"
                baseamount: 150
                parenttransactionreference: "(property from THREEDQUERY response object)"
                threedresponse: "(property from THREEDQUERY response object)"
                """
            case .performAccountCheckThreeDQueryV1AndLaterAuth:
                return """
                Performs ACCOUNTCHECK & THREEDQUERY request to the EU gateway:
                currencyiso3a: "GBP"
                baseamount: 150
                pan: "5200000000000007"
                expirydate: "12/2022"
                securitycode: "123"

                After a successful request - performs AUTH request to the EU gateway (as a separate, later transaction):
                currencyiso3a: "GBP"
                baseamount: 150
                parenttransactionreference: "(property from THREEDQUERY response object)"
                pares: "(property from THREEDQUERY response object)"
                """
            default:
                return nil
            }
        }

        var identifier: String? {
            switch self {
            case .performAuthRequestInBackground:
                return "performAuthRequestButton"
            case .presentSingleInputComponents:
                return "singleInputButton"
            case .presentPayByCardForm:
                return "payWith3DSecureButton"
            case .performAccountCheck:
                return "performAccountCheckRequestButton"
            case .performAccountCheckWithAuth:
                return "performAccountCheckAndAuthRequestsButton"
            case .presentAddCardForm:
                return "addCardFormButton"
            case .presentWalletForm:
                return "showStoredCardViewButton"
            case .presentWalletWithCardTypesToBypass:
                return "showStoredCardWithBypassFlowButton"
            case .subscriptionOnTPEngine:
                return "performSubscriptionOnTPEngineButton"
            case .subscriptionOnMerchantEngine:
                return "performSubscriptionOnMerchantEngineButton"
            case .showDropInControllerNo3DSecure:
                return "payWithout3DSecureButton"
            case .showDropInControllerWithCustomView:
                return "payWithCustomForm"
            case .payByCardFromParentReference:
                return "payWithParentReferenceButton"
            case .payFillCVV:
                return "payAddingOnlyCVVButton"
            case .payByCustomForm:
                return "payWithCustomFormButton"
            case .showDropInControllerWithCustomViewAndTip:
                return "payWithAddingTipButton"
            case .showDropInControllerWithRiskDec:
                return "payWith3DSecureAndRiskDecButton"
            case .dropInControllerWithCardTypesToBypass:
                return "payWithBypassCard"
            case .showDropInControllerWithZIP:
                return "payWithCardZIP"
            case .showDropInControllerWithATA:
                return "payWithCardATA"
            case .showDropInControllerWithJWTUpdates:
                return "payWithJWTUpdatesButton"
            case .applePayWithTypeDescriptionSelection:
                return "payWithApplePayButton"
            case .performThreeDQueryV2AndLaterAuth:
                return "payWithForwardedThreeDResponse"
            case .performThreeDQueryV1AndLaterAuth:
                return "payWithForwardedPares"
            case .performAccountCheckThreeDQueryV2AndLaterAuth:
                return "performAccountCheckAndPayWithForwardedThreeDResponse"
            case .performAccountCheckThreeDQueryV1AndLaterAuth:
                return "performAccountCheckAndPayWithForwardedPares"
            case .performAuthZIP:
                return "performAuthZIP"
            case .performAuthATA:
                return "performAuthATA"
            default: return nil
            }
        }
    }

    enum Section {
        case onMerchant(rows: [Row])
        case onSDK(rows: [Row])

        var rows: [Row] {
            switch self {
            case let .onMerchant(rows): return rows
            case let .onSDK(rows): return rows
            }
        }

        var title: String? {
            switch self {
            case .onMerchant: return Localizable.MainViewModel.merchantResponsibility.text
            case .onSDK: return Localizable.MainViewModel.sdkResponsibility.text
            }
        }
    }
}

// MARK: Localizable

private extension Localizable {
    enum MainViewModel: String, Localized {
        case makeAuthRequestButton
        case showSingleInputViewsButton
        case showDropInControllerButton
        case makeAccountCheckRequestButton
        case makeAccountCheckWithAuthRequestButton
        case addCardReferenceButton
        case payWithWalletButton
        case presentWalletWithCardTypesToBypass
        case merchantResponsibility
        case sdkResponsibility
        case showDropInControllerNo3DSecure
        case showDropInControllerWithCustomView
        case subscriptionOnTPEngine
        case subscriptionOnMerchantEngine
        case payByCardFromParentReference
        case payFillCVV
        case payByCustomForm
        case applePay
        case showDropInControllerWithCustomViewAndTip
        case showDropInControllerWithRiskDec
        case showDropInControllerWithJWTUpdates
        case dropInControllerWithCardTypesToBypass
        case showDropInControllerWithZIP
        case showDropInControllerWithATA
        case showStyleManagerInitView
        case showDarkModeStyleManagerInitView
        case applePayWithTypeDescriptionSelection
        case performThreeDQueryV2AndLaterAuth
        case performThreeDQueryV1AndLaterAuth
        // swiftlint:disable:next identifier_name
        case performAccountCheckThreeDQueryV2AndLaterAuth
        // swiftlint:disable:next identifier_name
        case performAccountCheckThreeDQueryV1AndLaterAuth
        case performAuthZIP
        case performAuthATA
    }
}

extension MainViewModel: TPApplePayConfigurationHandler {
    func shippingMethodChanged(to method: PKShippingMethod, updatedWith: @escaping ([PKPaymentSummaryItem]) -> Void) {
        // // Example: update summary items
        if method.identifier == "standardShippingMethod" {
            let item = PKPaymentSummaryItem(label: "Item 1", amount: 1.99)
            let newItems = [
                PKPaymentSummaryItem(label: "Shipping", amount: method.amount),
                item,
                PKPaymentSummaryItem(label: "Total", amount: method.amount.adding(item.amount))
            ]
            updatedWith(newItems)
        } else if method.identifier == "expressShippingMethod" {
            let item = PKPaymentSummaryItem(label: "Item 1", amount: 1.99)
            let newItems = [
                PKPaymentSummaryItem(label: "Shipping", amount: method.amount),
                item,
                PKPaymentSummaryItem(label: "Total", amount: method.amount.adding(item.amount))
            ]
            updatedWith(newItems)
        } else {
            // no change required
            updatedWith([])
        }
    }

    func shippingAddressChanged(to address: CNPostalAddress, updatedWith: @escaping ([Error]?, [PKPaymentSummaryItem]) -> Void) {
        // Example: for some reason, cannot post to Poland
        if address.isoCountryCode == "PL" {
            updatedWith([PKPaymentError(.shippingAddressUnserviceableError)], [])
        } else {
            updatedWith(nil, [])
        }
    }

    func didAuthorizedPayment(payment: PKPayment, updatedRequestParameters: @escaping ((String?, String?, [Error]?) -> Void)) {
        let result = getApplePayJWTAndConfiguration(typeDescriptions: typeDescForApplePayJwt, payment: payment, shouldAddSubscriptionData: shouldAddSubscriptionDataForApplePayJWT)
        guard let jwt = result?.jwt, let token = result?.walletToken else {
            let error = NSError(domain: PKPaymentError.errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing Apple Pay token"])
            updatedRequestParameters(nil, nil, [error])
            return
        }
        updatedRequestParameters(jwt, token, nil)
    }

    func didCancelPaymentAuthorization() {
        AppLog.log("Apple pay dismissed")
    }
}
