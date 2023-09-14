//
//  ApplePayViewModel.swift
//  Example
//

import PassKit

final class ApplePayViewModel {
    // MARK: Properties

    private let paymentTransactionManager: PaymentTransactionManager

    /// Keys for certain scheme
    private let keys = ApplicationKeys(keys: ExampleKeys())

    var handleResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?

    private var request: PKPaymentRequest {
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
        return req
    }

    var applePayRequest: PKPaymentRequest? {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: request.supportedNetworks, capabilities: request.merchantCapabilities) else { return nil }
        return request
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    ///
    /// - Parameter transactionManager: configured PaymentTransactionManager instance
    init(transactionManager: PaymentTransactionManager) {
        paymentTransactionManager = transactionManager
    }

    // MARK: Functions

    /// Executes payment transaction flow
    func performRequest(with payment: PKPayment) {
        let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 299))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey), let token = payment.stringRepresentation else { return }

        paymentTransactionManager.performWalletTransaction(walletSource: .applePay, walletToken: token, jwt: jwt, transactionResponseClosure: handleResponseClosure)
    }
}
