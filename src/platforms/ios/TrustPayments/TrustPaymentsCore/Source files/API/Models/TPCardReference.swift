//
//  TPCardReference.swift
//  TrustPaymentsCore
//

import Foundation

/// Represents a transaction and card details used for that transaction.
///
/// Can be used for future payments without the need to provide all card details.
///
/// Pass `transactionReference` property as `parenttransactionreference` in the JWT payload to perform transaction based on parent's card details.
/// - warning: `transactionReference` will be nil when `credentialsonfile` will not be set.
///
/// Use `maskedPan` property to show to the end user what card will be used alongside with brand logo. You can get the logo from Card module:
/// ```
/// CardType.cardType(for: `cardType`).logo
/// ```
@objc public class TPCardReference: NSObject, Codable {
    @objc public let transactionReference: String?
    @objc public let cardType: String
    @objc public let maskedPan: String

    /// Initialize a card reference object
    /// - Parameters:
    ///   - reference: transaction reference, returned on ACCOUNTCHECK
    ///   - cardType: String value representing card type, e.g VISA
    ///   - pan: masked pan number returned in response
    @objc public init(reference: String?, cardType: String, pan: String) {
        transactionReference = reference
        self.cardType = cardType
        maskedPan = pan
    }
}
