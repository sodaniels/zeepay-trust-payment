//
//  StringCard.swift
//  TrustPaymentsCard
//

import Foundation

public extension String {
    static let empty = ""
    static let space = " "
}

public extension String {
    /// Removes non digit characters
    var onlyDigits: String {
        components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
