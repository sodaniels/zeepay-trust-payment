//
//  Dequeueable.swift
//  TrustPaymentsUI
//

import Foundation

protocol Dequeueable {
    static var defaultReuseIdentifier: String { get }
}

extension Dequeueable {
    static var defaultReuseIdentifier: String {
        String(describing: self)
    }
}
