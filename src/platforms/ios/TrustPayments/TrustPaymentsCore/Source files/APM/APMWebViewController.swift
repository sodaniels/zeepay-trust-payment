//
//  APMWebViewController.swift
//  TrustPaymentsCore
//

import UIKit
import WebKit

class APMWebViewController: UIViewController {
    private var webView: WKWebView!
    private let viewModel: APMViewModel

    private var sessionAuthenticationValidateParameters: ((_ settleStatus: String, _ transactionReference: String) -> Void)?
    private var sessionAuthenticationFailure: (() -> Void)?

    // MARK: Initialization

    /// Initializes view controller with given view model.
    ///
    init(viewModel: APMViewModel) {
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

    override func loadView() {

        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeView()
        guard let request = viewModel.webViewRequest else {
            sessionAuthenticationFailure?()
            return
        }
        webView.load(request)
    }

    // MARK: View customization

    /// customization of the view with the distinction between the normal and the dark mode
    private func customizeView() {
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonTapped))
        navigationItem.rightBarButtonItem = cancelBarButton
        edgesForExtendedLayout = []
        navigationController?.navigationBar.barTintColor = viewModel.headerColor
        navigationController?.view.backgroundColor = viewModel.headerColor
        navigationController?.navigationBar.isTranslucent = true
        title = viewModel.title
    }

    // MARK: Actions

    /// Closures that are triggered after the completion of redirections
    /// - Parameters:
    ///   - sessionAuthenticationValidatePayload: the successful flow, payload return
    ///   - sessionAuthenticationFailure: flow failure
    func setCompletion(sessionAuthenticationValidateParameters: @escaping ((String, String) -> Void), sessionAuthenticationFailure: @escaping (() -> Void)) {
        self.sessionAuthenticationValidateParameters = sessionAuthenticationValidateParameters
        self.sessionAuthenticationFailure = sessionAuthenticationFailure
    }

    /// Action triggered after tapping cancel bar button
    @objc private func cancelBarButtonTapped() {
        dismiss(animated: true) {
            self.sessionAuthenticationFailure?()
        }
    }
}

// MARK: - WKUIDelegate

extension APMWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        if !webView.hasOnlySecureContent {
            dismiss(animated: true) {
                self.sessionAuthenticationFailure?()
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension APMWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            if (400 ... 599).contains(response.statusCode) {
                // Sentry 17 - Catch network errors
                TrustPayments.instance.monitoringManager.log(severity: .error, message: "Network error: \(response.statusCode)")
            }
        }
        decisionHandler(.allow)
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.starts(with: viewModel.returnUrl) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let settleStatus = components?.queryItems?.first(where: { $0.name == "settlestatus" })?.value,
               let transactionReference = components?.queryItems?.first(where: { $0.name == "transactionreference" })?.value {
                dismiss(animated: true) {
                    self.sessionAuthenticationValidateParameters?(settleStatus, transactionReference)
                }
            } else {
                dismiss(animated: true) {
                    self.sessionAuthenticationFailure?()
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if TrustPayments.instance.gateway == .devbox {
            guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }
            let exceptions = SecTrustCopyExceptions(serverTrust)
            SecTrustSetExceptions(serverTrust, exceptions)
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension APMWebViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                customizeView()
            }
        }
    }
}
