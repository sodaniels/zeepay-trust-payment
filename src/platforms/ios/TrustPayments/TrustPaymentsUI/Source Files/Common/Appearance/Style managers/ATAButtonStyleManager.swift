//
//  ATAButtonStyleManager.swift
//  TrustPaymentsUI
//

import UIKit

@objc public class ATAButtonStyleManager: RequestButtonStyleManager {
    /// Default appearance configuration of the ATA Button
    /// - Returns: Configured PayButtonStyleManager
    ///
    @objc public static func dark() -> ATAButtonStyleManager {
        ATAButtonStyleManager(titleColor: .black,
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

    @objc public static func light() -> ATAButtonStyleManager {
        ATAButtonStyleManager(titleColor: .white,
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
}
