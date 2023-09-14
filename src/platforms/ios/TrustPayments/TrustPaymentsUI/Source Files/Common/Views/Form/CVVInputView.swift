//
//  CVVInputView.swift
//  TrustPaymentsUI
//

#if !COCOAPODS
    import TrustPaymentsCard
    import TrustPaymentsCore
#endif
import UIKit

@objc public final class CVVInputView: DefaultSecureFormInputView, CVVInput {
    // MARK: Private Properties

    private var expectedInputLength: Int {
        cardType.cvvLength
    }

    // MARK: Public Properties

    @objc public var cardType = CardType.unknown {
        didSet {
            placeholder = placeholderForTextField(cardType: cardType, expectedLength: expectedInputLength)
        }
    }

    @objc public var cvv: CVV? {
        guard let text = text, !text.isEmpty else { return nil }
        return CVV(rawValue: text)
    }

    @objc override public var isInputValid: Bool {
        if !CardValidator.isCVVRequired(for: cardType) {
            return true
        }

        return CardValidator.isCVVValid(cvv: cvv?.rawValue ?? .empty, cardType: cardType)
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - inputViewStyleManager: instance of manager to customize view
    ///   - inputViewDarkModeStyleManager: instance of dark mode manager to customize view
    @objc override public init(inputViewStyleManager: InputViewStyleManager? = nil, inputViewDarkModeStyleManager: InputViewStyleManager? = nil) {
        super.init(inputViewStyleManager: inputViewStyleManager, inputViewDarkModeStyleManager: inputViewDarkModeStyleManager)
        accessibilityIdentifier = "st-security-code-input"
        textField.accessibilityIdentifier = "st-security-code-input-textfield"
        errorLabel.accessibilityIdentifier = "st-security-code-input-message"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension CVVInputView {
    /// - SeeAlso: SecureFormInputView.setupProperties
    override func setupProperties() {
        super.setupProperties()

        title = LocalizableKeys.CVVInputView.title.localizedStringOrEmpty
        placeholder = placeholderForTextField(cardType: cardType, expectedLength: expectedInputLength)

        error = LocalizableKeys.CVVInputView.error.localizedStringOrEmpty
        emptyError = LocalizableKeys.CVVInputView.emptyError.localizedStringOrEmpty

        keyboardType = .numberPad

        isSecuredTextEntry = true

        textFieldTextAligment = .center

        textFieldImage = UIImage(named: "cvv", in: Bundle(for: CVVInputView.self), compatibleWith: nil)
    }
}

// MARK: TextField delegate

public extension CVVInputView {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text ?? .empty).replacingCharacters(in: range, with: string)

        if !newText.isEmpty, !newText.isNumeric {
            return false
        }

        let hasOverflow = newText.count > expectedInputLength
        let index = hasOverflow ?
            newText.index(newText.startIndex, offsetBy: expectedInputLength) :
            newText.index(newText.startIndex, offsetBy: newText.count)
        let currentTextFieldText = String(newText[..<index])

        textField.text = currentTextFieldText

        if isInputValid {
            showHideError(show: false)
        }

        return false
    }
}

// MARK: Helper methods

private extension CVVInputView {
    func placeholderForTextField(cardType _: CardType, expectedLength _: Int) -> String {
        let cvv3Characters = LocalizableKeys.CVVInputView.placeholder3.localizedStringOrEmpty
        let cvv4Characters = LocalizableKeys.CVVInputView.placeholder4.localizedStringOrEmpty
        return expectedInputLength == 3 ? cvv3Characters : cvv4Characters
    }
}
