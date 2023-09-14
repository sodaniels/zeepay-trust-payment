//
//  Card.swift
//  TrustPaymentsUI
//

import Foundation

/// Object representation of the credit card with its number, expiry date and cvv
@objc public class Card: NSObject {
    @objc public let cardNumber: CardNumber?

    @objc public let cvv: CVV?

    @objc public let expiryDate: ExpiryDate?

    @objc public var cardTypeContainer: CardTypeContainer

    @objc public var cardType: CardType {
        CardValidator.cardType(for: cardNumber?.rawValue ?? .empty, cardTypes: cardTypeContainer.cardTypes)
    }

    @objc public init(cardNumber: CardNumber?, cvv: CVV?, expiryDate: ExpiryDate?, cardTypeContainer: CardTypeContainer = CardTypeContainer(cardTypes: CardType.allCases)) {
        self.cardNumber = cardNumber
        self.cvv = cvv
        self.expiryDate = expiryDate
        self.cardTypeContainer = cardTypeContainer
    }
}
