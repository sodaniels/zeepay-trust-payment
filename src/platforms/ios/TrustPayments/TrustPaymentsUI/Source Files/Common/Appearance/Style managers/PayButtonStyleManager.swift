//
//  PayButtonStyleManager.swift
//  TrustPaymentsUI
//

import UIKit

@objc public class PayButtonStyleManager: RequestButtonStyleManager {
    /// Default appearance configuration of the Pay Button
    /// - Returns: Configured PayButtonStyleManager
    @objc public static func defaultLight() -> PayButtonStyleManager {
        PayButtonStyleManager(titleColor: .white,
                              enabledBackgroundColor: .black,
                              disabledBackgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                              borderColor: .clear,
                              titleFont: UIFont.systemFont(ofSize: 16, weight: .medium),
                              spinnerStyle: .white,
                              spinnerColor: .white,
                              buttonContentHeightMargins: HeightMargins(top: 15, bottom: 15),
                              borderWidth: 0,
                              cornerRadius: 6)
    }

    @objc public static func defaultDark() -> PayButtonStyleManager {
        PayButtonStyleManager(titleColor: .black,
                              enabledBackgroundColor: .white,
                              disabledBackgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                              borderColor: .clear,
                              titleFont: UIFont.systemFont(ofSize: 16, weight: .medium),
                              spinnerStyle: .gray,
                              spinnerColor: .black,
                              buttonContentHeightMargins: HeightMargins(top: 15, bottom: 15),
                              borderWidth: 0,
                              cornerRadius: 6)
    }
}
