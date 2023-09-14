//
//  ApplePayButton.swift
//  TrustPaymentsUI
//

import PassKit

class ApplePayButton: UIButton {
    // MARK: Private properties

    private let payButton: PKPaymentButton
    private let style: PKPaymentButtonStyle
    private let darkModeStyle: PKPaymentButtonStyle
    private let edgeInsets: UIEdgeInsets

    // MARK: Initialization

    /// Initialize an instance and calls required methods
    /// - Parameters:
    ///   - style: Button style
    ///   - darkModeStyle: Dark mode button style
    ///   - type: Button type
    ///   - insets: content edge insets
    init(style: PKPaymentButtonStyle = .black, darkModeStyle: PKPaymentButtonStyle = .white, type: PKPaymentButtonType = .plain, insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)) {
        self.style = style
        self.darkModeStyle = darkModeStyle
        payButton = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: style)
        edgeInsets = insets
        super.init(frame: .zero)
        configureView()
    }

    var buttonTappedClosure: (() -> Void)? {
        get { payButton.onTap }
        set { payButton.onTap = newValue }
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private functions

    private func configureView() {
        addSubview(payButton)
        payButton.addConstraints([
            equal(self, \.topAnchor, \.topAnchor, constant: 0),
            equal(self, \.bottomAnchor, \.bottomAnchor, constant: 0),
            equal(self, \.leadingAnchor, \.leadingAnchor, constant: 0),
            equal(self, \.trailingAnchor, \.trailingAnchor, constant: 0)
        ])
        contentEdgeInsets = edgeInsets
        updateButtonStyle()
        highlightIfNeeded()
    }

    private func updateButtonStyle() {
        var currentStyle: PKPaymentButtonStyle
        if #available(iOS 12.0, *) {
            currentStyle = traitCollection.userInterfaceStyle == .dark ? darkModeStyle : style
        } else {
            currentStyle = style
        }
        payButton.setValue(currentStyle.rawValue, forKey: "style")
    }
}

extension ApplePayButton {
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateButtonStyle()
        }
    }
}
