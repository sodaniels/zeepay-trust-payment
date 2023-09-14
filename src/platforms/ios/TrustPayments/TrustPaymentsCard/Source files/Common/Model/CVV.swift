//
//  CVV.swift
//  TrustPaymentsUI
//

import Foundation

/// Object representation of the cvv code string.
@objc public class CVV: NSObject, RawRepresentable {
    public typealias RawValue = String

    @objc public let rawValue: String

    @objc public var length: Int {
        rawValue.count
    }

    @objc public required init(rawValue: String) {
        self.rawValue = rawValue
    }

    @objc public var intValue: Int {
        Int(rawValue) ?? -1
    }
}

public extension CVV {
    override var description: String {
        rawValue
    }
}
