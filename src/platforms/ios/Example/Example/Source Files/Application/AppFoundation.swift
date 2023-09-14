//
//  AppFoundation.swift
//  Example
//

import Foundation

/// Protocol which will be used by almost all flow controllers in the application.
protocol AppFoundation {
    /// Common interface for securely providing keys
    var keys: ApplicationKeys { get }
}
