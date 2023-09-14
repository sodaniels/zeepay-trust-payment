//
//  ThreeDSecureWebViewController.swift
//  TrustPayments3DSecure
//

import UIKit
import WebKit

public class ThreeDSecureWebViewController: UIViewController {
    private var webView: WKWebView!
    private let viewModel: ThreeDSecureWebViewModel

    private var sessionAuthenticationValidatePayload: ((String) -> Void)?
    private var sessionAuthenticationFailure: (() -> Void)?

    // MARK: Initialization

    /// Initializes view controller with given view model.
    ///
    public init(viewModel: ThreeDSecureWebViewModel) {
        webView = WKWebView(frame: .zero, configuration: viewModel.webViewConfiguration)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    @available(*, unavailable, message: "Not available, use init(view:viewModel)")
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override public func loadView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtons()
        customizeView()
        webView.load(viewModel.webViewRequest)
    }

    // MARK: View customization

    /// Set up top navigation bar buttons
    private func setupBarButtons() {
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        navigationItem.rightBarButtonItem = cancelBarButton
    }

    /// customization of the view with the distinction between the normal and the dark mode
    private func customizeView() {
        var styleManager: CardinalStyleManager?
        if #available(iOS 12.0, *) {
            styleManager = traitCollection.userInterfaceStyle == .dark && viewModel.cardinalDarkModeStyleManager != nil ? viewModel.cardinalDarkModeStyleManager : viewModel.cardinalStyleManager
        } else {
            styleManager = viewModel.cardinalStyleManager
        }
        customizeToolbar(styleManager: styleManager)
    }

    /// Setting up the controller's toolbar
    /// - Parameter styleManager: instance of style manager
    private func customizeToolbar(styleManager: CardinalStyleManager?) {
        if let toolbarStyleManager = styleManager?.toolbarStyleManager {
            if let headerText = toolbarStyleManager.headerText {
                title = headerText
            }

            if let buttonText = toolbarStyleManager.buttonText {
                navigationItem.rightBarButtonItem?.title = buttonText
            }

            var attributes: [NSAttributedString.Key: Any]?
            var rightBarButtonAttributes: [NSAttributedString.Key: Any]?

            if let textColor = toolbarStyleManager.textColor {
                attributes = [.foregroundColor: textColor]
                rightBarButtonAttributes = [.foregroundColor: textColor]
            }

            if let backgroundColor = toolbarStyleManager.backgroundColor {
                navigationController?.navigationBar.barTintColor = backgroundColor
            }

            if let textFont = toolbarStyleManager.textFont {
                if let name = textFont.name, let font = UIFont(name: name, size: textFont.size) {
                    attributes != nil ? (attributes![.font] = font) : (attributes = [.font: font])
                    rightBarButtonAttributes != nil ? (rightBarButtonAttributes![.font] = font) : (rightBarButtonAttributes = [.font: font])
                } else {
                    let font = UIFont.systemFont(ofSize: textFont.size)
                    attributes != nil ? (attributes![.font] = font) : (attributes = [.font: font])
                    rightBarButtonAttributes != nil ? (rightBarButtonAttributes![.font] = font) : (rightBarButtonAttributes = [.font: font])
                }
            }

            if let attributes = attributes {
                navigationController?.navigationBar.titleTextAttributes = attributes
            }

            if let rightBarButtonAttributes = rightBarButtonAttributes {
                navigationItem.rightBarButtonItem?.setTitleTextAttributes(rightBarButtonAttributes, for: .normal)
            }
        }
    }

    // MARK: Actions

    /// Closures that are triggered after the completion of redirections
    /// - Parameters:
    ///   - sessionAuthenticationValidatePayload: the successful flow, payload return
    ///   - sessionAuthenticationFailure: flow failure
    public func setCompletion(sessionAuthenticationValidatePayload: @escaping ((String) -> Void), sessionAuthenticationFailure: @escaping (() -> Void)) {
        self.sessionAuthenticationValidatePayload = sessionAuthenticationValidatePayload
        self.sessionAuthenticationFailure = sessionAuthenticationFailure
    }

    /// Action triggered after tapping cancel bar button
    @objc private func cancelBarButtonTapped() {
        dismiss(animated: true) {
            self.sessionAuthenticationFailure?()
        }
    }
}

// MARK: WKUIDelegate

extension ThreeDSecureWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        if !webView.hasOnlySecureContent {
            dismiss(animated: true) {
                self.sessionAuthenticationFailure?()
            }
        }
    }
}

// MARK: WKNavigationDelegate

extension ThreeDSecureWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            if (400 ... 599).contains(response.statusCode) {
                // Sentry 17 - Catch network errors
                viewModel.webViewRedirectionStatusCodeError(status: response.statusCode)
            }
        }
        decisionHandler(.allow)
    }
    
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString, url.starts(with: viewModel.termUrl) {
            let payloadAndMd = url.replacingOccurrences(of: viewModel.termUrl, with: "")
            if !payloadAndMd.isEmpty {
                let components = URLComponents(url: navigationAction.request.url!, resolvingAgainstBaseURL: true)
                let md = components?.queryItems?.first(where: { $0.name == "MD" })?.value
                let pares = components?.queryItems?.first(where: { $0.name == "PaRes" })?.value

                if md == viewModel.mdValue, let pares = pares {
                    dismiss(animated: true) {
                        self.sessionAuthenticationValidatePayload?(pares)
                    }
                } else {
                    dismiss(animated: true) {
                        self.sessionAuthenticationFailure?()
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
}

public extension ThreeDSecureWebViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                customizeView()
            }
        }
    }
}
