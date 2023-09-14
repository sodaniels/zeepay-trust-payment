//
//  InputViewStyleManager.swift
//  TrustPaymentsUI
//

import UIKit

@objc public class HeightMargins: NSObject {
    @objc public var top: CGFloat
    @objc public var bottom: CGFloat

    @objc public init(top: CGFloat, bottom: CGFloat) {
        self.top = top
        self.bottom = bottom
    }
}

/// Input views style manager.
///
/// Use it to configure input views appearance. See the `init()` method for possible options.
@objc public class InputViewStyleManager: NSObject {
    // MARK: - colors

    @objc public var titleColor: UIColor?
    @objc public var textFieldBorderColor: UIColor?
    @objc public var textFieldBackgroundColor: UIColor?
    @objc public var textColor: UIColor?
    @objc public var placeholderColor: UIColor?
    @objc public var errorColor: UIColor?
    @objc public var textFieldImageColor: UIColor?

    // MARK: - fonts

    @objc public var titleFont: UIFont?
    @objc public var textFont: UIFont?
    @objc public var placeholderFont: UIFont?
    @objc public var errorFont: UIFont?

    // MARK: - images

    @objc public var textFieldImage: UIImage?

    // MARK: - spacing/sizes

    @objc public var titleSpacing: CGFloat
    @objc public var errorSpacing: CGFloat
    @objc public var textFieldHeightMargins: HeightMargins?
    @objc public var textFieldBorderWidth: CGFloat
    @objc public var textFieldCornerRadius: CGFloat

    /// Initialize the input style manager for configuration for all input views that are present of DropIn View
    /// - Parameters:
    ///   - titleColor: Title color displayed above input view
    ///   - textFieldBorderColor: Border color of input text view
    ///   - textFieldBackgroundColor: Background color of input text view
    ///   - textColor: Text color of input view
    ///   - placeholderColor: Placeholder color of input view
    ///   - errorColor: Error text color displayed below input view
    ///   - textFieldImageColor: Color of the input view thumbnail displayed on the left
    ///   - titleFont: Font of the title
    ///   - textFont: Font on the input view
    ///   - placeholderFont: Font of the placeholder text
    ///   - errorFont: Font of the error message
    ///   - textFieldImage: Thumbnail of the input view
    ///   - titleSpacing: Spacing between title and required field mark
    ///   - errorSpacing: Spacing for the error message
    ///   - textFieldHeightMargins: Height margin of the input view, can be used to adjust input view size
    ///   - textFieldBorderWidth: Border width of the input view
    ///   - textFieldCornerRadius: Corner radius if the input view
    @objc public init(titleColor: UIColor?, textFieldBorderColor: UIColor?, textFieldBackgroundColor: UIColor?, textColor: UIColor?, placeholderColor: UIColor?, errorColor: UIColor?, textFieldImageColor: UIColor?, titleFont: UIFont?, textFont: UIFont?, placeholderFont: UIFont?, errorFont: UIFont?, textFieldImage: UIImage?, titleSpacing: CGFloat = 5, errorSpacing: CGFloat = 5, textFieldHeightMargins: HeightMargins? = nil, textFieldBorderWidth: CGFloat = 2, textFieldCornerRadius: CGFloat = 5) {
        self.titleColor = titleColor
        self.textFieldBorderColor = textFieldBorderColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.errorColor = errorColor
        self.textFieldImageColor = textFieldImageColor
        self.titleFont = titleFont
        self.textFont = textFont
        self.placeholderFont = placeholderFont
        self.errorFont = errorFont
        self.textFieldImage = textFieldImage
        self.titleSpacing = titleSpacing
        self.errorSpacing = errorSpacing
        self.textFieldHeightMargins = textFieldHeightMargins
        self.textFieldBorderWidth = textFieldBorderWidth
        self.textFieldCornerRadius = textFieldCornerRadius
    }

    /// Default configuration of the input views appearance properties
    /// - Returns: Configured InputViewStyleManager
    @objc public static func defaultLight() -> InputViewStyleManager {
        InputViewStyleManager(titleColor: UIColor.gray,
                              textFieldBorderColor: UIColor.black.withAlphaComponent(0.8),
                              textFieldBackgroundColor: .clear,
                              textColor: .black,
                              placeholderColor: UIColor.lightGray.withAlphaComponent(0.8),
                              errorColor: UIColor.red.withAlphaComponent(0.8),
                              textFieldImageColor: .black,
                              titleFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                              textFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                              placeholderFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                              errorFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                              textFieldImage: nil,
                              titleSpacing: 5,
                              errorSpacing: 3,
                              textFieldHeightMargins: HeightMargins(top: 10, bottom: 10),
                              textFieldBorderWidth: 1,
                              textFieldCornerRadius: 6)
    }

    @objc public static func defaultDark() -> InputViewStyleManager {
        InputViewStyleManager(titleColor: UIColor.white,
                              textFieldBorderColor: UIColor.white.withAlphaComponent(0.8),
                              textFieldBackgroundColor: .clear,
                              textColor: .white,
                              placeholderColor: UIColor.white.withAlphaComponent(0.8),
                              errorColor: UIColor.red.withAlphaComponent(0.8),
                              textFieldImageColor: .white,
                              titleFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                              textFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                              placeholderFont: UIFont.systemFont(ofSize: 16, weight: .regular),
                              errorFont: UIFont.systemFont(ofSize: 12, weight: .regular),
                              textFieldImage: nil,
                              titleSpacing: 5,
                              errorSpacing: 3,
                              textFieldHeightMargins: HeightMargins(top: 10, bottom: 10),
                              textFieldBorderWidth: 1,
                              textFieldCornerRadius: 6)
    }
}
