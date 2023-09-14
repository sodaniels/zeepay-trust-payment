//
//  CardinalStyleManager.swift
//  TrustPayments3DSecure
//

import UIKit

/// Font object used by the 3DS challenge view.
/// ```
/// let cardinalDefaultFont = CardinalFont(name: "TimesNewRomanPSMT", size: 17)
/// ```
/// - warning: Test appearance of your fonts as not all are supported.
@objc public class CardinalFont: NSObject {
    @objc public var size: CGFloat
    @objc public var name: String?

    @objc public init(name: String? = nil, size: CGFloat) {
        self.name = name
        self.size = size
    }
}

/// Style object used to configure toolbar of the 3DS challenge view.
@objc public class CardinalToolbarStyleManager: NSObject {
    // MARK: - colors

    @objc public var textColor: UIColor?
    @objc public var backgroundColor: UIColor?

    // MARK: - fonts

    @objc public var textFont: CardinalFont?

    // MARK: - texts

    @objc public var headerText: String?
    @objc public var buttonText: String?

    /// Initialization of the Cardinal Toolbar configuration object.
    /// - Parameters:
    ///   - textColor: Text color displayed on the center of the toolbar
    ///   - textFont: Text font
    ///   - backgroundColor: Background color fo the toolbar
    ///   - headerText: Text displayed in the center of the toolbar
    ///   - buttonText: Action button title displayed on the right side of the toolbar, used for canceling the 3DS flow
    @objc public init(textColor: UIColor?, textFont: CardinalFont?, backgroundColor: UIColor?, headerText: String?, buttonText: String?) {
        self.textColor = textColor
        self.textFont = textFont
        self.backgroundColor = backgroundColor
        self.headerText = headerText
        self.buttonText = buttonText
    }
}

/// Style object used to configure text label of the 3DS challenge view.
@objc public class CardinalLabelStyleManager: NSObject {
    // MARK: - colors

    @objc public var textColor: UIColor?
    @objc public var headingTextColor: UIColor?

    // MARK: - fonts

    @objc public var textFont: CardinalFont?
    @objc public var headingTextFont: CardinalFont?

    /// Initialization of the Cardinal Label configuration object.
    /// - Parameters:
    ///   - textColor: Text color fo the label
    ///   - textFont: Text's font
    ///   - headingTextColor: Heading text color
    ///   - headingTextFont: Heading text font
    @objc public init(textColor: UIColor?, textFont: CardinalFont?, headingTextColor: UIColor?, headingTextFont: CardinalFont?) {
        self.textColor = textColor
        self.textFont = textFont
        self.headingTextColor = headingTextColor
        self.headingTextFont = headingTextFont
    }
}

/// Style object used to configure 'submit' button of the 3DS challenge view.
@objc public class CardinalButtonStyleManager: NSObject {
    // MARK: - colors

    @objc public var textColor: UIColor?
    @objc public var backgroundColor: UIColor?

    // MARK: - fonts

    @objc public var textFont: CardinalFont?

    // MARK: - sizes

    @objc public var cornerRadius: CGFloat

    /// Initialization of the Cardinal `Submit`button configuration object.
    /// - Parameters:
    ///   - textColor: Button's text color
    ///   - textFont: Button's text font
    ///   - backgroundColor: Button's background color
    ///   - cornerRadius: Button's corner radius
    @objc public init(textColor: UIColor?, textFont: CardinalFont?, backgroundColor: UIColor?, cornerRadius: CGFloat) {
        self.textColor = textColor
        self.textFont = textFont
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
}

/// Style object used to configure main text view of the 3DS challenge view.
@objc public class CardinalTextBoxStyleManager: NSObject {
    // MARK: - colors

    @objc public var textColor: UIColor?
    @objc public var borderColor: UIColor?

    // MARK: - fonts

    @objc public var textFont: CardinalFont?

    // MARK: - sizes

    @objc public var cornerRadius: CGFloat
    @objc public var borderWidth: CGFloat

    /// Initialization of the Cardinal main text view configuration object.
    /// - Parameters:
    ///   - textColor: Text color
    ///   - textFont: Text font
    ///   - borderColor: Border color
    ///   - cornerRadius: Corner radius
    ///   - borderWidth: Border width
    @objc public init(textColor: UIColor?, textFont: CardinalFont?, borderColor: UIColor?, cornerRadius: CGFloat, borderWidth: CGFloat) {
        self.textColor = textColor
        self.textFont = textFont
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
    }
}

/// Style manager object used to configure appearance of the 3DS challenge view
@objc public class CardinalStyleManager: NSObject {
    @objc public var toolbarStyleManager: CardinalToolbarStyleManager?
    @objc public var labelStyleManager: CardinalLabelStyleManager?
    @objc public var verifyButtonStyleManager: CardinalButtonStyleManager?
    @objc public var continueButtonStyleManager: CardinalButtonStyleManager?
    @objc public var resendButtonStyleManager: CardinalButtonStyleManager?
    @objc public var textBoxStyleManager: CardinalTextBoxStyleManager?

    @objc public init(toolbarStyleManager: CardinalToolbarStyleManager?, labelStyleManager: CardinalLabelStyleManager?, verifyButtonStyleManager: CardinalButtonStyleManager?, continueButtonStyleManager: CardinalButtonStyleManager?, resendButtonStyleManager: CardinalButtonStyleManager?, textBoxStyleManager: CardinalTextBoxStyleManager?) {
        self.toolbarStyleManager = toolbarStyleManager
        self.labelStyleManager = labelStyleManager
        self.verifyButtonStyleManager = verifyButtonStyleManager
        self.continueButtonStyleManager = continueButtonStyleManager
        self.resendButtonStyleManager = resendButtonStyleManager
        self.textBoxStyleManager = textBoxStyleManager
    }
}
