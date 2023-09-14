//
//  PKPaymentMethodType.swift
//  Example
//

import PassKit

extension PKPaymentMethodType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .credit: return "credit"
        case .debit: return "debit"
        case .prepaid: return "prepaid"
        case .store: return "store"
        default: return "default"
        }
    }
}
