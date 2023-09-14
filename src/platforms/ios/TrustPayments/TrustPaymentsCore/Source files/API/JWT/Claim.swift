//
//  Claim.swift
//  TrustPaymentsCore
//

import Foundation

struct Claim {
    // MARK: Properties

    /// raw value of the claim
    let value: Any?

    /// original claim value
    var rawValue: Any? {
        value
    }

    /// value of the claim as `String`
    var string: String? {
        value as? String
    }

    /// value of the claim as `Int`
    var integer: Int? {
        guard let integer = value as? Int else {
            if let string = string {
                return Int(string)
            } else if let double = value as? Double {
                return Int(double)
            }
            return nil
        }
        return integer
    }

    /// value of the claim as `Double`
    var double: Double? {
        guard let double = value as? Double else {
            if let string = string {
                return Double(string)
            }
            return nil
        }
        return double
    }

    /// value of the claim as `NSDate`
    var date: Date? {
        guard let timestamp: TimeInterval = double else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// value of the claim as `[String]`
    var array: [String]? {
        if let array = value as? [String] {
            return array
        }
        if let value = string {
            return [value]
        }
        return nil
    }

    /// value of the claim as `[String]`
    var arrayOfObjects: [[String: Any]]? {
        if let array = value as? [[String: Any]] {
            return array
        }
        return nil
    }
}
