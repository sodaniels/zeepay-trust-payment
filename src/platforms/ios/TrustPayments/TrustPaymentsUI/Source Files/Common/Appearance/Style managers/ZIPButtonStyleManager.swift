//
//  ZIPButtonStyleManager.swift
//  TrustPaymentsUI
//

import UIKit

@objc public enum ZIPButtonLogoTheme: Int, CaseIterable {
    case light
    case dark
}

@objc public class ZIPButtonStyleManager: RequestButtonStyleManager {
    /// Default appearance configuration of the ZIP Button
    /// - Returns: Configured PayButtonStyleManager
    let theme: ZIPButtonLogoTheme

    @objc public required init(logoTheme: ZIPButtonLogoTheme, backgroundColor: UIColor, borderColor: UIColor, borderWith: CGFloat, spinnerStyle: UIActivityIndicatorView.Style, spinnerColor: UIColor, contentHeightMargins: HeightMargins, cornerRadius: CGFloat) {
        theme = logoTheme
        super.init(titleColor: nil,
                   enabledBackgroundColor: backgroundColor,
                   disabledBackgroundColor: nil,
                   borderColor: borderColor,
                   titleFont: nil,
                   spinnerStyle: spinnerStyle,
                   spinnerColor: spinnerColor,
                   buttonContentHeightMargins: contentHeightMargins,
                   borderWidth: borderWith,
                   cornerRadius: cornerRadius)
    }

    @objc public static func dark() -> ZIPButtonStyleManager {
        ZIPButtonStyleManager(logoTheme: .dark,
                              backgroundColor: .white,
                              borderColor: .gray,
                              borderWith: 1,
                              spinnerStyle: .white,
                              spinnerColor: .gray,
                              contentHeightMargins: HeightMargins(top: 0, bottom: 0),
                              cornerRadius: 6)
    }

    @objc public static func light() -> ZIPButtonStyleManager {
        ZIPButtonStyleManager(logoTheme: .light,
                              backgroundColor: .black,
                              borderColor: .clear,
                              borderWith: 1,
                              spinnerStyle: .white,
                              spinnerColor: .white,
                              contentHeightMargins: HeightMargins(top: 0, bottom: 0),
                              cornerRadius: 6)
    }
}
