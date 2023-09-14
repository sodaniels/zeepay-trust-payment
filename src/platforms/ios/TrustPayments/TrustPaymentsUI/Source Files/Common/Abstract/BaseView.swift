//
//  BaseView.swift
//  TrustPaymentsUI
//

import UIKit

@objc open class BaseView: UIView {
    /// Indicating if keyboard should be closed on touch
    @objc var closeKeyboardOnTouch = true

    /// Initialize an instance and calls required methods
    @objc public init() {
        super.init(frame: .zero)
        guard let setupableView = self as? ViewSetupable else { return }
        setupableView.setupView()
        highlightIfNeeded()
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// - SeeAlso: UIView.touchesBegan()
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if closeKeyboardOnTouch {
            endEditing(true)
        }
    }
}

extension BaseView {
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        performBlockIfAppearanceChanged(from: previousTraitCollection) {
            guard let setupableView = self as? ViewSetupable else { return }
            setupableView.customizeView()
        }
    }
}
