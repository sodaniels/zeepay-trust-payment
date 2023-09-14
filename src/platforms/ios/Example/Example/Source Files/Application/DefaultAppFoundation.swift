//
//  DefaultAppFoundation.swift
//  Example
//

import Foundation

final class DefaultAppFoundation: AppFoundation {
    /// - SeeAlso: AppFoundation.keys
    private(set) var keys = ApplicationKeys(keys: ExampleKeys())
}
