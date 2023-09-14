//
//  TPAdditionalTransactionResult.swift
//  TrustPaymentsCore
//

import Foundation

/// Object passed in the transaction's completion closure. Use it to get 3DS challenge results or APM's transaction status
@objc public final class TPAdditionalTransactionResult: NSObject {
    /// property to store the threedsecure authentication value (3ds version 1)
    @objc public let pares: String?
    /// property to store the threedsecure authentication value
    @objc public let threeDResponse: String?
    /// Settle status of apm transaction
    @objc public let settleStatus: String?
    /// Reference of apm transaction
    @objc public let transactionReference: String?

    @objc public init(pares: String) {
        self.pares = pares
        threeDResponse = nil
        settleStatus = nil
        transactionReference = nil
    }

    @objc public init(threeDResponse: String) {
        pares = nil
        self.threeDResponse = threeDResponse
        settleStatus = nil
        transactionReference = nil
    }

    @objc public init(settleStatus: String, transactionReference: String) {
        self.settleStatus = settleStatus
        self.transactionReference = transactionReference
        pares = nil
        threeDResponse = nil
    }
}
