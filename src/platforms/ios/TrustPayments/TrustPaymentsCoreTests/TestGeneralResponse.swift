//
//  TestGeneralResponse.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestGeneralResponse: XCTestCase {
    func test_responseDecoding() throws {
        let jwt = ["jwt": getJWT()]
        let data = try JSONSerialization.data(withJSONObject: jwt, options: JSONSerialization.WritingOptions(rawValue: 0))
        let response = try JSONDecoder().decode(GeneralResponse.self, from: data)
        XCTAssertNotNil(response)
    }
}
