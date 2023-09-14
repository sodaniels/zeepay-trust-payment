//
//  RequestButtonStyleManager.swift
//  TrustPaymentsUI
//

import UIKit

/// General request button style manager
///
/// Subclassed by Pay button, Add card button and Next button. Refer to the `init()` for available options.
@objc public class RequestButtonStyleManager: NSObject {
    // MARK: - colors

    @objc public var titleColor: UIColor?
    @objc public var enabledBackgroundColor: UIColor?
    @objc public var disabledBackgroundColor: UIColor?
    @objc public var borderColor: UIColor?

    // MARK: - fonts

    @objc public var titleFont: UIFont?

    // MARK: - loading spinner

    @objc public var spinnerStyle: UIActivityIndicatorView.Style
    @objc public var spinnerColor: UIColor?

    // MARK: - spacing/sizes

    @objc public var buttonContentHeightMargins: HeightMargins?
    @objc public var borderWidth: CGFloat
    @objc public var cornerRadius: CGFloat

    /// Initialize the  style manager for configuration request button that is present in the  DropIn View.
    /// - Parameters:
    ///   - titleColor: Title color of the button
    ///   - enabledBackgroundColor: Background color for the `enabled` state
    ///   - disabledBackgroundColor: Background color for the `disabled` state
    ///   - borderColor: Border color of the button
    ///   - titleFont: Font of the button's title
    ///   - spinnerStyle: Spinner style visible on the right side of the button indicating transaction is processing
    ///   - spinnerColor: Spinner color
    ///   - buttonContentHeightMargins: Height margin of the button. Can be used to adjust height of the element.
    ///   - borderWidth: Border width
    ///   - cornerRadius: Corner radius
    @objc public init(titleColor: UIColor?, enabledBackgroundColor: UIColor?, disabledBackgroundColor: UIColor?, borderColor: UIColor?, titleFont: UIFont?, spinnerStyle: UIActivityIndicatorView.Style = .white, spinnerColor: UIColor? = nil, buttonContentHeightMargins: HeightMargins? = nil, borderWidth: CGFloat = 0, cornerRadius: CGFloat = 5) {
        self.titleColor = titleColor
        self.enabledBackgroundColor = enabledBackgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.borderColor = borderColor
        self.titleFont = titleFont
        self.spinnerStyle = spinnerStyle
        self.spinnerColor = spinnerColor
        self.buttonContentHeightMargins = buttonContentHeightMargins
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
}
