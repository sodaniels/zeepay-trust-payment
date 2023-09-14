//
//  CardNumberInputVIew.swift
//  TrustPaymentsUI
//

#if !COCOAPODS
    import TrustPaymentsCard
    import TrustPaymentsCore
#endif

import UIKit

@objc public protocol CardNumberInputViewDelegate {
    /// Called when the user enters a valid card number.
    /// - Parameter cardNumberInputView: The `CardNumberInputView` that was used to enter the card number.
    @objc func cardNumberInputViewDidComplete(_ cardNumberInputView: CardNumberInputView)

    ///  Called when the user has changed the text in `CardNumberInputView`.
    /// - Parameter cardNumberInputView: `CardNumberInputView`, whose text has been changed.
    @objc func cardNumberInputViewDidChangeText(_ cardNumberInputView: CardNumberInputView)
}

/// Card number input view.
///
/// Validates card number, applies proper masking and checks whether cvv is required for given card. Also displays a card logo.
///
/// Works as a stand alone view and requires CardValidator from Card module. Can be used to build your own Pay form.
@objc public final class CardNumberInputView: DefaultSecureFormInputView, CardNumberInput {
    // MARK: Private Properties

    private var cardNumberFormat: CardNumberFormat {
        CardNumberFormat(cardTypeContainer: cardTypeContainer, separator: cardNumberSeparator)
    }

    // MARK: Public Properties

    @objc public weak var cardNumberInputViewDelegate: CardNumberInputViewDelegate?

    @objc public var cardTypeContainer: CardTypeContainer

    @objc public var cardNumberSeparator: String

    @objc public var cardNumber: CardNumber {
        let textFieldTextWithoutSeparators = cardNumberFormat.removeSeparator(cardNumber: text ?? .empty)
        return CardNumber(rawValue: textFieldTextWithoutSeparators)
    }

    @objc public var cardType: CardType {
        CardValidator.cardType(for: cardNumber.rawValue, cardTypes: cardTypeContainer.cardTypes)
    }

    @objc public var isCVVRequired: Bool {
        CardValidator.isCVVRequired(for: cardType)
    }

    @objc override public var isInputValid: Bool {
        let cardType = CardValidator.cardType(for: cardNumber.rawValue, cardTypes: cardTypeContainer.cardTypes)
        return CardValidator.cardNumberHasValidLength(cardNumber: cardNumber.rawValue, card: cardType) && CardValidator.isCardNumberLuhnCompliant(cardNumber: cardNumber.rawValue)
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - cardTypeContainer: A card type container that is used to access accepted card types.
    ///   - cardNumberSeparator: A separator that is used to separate different groups of the card number.
    ///   - inputViewStyleManager: instance of manager to customize view
    ///   - inputViewDarkModeStyleManager: instance of dark mode manager to customize view
    @objc public init(cardTypeContainer: CardTypeContainer = CardTypeContainer(cardTypes: CardType.allCases), cardNumberSeparator: String = .space, inputViewStyleManager: InputViewStyleManager? = nil, inputViewDarkModeStyleManager: InputViewStyleManager? = nil) {
        self.cardTypeContainer = cardTypeContainer
        self.cardNumberSeparator = cardNumberSeparator
        super.init(inputViewStyleManager: inputViewStyleManager, inputViewDarkModeStyleManager: inputViewDarkModeStyleManager)
        accessibilityIdentifier = "st-card-number-input"
        textField.accessibilityIdentifier = "st-card-number-input-textfield"
        errorLabel.accessibilityIdentifier = "st-card-number-message"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Functions

    private func showCardImage() {
        let cardType = CardValidator.cardType(for: cardNumber.rawValue, cardTypes: cardTypeContainer.cardTypes)
        let cardTypeImage = cardType.logo

        if cardType == .unknown {
            textFieldImage = cardTypeImage
        } else {
            textFieldCardImage = cardTypeImage
        }
    }
}

public extension CardNumberInputView {
    /// - SeeAlso: SecureFormInputView.customizeView
    override func customizeView() {
        super.customizeView()
        showCardImage()
    }

    /// - SeeAlso: SecureFormInputView.setupProperties
    override func setupProperties() {
        super.setupProperties()

        title = LocalizableKeys.CardNumberInputView.title.localizedStringOrEmpty
        placeholder = LocalizableKeys.CardNumberInputView.placeholder.localizedStringOrEmpty
        error = LocalizableKeys.CardNumberInputView.error.localizedStringOrEmpty
        emptyError = LocalizableKeys.CardNumberInputView.emptyError.localizedStringOrEmpty

        keyboardType = .numberPad
    }
}

// MARK: TextField delegate

public extension CardNumberInputView {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldTextWithSeparators = NSString(string: textField.text ?? .empty)
        let newTextWithSeparators = textFieldTextWithSeparators.replacingCharacters(in: range, with: string)
        let newTextWithoutSeparators = cardNumberFormat.removeSeparator(cardNumber: newTextWithSeparators)

        if !newTextWithoutSeparators.isEmpty, !newTextWithoutSeparators.isNumeric {
            return false
        }

        let isOldValid = isInputValid

        let parsedCardNumber = CardNumber(rawValue: newTextWithoutSeparators).rawValue
        let parsedCardType = CardValidator.cardType(for: parsedCardNumber, cardTypes: cardTypeContainer.cardTypes)
        let isNewValid = CardValidator.cardNumberHasValidLength(cardNumber: parsedCardNumber, card: parsedCardType) && CardValidator.isCardNumberLuhnCompliant(cardNumber: parsedCardNumber)

        let isNewNumberTooLong = CardValidator.isNumberTooLong(cardNumber: parsedCardNumber, card: CardValidator.cardType(for: parsedCardNumber, cardTypes: cardTypeContainer.cardTypes))

        if !isNewNumberTooLong {
            cardNumberFormat.addSeparators(range: range, inTextField: textField, replaceWith: string)
            showCardImage()
            cardNumberInputViewDelegate?.cardNumberInputViewDidChangeText(self)
        } else if isOldValid {
            showHideError(show: false)
            cardNumberInputViewDelegate?.cardNumberInputViewDidComplete(self)
            return false
        }

        if isNewValid {
            showHideError(show: false)
            cardNumberInputViewDelegate?.cardNumberInputViewDidComplete(self)
        }

        return false
    }
}
