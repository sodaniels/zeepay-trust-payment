//
//  DropInViewStyleManager.swift
//  TrustPaymentsUI
//

import UIKit

/// DropIn view style manager.
/// Use it to style the drop-in view to match general appearance of your application.
///
/// Properties that are configurable:
/// - Background color
/// - Input fields
/// - Request button (Pay/Add Card button)
/// - ZIP Button style configuration
/// - Spacing and insets between UI components
@objc public class DropInViewStyleManager: NSObject {
    @objc public var inputViewStyleManager: InputViewStyleManager?
    @objc public var requestButtonStyleManager: RequestButtonStyleManager?
    @objc public var zipButtonStyleManager: ZIPButtonStyleManager?
    @objc public var ataButtonStyleManager: ATAButtonStyleManager?
    @objc public var backgroundColor: UIColor?
    @objc public var spacingBetweenInputViews: CGFloat
    @objc public var insets: UIEdgeInsets

    /// Configure drop-in view appearance
    /// - Parameters:
    ///   - inputViewStyleManager: Configures all input fields with the same settings
    ///   - requestButtonStyleManager: Configures request button (Pay button, Add card button)
    ///   - zipButtonStyleManager: Configures ZIP button
    ///   - ataButtonStyleManager: Configures ATA button
    ///   - backgroundColor: Background color of the whole view
    ///   - spacingBetweenInputViews: Spacing between UI components
    ///   - insets: Insets between main view bounds and all UI components
    @objc public init(inputViewStyleManager: InputViewStyleManager?,
                      requestButtonStyleManager: RequestButtonStyleManager?,
                      zipButtonStyleManager: ZIPButtonStyleManager? = nil,
                      ataButtonStyleManager: ATAButtonStyleManager? = nil,
                      backgroundColor: UIColor?,
                      spacingBetweenInputViews: CGFloat = 30,
                      insets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: -15, right: -30)) {
        self.inputViewStyleManager = inputViewStyleManager
        self.requestButtonStyleManager = requestButtonStyleManager
        self.zipButtonStyleManager = zipButtonStyleManager
        self.ataButtonStyleManager = ataButtonStyleManager
        self.backgroundColor = backgroundColor
        self.spacingBetweenInputViews = spacingBetweenInputViews
        self.insets = insets
    }
}
