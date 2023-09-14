//
//  Array.swift
//  TrustPaymentsCard
//

import Foundation

extension Array {
    func getIfExists(at index: Int) -> Element? {
        guard (0 ..< count).contains(index) else { return nil }
        return self[index]
    }
}
