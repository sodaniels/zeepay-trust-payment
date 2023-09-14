//
//  HumanReadableStringConvertible.swift
//  TrustPaymentsCore
//

/// Describes a type with a customized human-readable textual representation.
public protocol HumanReadableStringConvertible: CustomStringConvertible {
    /// A human-readable, preferrably localized, textual representation of `self`.
    var humanReadableDescription: String { get }
}

// MARK: -

public extension HumanReadableStringConvertible {
    /// - SeeAlso: CustomStringConvertible.description
    var description: String {
        humanReadableDescription
    }
}

/// An error that has a human-readable textual representation.
public typealias HumanReadableError = Error & HumanReadableStringConvertible
