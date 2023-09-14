//
//  Expiry.swift
//  TrustPaymentsUI
//

import Foundation

/// Object representation of the expiry date string.
@objc public class ExpiryDate: NSObject, RawRepresentable {
    public typealias RawValue = String

    @objc public let rawValue: String

    @objc public var length: Int {
        rawValue.count
    }

    @objc public required init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension ExpiryDate {
    override var description: String {
        rawValue
    }
}
