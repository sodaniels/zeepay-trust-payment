//
//  ZIPButton.swift
//  TrustPaymentsUI
//

import UIKit

/// A subclass of RequestButton, consists of ZIP graphic and spinner for the request interval
@objc public final class ZIPButton: RequestButton, ZipButtonProtocol {
    // MARK: Properties

    let zipButtonStyleManager: ZIPButtonStyleManager
    let zipButtonDarkStyleManager: ZIPButtonStyleManager

    private var currentLogo: UIImage? {
        var styleManager: ZIPButtonStyleManager!
        if #available(iOS 12.0, *) {
            styleManager = traitCollection.userInterfaceStyle == .dark ? zipButtonDarkStyleManager : zipButtonStyleManager
        } else {
            styleManager = zipButtonStyleManager
        }
        let imageName = styleManager.theme == .light ? "zip_button_light" : "zip_button_dark"
        return UIImage(named: imageName, in: Bundle(for: ZIPButton.self), compatibleWith: nil)
    }

    // MARK: Initialization

    /// Initialize an instance and calls required methods
    /// - Parameters:
    ///   - styleManager: instance of manager to customize view in light appearance
    ///   - darkModeStyleManager: instance of manager to customize view in dark appearance
    @objc public init(styleManager: ZIPButtonStyleManager?, darkModeStyleManager: ZIPButtonStyleManager?) {
        zipButtonStyleManager = styleManager ?? ZIPButtonStyleManager.light()
        zipButtonDarkStyleManager = darkModeStyleManager ?? ZIPButtonStyleManager.dark()
        super.init(requestButtonStyleManager: zipButtonStyleManager, requestButtonDarkModeStyleManager: zipButtonDarkStyleManager)
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
        accessibilityIdentifier = "zipButton"
        setImage(currentLogo, for: .normal)
        isEnabled = true
    }

    private func updateThemeForCurrentAppearance() {
        setImage(currentLogo, for: .normal)
    }
}

public extension ZIPButton {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateThemeForCurrentAppearance()
        }
    }
}
