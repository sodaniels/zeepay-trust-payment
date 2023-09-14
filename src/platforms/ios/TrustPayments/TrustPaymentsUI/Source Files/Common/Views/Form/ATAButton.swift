//
//  ATAButton.swift
//  TrustPaymentsUI
//

import UIKit

#if !COCOAPODS
    import TrustPaymentsCore
#endif

/// A subclass of RequestButton, consists of title and spinner for the request interval
@objc public final class ATAButton: RequestButton, ATAButtonProtocol {
    
    // MARK: Properties

    let ataButtonStyleManager: ATAButtonStyleManager
    let ataButtonDarkStyleManager: ATAButtonStyleManager
    
    @objc override public var title: String {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    // MARK: Initialization

    /// Initialize an instance and calls required methods
    /// - Parameters:
    ///   - styleManager: instance of manager to customize view in light appearance
    ///   - darkModeStyleManager: instance of manager to customize view in dark appearance
    @objc public init(styleManager: ATAButtonStyleManager? = nil, darkModeStyleManager: ATAButtonStyleManager? = nil) {
        ataButtonStyleManager = styleManager ?? ATAButtonStyleManager.light()
        ataButtonDarkStyleManager = darkModeStyleManager ?? ATAButtonStyleManager.dark()
        super.init(requestButtonStyleManager: ataButtonStyleManager, requestButtonDarkModeStyleManager: ataButtonDarkStyleManager)
        configureView()
        accessibilityIdentifier = "ATAButton"
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private functions

    override public func configureView() {
        super.configureView()
        setTitle(LocalizableKeys.PayButton.ataPayByBank.localizedStringOrEmpty, for: .normal)
        isEnabled = true
    }
}
