//
//  TP3DSecureManagerMock.swift
//  TrustPayments3DSecure
//

import CardinalMobile
import Foundation

class TP3DSecureManagerMock: TP3DSecureManager {
    override func setup(with _: String, completion: @escaping ((String) -> Void), failure _: @escaping ((CardinalResponse) -> Void)) {
        completion("consumerSessionID")
    }
}
