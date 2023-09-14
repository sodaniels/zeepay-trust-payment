//
//  AddCardViewModel.swift
//  Example
//

import Foundation

final class AddCardViewModel {
    // MARK: Properties

    private let paymentTransactionManager: PaymentTransactionManager?

    private let jwt: String

    var handleResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    ///
    /// - Parameter jwt: jwt token
    init(transactionManager: PaymentTransactionManager, jwt: String) {
        self.jwt = jwt
        paymentTransactionManager = transactionManager
    }

    // MARK: Functions

    /// Executes payment transaction flow.
    /// - Parameters:
    ///   - cardNumber: The long number printed on the front of the customer’s card.
    ///   - cvv: The three digit security code printed on the back of the card. (For AMEX cards, this is a 4 digit code found on the front of the card), This field is not strictly required.
    ///   - expiryDate: The expiry date printed on the card.
    func performTransaction(cardNumber: CardNumber, cvv: CVV?, expiryDate: ExpiryDate) {
        let card = Card(cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate)
        paymentTransactionManager?.performTransaction(jwt: jwt, card: card, transactionResponseClosure: handleResponseClosure)
    }

    /// Validates all input views in form
    /// - Parameter view: form view
    /// - Returns: result of validation
    @discardableResult
    func validateForm(view: AddCardView) -> Bool {
        let cardNumberValidationResult = view.cardNumberInput.validate(silent: false)
        let expiryDateValidationResult = view.expiryDateInput.validate(silent: false)
        let cvvValidationResult = view.cvvInput.validate(silent: false)
        return cardNumberValidationResult && expiryDateValidationResult && cvvValidationResult
    }
}
