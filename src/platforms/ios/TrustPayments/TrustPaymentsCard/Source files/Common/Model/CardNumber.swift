//
//  CardNumber.swift
//  TrustPaymentsUI
//

import Foundation

/// Object representation of the card number string.
@objc public class CardNumber: NSObject, RawRepresentable {
    public typealias RawValue = String

    @objc public let rawValue: String

    @objc public var length: Int {
        rawValue.count
    }

    @objc public required init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension CardNumber {
    override var description: String {
        rawValue
    }
}
