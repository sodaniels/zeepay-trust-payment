//
//  AddCardButton.swift
//  TrustPaymentsUI
//

import UIKit

#if !COCOAPODS
    import TrustPaymentsCore
#endif

/// A subclass of RequestButton, consists of title and spinner for the request interval
@objc public final class AddCardButton: RequestButton {
    // MARK: Properties

    let addCardButtonStyleManager: AddCardButtonStyleManager?

    // MARK: - texts

    @objc override public var title: String {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    // MARK: Initialization

    /// Initialize an instance and calls required methods
    /// - Parameters:
    ///   - addCardButtonStyleManager: instance of manager to customize view
    @objc public init(addCardButtonStyleManager: AddCardButtonStyleManager? = nil) {
        self.addCardButtonStyleManager = addCardButtonStyleManager
        super.init(requestButtonStyleManager: addCardButtonStyleManager)
        configureView()
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private functions

    override public func configureView() {
        super.configureView()
        accessibilityIdentifier = "addCardButton"
        title = LocalizableKeys.AddCardButton.title.localizedStringOrEmpty
    }
}
