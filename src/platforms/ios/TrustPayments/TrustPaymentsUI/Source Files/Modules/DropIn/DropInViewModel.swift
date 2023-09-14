//
//  DropInViewModel.swift
//  TrustPaymentsUI
//

#if !COCOAPODS
    import TrustPayments3DSecure
    import TrustPaymentsCard
    import TrustPaymentsCore
#endif
import Foundation
import PassKit

final class DropInViewModel {
    // MARK: Properties

    private var paymentTransactionManager: PaymentTransactionManager

    private var jwt: String?

    private let visibleFields: [DropInViewVisibleFields]

    let applePayConfiguration: TPApplePayConfiguration?

    let apmsConfiguration: TPAPMConfiguration?

    var transactionResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?

    var isCardNumberFieldHidden: Bool {
        !visibleFields.contains(.pan)
    }

    var isCVVFieldHidden: Bool {
        !(visibleFields.contains(.cvv3) || visibleFields.contains(.cvv4))
    }

    var isExpiryDateFieldHidden: Bool {
        !visibleFields.contains(.expiryDate)
    }

    var isPayButtonHidden: Bool {
        visibleFields.isEmpty && applePayConfiguration?.isApplePayAvailable == true
    }

    var cardType: CardType {
        visibleFields.contains(.cvv4) ? .amex : .unknown
    }

    var isZipButtonHidden: Bool {
        guard let jwt = jwt, let configuration = apmsConfiguration else {
            // The ZIP button is not displayed without configuration object and JWT
            // (needed for mainamount/baseamount validation and billing address)
            return true
        }
        
        // ZIP should be enabled as supported APM in configuration
        guard configuration.supportedAPMs.contains(.zip) else {
            return true
        }
        
        // The JWT also needs to be valid
        guard let decodedJwt = try? DecodedMerchantJWT(jwt: jwt) else { return true }

        // Validate request types
        let disallowedRequestTypes: [TypeDescription] = [.accountCheck, .subscription]
        // Single THREEDQUERY is also disallowed
        guard !decodedJwt.typeDescriptions.contains(where: { disallowedRequestTypes.contains($0) }), decodedJwt.typeDescriptions != [.threeDQuery] else {
            // ACCOUNTCHECK and SUBSCRIPTION is not allowed for ZIP requests, THREEDQUERY is bypassed
            return true
        }

        // Validate billing data and customer data
        // For zip to proceed those parameters are required (18): billingTown, billingEmail, billingCounty, billingStreet, billingPremise, billingPostcode, billingLastname, billingFirstname, billingCountryiso2a, customerFirstname, customerLastname, customerEmail, customerPremise, customerTown, customerStreet, customerPostcode, customerCounty, customerCountryiso2a
        let billingData = [decodedJwt.billingTown,
                           decodedJwt.billingEmail,
                           decodedJwt.billingCounty,
                           decodedJwt.billingStreet,
                           decodedJwt.billingPremise,
                           decodedJwt.billingPostcode,
                           decodedJwt.billingLastname,
                           decodedJwt.billingFirstname,
                           decodedJwt.billingCountryiso2a,
                           decodedJwt.customerFirstname,
                           decodedJwt.customerLastname,
                           decodedJwt.customerEmail,
                           decodedJwt.customerPremise,
                           decodedJwt.customerTown,
                           decodedJwt.customerStreet,
                           decodedJwt.customerPostcode,
                           decodedJwt.customerCounty,
                           decodedJwt.customerCountryiso2a].compactMap { $0 }.filter { !$0.isEmpty }
        guard billingData.count == 18 else {
            // Some billing data is missing
            return true
        }
        
        // Only currency  allowed for ZIP is GBP.
        guard decodedJwt.currencyIso3a == "GBP" else { return true }

        if let min = configuration.minAmount, let max = configuration.maxAmount, max > min {
            // Has min and max defined
            if let baseAmount = decodedJwt.baseAmount {
                let amount = Double(baseAmount / 100)
                // Within range - zip button should not be hidden
                return !(min ... max).contains(amount)
            } else if let mainAmount = decodedJwt.mainAmount {
                // Within range - zip button should not be hidden
                return !(min ... max).contains(mainAmount)
            }
            // Min and max defined but missing baseamount or mainamount in JWT
            return true
        }
        // Show zip button
        return false
    }
    
    var isATAButtonHidden: Bool {
        guard let jwt = jwt, let configuration = apmsConfiguration else {
            // The ATA button is not displayed without JWT and without being enabled in APMs Configuration
            return true
        }
        
        // ATA should be enabled as supported APM in configuration
        guard configuration.supportedAPMs.contains(.ata) else {
            return true
        }
        
        // The JWT also needs to be valid
        guard let decodedJwt = try? DecodedMerchantJWT(jwt: jwt) else { return true }
        
        // Validate with required JWT fields
        // Proceed with ATA those parameters are required (3): billingCountryiso2a, billingCurrencyiso3a, returnUrl
        let jwtFields = [decodedJwt.billingCountryiso2a,
                         decodedJwt.currencyIso3a].compactMap { $0 }.filter { !$0.isEmpty }
        guard jwtFields.count == 2 else {
            // Some required JWT fields data is missing
            return true
        }

        // Only currencies allowed for ATA are GBP and EUR
        guard decodedJwt.currencyIso3a == "GBP" || decodedJwt.currencyIso3a == "EUR" else { return true }
        // Show ATA button
        return false
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    ///
    /// - Parameter jwt: jwt token
    /// - Parameter applePayConfiguration: Configuration of Apple Pay containing request and button styles. When requesttypedescriptions (JWT payload) parameter contains only   THREEDQUERY, the apple pay settings will be omitted
    /// - Parameter apmsConfiguration: Configuration of supported APMs
    /// - Parameter cardinalStyleManager: manager to set the interface style (view customization)
    /// - Parameter cardinalDarkModeStyleManager: manager to set the interface style in dark mode
    /// - Parameter visibleFields: specify which input fields should be visible
    init(jwt: String?, applePayConfiguration: TPApplePayConfiguration? = nil, apmsConfiguration: TPAPMConfiguration?, cardinalStyleManager: CardinalStyleManager?, cardinalDarkModeStyleManager: CardinalStyleManager?, visibleFields: [DropInViewVisibleFields] = DropInViewVisibleFields.default) throws {
        self.jwt = jwt
        self.apmsConfiguration = apmsConfiguration
        self.visibleFields = visibleFields

        // Omit the Apple Pay configuration if type desciptions parameter consist only of .threeDQuery
        if let jwt = jwt {
            let decodedJwt = try? DecodedMerchantJWT(jwt: jwt)
            self.applePayConfiguration = decodedJwt?.typeDescriptions == [TypeDescription.threeDQuery] ? nil : applePayConfiguration
        } else {
            self.applePayConfiguration = applePayConfiguration
        }

        paymentTransactionManager = try PaymentTransactionManager(jwt: jwt, cardinalStyleManager: cardinalStyleManager, cardinalDarkModeStyleManager: cardinalDarkModeStyleManager)

        self.applePayConfiguration?.proceedAfterApplePayAuthorization = { [weak self] jwt, walletToken in
            self?.updateTokenAndPerformTransactionWithApplePay(jwt: jwt, walletToken: walletToken)
        }
    }

    /// executes payment transaction flow
    /// - Parameters:
    ///   - cardNumber: The long number printed on the front of the customer’s card.
    ///   - cvv: The three digit security code printed on the back of the card. (For AMEX cards, this is a 4 digit code found on the front of the card), This field is not strictly required.
    ///   - expiryDate: The expiry date printed on the card.
    func performTransaction(cardNumber: CardNumber, cvv: CVV?, expiryDate: ExpiryDate) {
        let card = Card(cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate)
        paymentTransactionManager.performTransaction(jwt: jwt, card: card, transactionResponseClosure: transactionResponseClosure)
    }

    /// Validates all input views in form
    /// - Parameter view: form view
    /// - Returns: result of validation
    @discardableResult
    func validateForm(view: DropInViewProtocol) -> Bool {
        // validate only fields that are added to the view's hierarchy
        let viewsToValidate = [view.cardNumberInput, view.expiryDateInput, view.cvvInput].filter { ($0 as? BaseView)?.isHidden == false }
        return viewsToValidate.count == viewsToValidate.filter { $0.validate(silent: false) }.count && view.additionalFieldsToValidate.count == view.additionalFieldsToValidate.filter { $0.validate(silent: false) }.count && view.isFormValid
    }

    // MARK: Helpers

    /// Updates JWT token
    /// - Parameter newValue: updated JWT token
    func updateJWT(newValue: String) {
        jwt = newValue
    }
}

// MARK: Apple Pay flow

extension DropInViewModel {
    /// Check if ApplePay is available and present payment controller
    func performApplePayAuthorization() {
        guard let topMostVC = UIApplication.shared.topMostViewController else { return }
        guard let request = applePayConfiguration?.request else { return }
        guard let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
        applePayController.delegate = applePayConfiguration
        topMostVC.present(applePayController, animated: true)
    }

    /// Executes payment transaction flow after authorization from Apple Pay
    func updateTokenAndPerformTransactionWithApplePay(jwt: String, walletToken: String) {
        paymentTransactionManager.performWalletTransaction(walletSource: .applePay, walletToken: walletToken, jwt: jwt, transactionResponseClosure: transactionResponseClosure)
    }
}

// MARK: - APM ZIP

extension DropInViewModel {
    func performZIPTransaction() {
        paymentTransactionManager.performAPMTransaction(jwt: jwt, apm: .zip, styling: apmsConfiguration?.styling, transactionResponseClosure: transactionResponseClosure)
    }
}

// MARK: - APM A2A

extension DropInViewModel {
    func performATATransaction() {
        paymentTransactionManager.performAPMTransaction(jwt: jwt, apm: .ata, styling: apmsConfiguration?.styling, transactionResponseClosure: transactionResponseClosure)
    }
}

/// Use to specify which card details fields should be visible.
///
/// Needed when all you need from your user is just to provide CVV code.
///
/// - warning: When providing both lengths of cvv, the one with 3 digits will be used.
@objc public enum DropInViewVisibleFields: Int {
    case pan = 0
    case expiryDate
    case cvv3
    case cvv4

    public static var `default`: [DropInViewVisibleFields] {
        [
            .pan,
            .expiryDate,
            .cvv3
        ]
    }
}
