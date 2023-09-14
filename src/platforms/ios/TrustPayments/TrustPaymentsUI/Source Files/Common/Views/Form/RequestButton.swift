//
//  RequestButton.swift
//  TrustPaymentsUI
//

import UIKit

/// Button with optional spinner functionality, meant to be subclassed
@objc open class RequestButton: UIButton {
    // MARK: Private properties

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    let requestButtonStyleManager: RequestButtonStyleManager?
    let requestButtonDarkModeStyleManager: RequestButtonStyleManager?

    // MARK: Public properties

    @objc override public var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = enabledBackgroundColor
            } else {
                backgroundColor = disabledBackgroundColor
            }
        }
    }

    // MARK: - texts

    @objc public var title: String = "request" {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    // MARK: - fonts

    @objc public var titleFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            titleLabel?.font = titleFont
        }
    }

    // MARK: - colors

    @objc public var enabledBackgroundColor: UIColor = .darkGray

    @objc public var disabledBackgroundColor = UIColor.darkGray.withAlphaComponent(0.5)

    @objc public var titleColor: UIColor = .white {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }

    @objc public var borderColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    // MARK: - loading spinner

    @objc public var spinnerStyle: UIActivityIndicatorView.Style = .white {
        didSet {
            spinner.style = spinnerStyle
        }
    }

    @objc public var spinnerColor: UIColor = .white {
        didSet {
            spinner.color = spinnerColor
        }
    }

    // MARK: - sizes

    @objc public var buttonContentHeightMargins = HeightMargins(top: 10, bottom: 10) {
        didSet {
            contentEdgeInsets = UIEdgeInsets(top: buttonContentHeightMargins.top, left: 0, bottom: buttonContentHeightMargins.bottom, right: 0)
        }
    }

    @objc public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @objc public var cornerRadius: CGFloat = 5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    // MARK: Initialization

    /// Initialize an instance and calls required methods
    /// - Parameters:
    ///   - requestButtonStyleManager: instance of manager to customize view
    ///   - requestButtonDarkModeStyleManager: instance of dark mode manager to customize view
    @objc public init(requestButtonStyleManager: RequestButtonStyleManager? = nil, requestButtonDarkModeStyleManager: RequestButtonStyleManager? = nil) {
        self.requestButtonStyleManager = requestButtonStyleManager
        self.requestButtonDarkModeStyleManager = requestButtonDarkModeStyleManager
        super.init(frame: .zero)
        configureView()
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private functions

    open func configureView() {
        addSubview(spinner)
        spinner.addConstraints([
            equal(self, \.centerYAnchor),
            equal(self, \.trailingAnchor, constant: -15)
        ])

        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius

        contentEdgeInsets = UIEdgeInsets(top: buttonContentHeightMargins.top, left: 0, bottom: buttonContentHeightMargins.bottom, right: 0)
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping

        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = titleFont

        spinner.style = spinnerStyle
        spinner.color = spinnerColor

        customizeView()

        highlightIfNeeded()
        isEnabled = false
    }

    private func customizeView() {
        var styleManager: RequestButtonStyleManager!
        if #available(iOS 12.0, *) {
            styleManager = traitCollection.userInterfaceStyle == .dark && requestButtonDarkModeStyleManager != nil ? requestButtonDarkModeStyleManager : requestButtonStyleManager
        } else {
            styleManager = requestButtonStyleManager
        }
        customizeView(requestButtonStyleManager: styleManager)

        backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
    }

    private func customizeView(requestButtonStyleManager: RequestButtonStyleManager?) {
        if let titleColor = requestButtonStyleManager?.titleColor {
            self.titleColor = titleColor
        }

        if let enabledBackgroundColor = requestButtonStyleManager?.enabledBackgroundColor {
            self.enabledBackgroundColor = enabledBackgroundColor
        }

        if let disabledBackgroundColor = requestButtonStyleManager?.disabledBackgroundColor {
            self.disabledBackgroundColor = disabledBackgroundColor
        }

        if let borderColor = requestButtonStyleManager?.borderColor {
            self.borderColor = borderColor
        }

        if let titleFont = requestButtonStyleManager?.titleFont {
            self.titleFont = titleFont
        }

        if let spinnerStyle = requestButtonStyleManager?.spinnerStyle {
            self.spinnerStyle = spinnerStyle
        }

        if let spinnerColor = requestButtonStyleManager?.spinnerColor {
            self.spinnerColor = spinnerColor
        }

        if let buttonContentHeightMargins = requestButtonStyleManager?.buttonContentHeightMargins {
            self.buttonContentHeightMargins = buttonContentHeightMargins
        }

        if let borderWidth = requestButtonStyleManager?.borderWidth {
            self.borderWidth = borderWidth
        }

        if let cornerRadius = requestButtonStyleManager?.cornerRadius {
            self.cornerRadius = cornerRadius
        }
    }

    // MARK: Public functions

    @objc public func startProcessing() {
        isUserInteractionEnabled = false
        spinner.startAnimating()
    }

    @objc public func stopProcessing() {
        isUserInteractionEnabled = true
        spinner.stopAnimating()
    }
}

extension RequestButton {
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.customizeView()
        }
    }
}
