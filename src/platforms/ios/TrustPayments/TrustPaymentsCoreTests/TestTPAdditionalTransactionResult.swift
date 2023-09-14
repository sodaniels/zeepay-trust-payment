//
//  TestTPAdditionalTransactionResult.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestTPAdditionalTransactionResult: XCTestCase {
    func test_pares() {
        let value = "pares"
        let result = TPAdditionalTransactionResult(pares: value)
        XCTAssertEqual(result.pares, value)
        XCTAssertNil(result.threeDResponse)
    }

    func test_threeDResponse() {
        let value = "threeDResponse"
        let result = TPAdditionalTransactionResult(threeDResponse: value)
        XCTAssertEqual(result.threeDResponse, value)
        XCTAssertNil(result.pares)
    }

    func test_statusAndReference() {
        let status = "status"
        let referencee = "reference"
        let result = TPAdditionalTransactionResult(settleStatus: status, transactionReference: referencee)
        XCTAssertEqual(result.settleStatus, status)
        XCTAssertEqual(result.transactionReference, referencee)
        XCTAssertNil(result.pares)
        XCTAssertNil(result.threeDResponse)
    }
}
