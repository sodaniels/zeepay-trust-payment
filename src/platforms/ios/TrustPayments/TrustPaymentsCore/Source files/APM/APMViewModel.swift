//
//  APMViewModel.swift
//  TrustPaymentsCore
//

import WebKit

final class APMViewModel {
    let returnUrl: String
    let redirectUrl: String
    let apm: APM
    let styling: TPAPMStyling?

    var webViewRequest: URLRequest? {
        guard let url = URL(string: redirectUrl) else { return nil }
        let request = URLRequest(url: url)
        return request
    }

    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        return configuration
    }

    init(apm: APM, returnUrl: String, redirectUrl: String, styling: TPAPMStyling? = nil) {
        self.apm = apm
        self.returnUrl = returnUrl
        self.redirectUrl = redirectUrl
        self.styling = styling
    }

    var title: String {
        switch apm {
        case .zip:
            return styling?.headerTitle ?? "Buy now pay later"
        case .ata:
            return styling?.headerTitle ?? "Pay By Bank"
        }
    }

    var headerColor: UIColor {
        switch apm {
        case .zip:
            return styling?.headerColor ?? UIColor(red: 1, green: 1, blue: 250.0 / 255.0, alpha: 1.0)
        case .ata:
            return styling?.headerColor ?? UIColor(red: 1, green: 1, blue: 250.0 / 255.0, alpha: 1.0)
        }
    }
}
