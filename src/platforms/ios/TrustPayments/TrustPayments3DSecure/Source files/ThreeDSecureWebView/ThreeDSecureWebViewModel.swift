//
//  ThreeDSecureWebViewModel.swift
//  TrustPayments3DSecure
//

import WebKit

public final class ThreeDSecureWebViewModel {
    let payload: String
    let termUrl: String
    let acsUrl: String
    let mdValue: String
    let cardinalStyleManager: CardinalStyleManager?
    let cardinalDarkModeStyleManager: CardinalStyleManager?
    public var webViewStatusCodeError: ((_ statusCode: Int) -> Void)?

    var webViewRequest: URLRequest {
        let url = URL(string: acsUrl)!
        let bodyParameters = [
            "PaReq": payload,
            "TermUrl": termUrl,
            "MD": mdValue
        ]
        let bodyString = bodyParameters.queryParameters
        var request = URLRequest(url: url)
        request.httpBody = bodyString.data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded"]
        return request
    }

    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        return configuration
    }

    public init(payload: String, termUrl: String, acsUrl: String, mdValue: String, cardinalStyleManager: CardinalStyleManager?, cardinalDarkModeStyleManager: CardinalStyleManager?) {
        self.payload = payload
        self.termUrl = termUrl
        self.acsUrl = acsUrl
        self.mdValue = mdValue
        self.cardinalStyleManager = cardinalStyleManager
        self.cardinalDarkModeStyleManager = cardinalDarkModeStyleManager
    }

    func webViewRedirectionStatusCodeError(status: Int) {
        webViewStatusCodeError?(status)
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String { get }
}

extension Dictionary: URLQueryParameterStringConvertible {
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: [])!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: [])!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}
