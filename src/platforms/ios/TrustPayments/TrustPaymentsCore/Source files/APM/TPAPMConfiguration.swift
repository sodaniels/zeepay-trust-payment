//
//  TPAPMConfiguration.swift
//  TrustPaymentsCore
//

import Foundation

@objc public class TPAPMConfiguration: NSObject {
    public let supportedAPMs: [APM]
    public let minAmount: Double?
    public let maxAmount: Double?
    /// Style properties used to customize a web view on which apm's redirection takes place
    public let styling: TPAPMStyling?

    public init(supportedAPMs: [APM], zipMinAmount: Double? = nil, zipMaxAmount: Double? = nil, styling: TPAPMStyling? = nil) {
        self.supportedAPMs = supportedAPMs
        minAmount = zipMinAmount
        maxAmount = zipMaxAmount
        self.styling = styling
    }
}
