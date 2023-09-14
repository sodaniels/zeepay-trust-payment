//
//  StringCore.swift
//  TrustPaymentsCore
//

import Foundation

extension String {
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
    
    var isValidURL: Bool {
        guard
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
            let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) else {
            return false
        }
        return match.range.length == utf16.count
    }
}
