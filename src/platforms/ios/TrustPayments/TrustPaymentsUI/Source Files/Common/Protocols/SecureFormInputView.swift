//
//  SecureFormInputView.swift
//  TrustPaymentsUI
//
#if !COCOAPODS
    import TrustPaymentsCard
    import TrustPaymentsCore
#endif
import UIKit

@objc public protocol InputValidation {
    @objc var isEnabled: Bool { get set }
    @objc var isInputValid: Bool { get }
    @objc func validate(silent: Bool) -> Bool
}

@objc public protocol CardNumberInput: InputValidation where Self: UIView {
    @objc var cardNumber: CardNumber { get }
}

@objc public protocol CVVInput: InputValidation where Self: UIView {
    @objc var cvv: CVV? { get }
}

@objc public protocol ExpiryDateInput: InputValidation where Self: UIView {
    @objc var expiryDate: ExpiryDate { get }
}

@objc public protocol PayButtonProtocol where Self: UIButton {
    @objc func startProcessing()
    @objc func stopProcessing()
}

@objc public protocol ZipButtonProtocol where Self: UIButton {
    @objc func startProcessing()
    @objc func stopProcessing()
}

@objc public protocol ATAButtonProtocol where Self: UIButton {
    @objc func startProcessing()
    @objc func stopProcessing()
}

@objc public protocol SecureFormInputViewDelegate: AnyObject {
    @objc func inputViewTextFieldDidEndEditing(_ view: SecureFormInputView)
    @objc func showHideError(_ show: Bool)
}

@objc public protocol SecureFormInputView: InputValidation where Self: UIView {
    @objc var isEmpty: Bool { get }

    @objc var isEnabled: Bool { get set }

    @objc var isInputValid: Bool { get }

    @objc var isSecuredTextEntry: Bool { get set }

    @objc var keyboardType: UIKeyboardType { get set }

    @objc var keyboardAppearance: UIKeyboardAppearance { get set }

    @objc var textFieldTextAligment: NSTextAlignment { get set }

    // MARK: - texts

    @objc var title: String { get set }

    @objc var text: String? { get set }

    @objc var placeholder: String { get set }

    @objc var error: String { get set }

    // MARK: - colors

    @objc var titleColor: UIColor { get set }

    @objc var textFieldBorderColor: UIColor { get set }

    @objc var textFieldBackgroundColor: UIColor { get set }

    @objc var textColor: UIColor { get set }

    @objc var placeholderColor: UIColor { get set }

    @objc var errorColor: UIColor { get set }

    @objc var textFieldImageColor: UIColor { get set }

    @objc var titleFont: UIFont { get set }

    // MARK: - fonts

    @objc var textFont: UIFont { get set }

    @objc var placeholderFont: UIFont { get set }

    @objc var errorFont: UIFont { get set }

    // MARK: - images

    @objc var textFieldImage: UIImage? { get set }

    // MARK: - spacing/sizes

    @objc var titleSpacing: CGFloat { get set }

    @objc var errorSpacing: CGFloat { get set }

    @objc var textFieldHeightMargins: HeightMargins { get set }

    @objc var textFieldBorderWidth: CGFloat { get set }

    @objc var textFieldCornerRadius: CGFloat { get set }
}

public extension SecureFormInputView {
    // swiftlint:disable cyclomatic_complexity
    func customizeView(inputViewStyleManager: InputViewStyleManager?) {
        if let titleColor = inputViewStyleManager?.titleColor {
            self.titleColor = titleColor
        }

        if let textFieldBorderColor = inputViewStyleManager?.textFieldBorderColor {
            self.textFieldBorderColor = textFieldBorderColor
        }

        if let textFieldBackgroundColor = inputViewStyleManager?.textFieldBackgroundColor {
            self.textFieldBackgroundColor = textFieldBackgroundColor
        }

        if let textColor = inputViewStyleManager?.textColor {
            self.textColor = textColor
        }

        if let placeholderColor = inputViewStyleManager?.placeholderColor {
            self.placeholderColor = placeholderColor
        }

        if let errorColor = inputViewStyleManager?.errorColor {
            self.errorColor = errorColor
        }

        if let textFieldImageColor = inputViewStyleManager?.textFieldImageColor {
            self.textFieldImageColor = textFieldImageColor
        }

        if let titleFont = inputViewStyleManager?.titleFont {
            self.titleFont = titleFont
        }

        if let textFont = inputViewStyleManager?.textFont {
            self.textFont = textFont
        }

        if let placeholderFont = inputViewStyleManager?.placeholderFont {
            self.placeholderFont = placeholderFont
        }

        if let errorFont = inputViewStyleManager?.errorFont {
            self.errorFont = errorFont
        }

        if let textFieldImage = inputViewStyleManager?.textFieldImage {
            self.textFieldImage = textFieldImage
        }

        if let titleSpacing = inputViewStyleManager?.titleSpacing {
            self.titleSpacing = titleSpacing
        }

        if let errorSpacing = inputViewStyleManager?.errorSpacing {
            self.errorSpacing = errorSpacing
        }

        if let textFieldHeightMargins = inputViewStyleManager?.textFieldHeightMargins {
            self.textFieldHeightMargins = textFieldHeightMargins
        }

        if let textFieldBorderWidth = inputViewStyleManager?.textFieldBorderWidth {
            self.textFieldBorderWidth = textFieldBorderWidth
        }

        if let textFieldCornerRadius = inputViewStyleManager?.textFieldCornerRadius {
            self.textFieldCornerRadius = textFieldCornerRadius
        }
    }

    // swiftlint:enable cyclomatic_complexity
}
