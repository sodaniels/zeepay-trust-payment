//
//  ApplePayView.swift
//  Example
//

import PassKit

final class ApplePayView: BaseView {
    var payButtonTappedClosure: (() -> Void)? {
        get { payButton.onTap }
        set { payButton.onTap = newValue }
    }

    private(set) lazy var payButton: PKPaymentButton = {
        var buttonStyle: PKPaymentButtonStyle = .black
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                buttonStyle = .white
            }
        }
        return PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: buttonStyle)
    }()
}

extension ApplePayView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        backgroundColor = UIColor(light: .white, dark: .black)
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        addSubview(payButton)
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        payButton.addConstraints([
            equal(self, \.centerYAnchor, \.centerYAnchor, constant: 0),
            equal(self, \.centerXAnchor, \.centerXAnchor, constant: 0)
        ])
    }
}
