//
//  NSError.swift
//  TrustPaymentsCore
//

import Foundation

extension NSError: HumanReadableStringConvertible {
    /// - SeeAlso: HumanReadableStringConvertible.humanReadableDescription
    public var humanReadableDescription: String {
        "\(localizedDescription) (\(code))"
    }

    static var domain: String {
        "com.trustpayments.TrustPaymentsCore"
    }
}
