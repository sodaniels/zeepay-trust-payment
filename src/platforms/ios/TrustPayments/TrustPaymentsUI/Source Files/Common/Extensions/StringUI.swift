//
//  String.swift
//  TrustPaymentsUI
//

import Foundation

extension String {
    /// A substring beginning with a character in an index `from` and ending before a character in an index `to`.
    subscript(from: Int, to: Int) -> String? {
        guard count < to || from >= to else { return nil }
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to)
        return String(self[startIndex ..< endIndex])
    }

    var isNumeric: Bool {
        guard !isEmpty else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
