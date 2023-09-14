//
//  LocalizableKeys.swift
//  TrustPaymentsCore
//

import Foundation

public protocol LocalizableKey {}
public extension LocalizableKey {
    /// Returns String representing LocalizableKeys as a String
    /// LocalizableKeys.PayButton.title -> "PayButton.title"
    var key: String {
        String(describing: "\(type(of: self)).\(self)")
    }

    /// Used to shorten slightly notation
    /// TrustPayments.translation(for: LocalizableKeys.PayButton.title) -> LocalizableKeys.PayButton.title.localizedString
    var localizedString: String? {
        TrustPayments.translation(for: self)
    }

    var localizedStringOrEmpty: String {
        TrustPayments.translation(for: self) ?? ""
    }
}

/// Possible translation keys to use or override when custom translations are needed.
public enum LocalizableKeys {
    // MARK: Pay Button

    public enum PayButton: LocalizableKey {
        case title
        case ataPayByBank
    }

    // MARK: DropIn View Controller

    public enum DropInViewController: LocalizableKey {
        case successfulPayment
    }

    // MARK: Errors

    public enum Errors: LocalizableKey {
        case general
    }

    // MARK: CardNumberInputView

    public enum CardNumberInputView: LocalizableKey {
        case title
        case placeholder
        case error
        case emptyError
    }

    // MARK: CVVInputView

    public enum CVVInputView: LocalizableKey {
        case title
        case placeholder3
        case placeholder4
        case error
        case emptyError
    }

    // MARK: ExpiryDateInputView

    public enum ExpiryDateInputView: LocalizableKey {
        case title
        case placeholder
        case error
        case emptyError
    }
    
    // MARK: ExpiryDatePickerView

    public enum ExpiryDatePickerView: LocalizableKey {
        case month
        case year
    }

    // MARK: AddCardButton

    public enum AddCardButton: LocalizableKey {
        case title
    }

    // MARK: Alerts

    public enum Alerts: LocalizableKey {
        case processing
    }

    // MARK: Challenge view

    public enum ChallengeView: LocalizableKey {
        case headerTitle
        case headerCancelTitle
    }
}

// Objc workaround for LocalizableKeys
/// Available keys to override when custom translation is needed.
@objc public enum LocalizableKeysObjc: Int {
    // swiftlint:disable identifier_name
    // underscores used for clarity: _payButton_title -> LocalizableKeysObjc_payButton_title
    case _payButton_title = 0

    case _dropInViewController_successfulPayment

    case _errors_general

    case _cardNumberInputView_title
    case _cardNumberInputView_placeholder
    case _cardNumberInputView_error
    case _cardNumberInputView_emptyError

    case _cvvInputView_title
    case _cvvInputView_placeholder3
    case _cvvInputView_placeholder4
    case _cvvInputView_error
    case _cvvInputView_emptyError

    case _expiryDateInputView_title
    case _expiryDateInputView_placeholder
    case _expiryDateInputView_error
    case _expiryDateInputView_emptyError

    case _expiryDatePickerView_month
    case _expiryDatePickerView_year
    
    case _addCardButton_title

    case _alerts_processing

    case _challengeView_headerTitle
    case _challengeView_headerCancelTitle
    
    case _ataPayByBank

    var swiftValue: LocalizableKey {
        switch self {
        case ._payButton_title: return LocalizableKeys.PayButton.title

        case ._dropInViewController_successfulPayment: return LocalizableKeys.DropInViewController.successfulPayment

        case ._errors_general: return LocalizableKeys.Errors.general

        case ._cardNumberInputView_title: return LocalizableKeys.CardNumberInputView.title
        case ._cardNumberInputView_placeholder: return LocalizableKeys.CardNumberInputView.placeholder
        case ._cardNumberInputView_error: return LocalizableKeys.CardNumberInputView.error
        case ._cardNumberInputView_emptyError: return LocalizableKeys.CardNumberInputView.emptyError

        case ._cvvInputView_title: return LocalizableKeys.CVVInputView.title
        case ._cvvInputView_placeholder3: return LocalizableKeys.CVVInputView.placeholder3
        case ._cvvInputView_placeholder4: return LocalizableKeys.CVVInputView.placeholder4
        case ._cvvInputView_error: return LocalizableKeys.CVVInputView.error
        case ._cvvInputView_emptyError: return LocalizableKeys.CVVInputView.emptyError

        case ._expiryDateInputView_title: return LocalizableKeys.ExpiryDateInputView.title
        case ._expiryDateInputView_placeholder: return LocalizableKeys.ExpiryDateInputView.placeholder
        case ._expiryDateInputView_error: return LocalizableKeys.ExpiryDateInputView.error
        case ._expiryDateInputView_emptyError: return LocalizableKeys.ExpiryDateInputView.emptyError
            
        case ._expiryDatePickerView_month: return LocalizableKeys.ExpiryDatePickerView.month
        case ._expiryDatePickerView_year: return LocalizableKeys.ExpiryDatePickerView.year

        case ._addCardButton_title: return LocalizableKeys.AddCardButton.title

        case ._alerts_processing: return LocalizableKeys.Alerts.processing

        case ._challengeView_headerTitle: return LocalizableKeys.ChallengeView.headerTitle
        case ._challengeView_headerCancelTitle: return LocalizableKeys.ChallengeView.headerCancelTitle
            
        case ._ataPayByBank: return LocalizableKeys.PayButton.ataPayByBank
        }
    }

    /// Used for mapping objc enum into TranslationsKeys
    var code: String {
        swiftValue.key
    }

    var localizedString: String? {
        swiftValue.localizedString
    }

    var localizedStringOrEmpty: String {
        swiftValue.localizedStringOrEmpty
    }
}

/// exposing translations in objc
@objc public class LocalizableKeysContainer: NSObject {
    @objc override private init() {}
    @objc public static func localizedString(key: LocalizableKeysObjc) -> String? {
        key.localizedString
    }

    @objc public static func localizedStringOrEmpty(key: LocalizableKeysObjc) -> String? {
        key.localizedStringOrEmpty
    }
}
