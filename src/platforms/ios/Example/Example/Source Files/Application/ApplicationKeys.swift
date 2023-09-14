//
//  ApplicationKeys.swift
//  Example
//

import Foundation

/// Common interface for securely providing keys
final class ApplicationKeys {
    /// The cocoapods-keys instance
    private let keys: ExampleKeys

    /// Initializes class with given keys
    /// - Parameter keys: All Example app keys initialized with cocoapods-keys
    init(keys: ExampleKeys) {
        self.keys = keys
    }

    /// JWT secret key
    var jwtSecretKey: String {
        keys.jWTSecret
    }

    /// merchant username
    var merchantUsername: String {
        keys.mERCHANT_USERNAME
    }

    /// merchant site reference
    var merchantSiteReference: String {
        keys.mERCHANT_SITEREFERENCE
    }

    // MARK: Web services keys

    var wsUsername: String {
        keys.wS_USERNAME
    }

    var wsSiteReference: String {
        keys.wS_SITEREFERENCE
    }

    var wsPassword: String {
        keys.wS_PASSWORD
    }

    /// JWT secret key
    var passcode: String {
        keys.pASSCODE
    }
}
