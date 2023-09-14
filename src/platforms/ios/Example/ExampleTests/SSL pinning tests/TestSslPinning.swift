//
//  TestSslPinning.swift
//  ExampleTests
//

import Foundation
@testable import Trust_Payments
import XCTest

class TestSslPinning: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    private var jwtTokenWithFrictionlessCardData: String? {
        let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4000000000001026",
                                              expirydate: "12/2022",
                                              cvv: "123"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    // MARK: Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
        paymentTransactionManager = try PaymentTransactionManager(jwt: .empty)
    }

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_sslPinning() {
        let expectation = XCTestExpectation()
        wait(interval: 12) { [weak self] in
            self?.paymentTransactionManager.performTransaction(jwt: self?.jwtTokenWithFrictionlessCardData ?? .empty, card: nil, transactionResponseClosure: { jwt, _, error in
                XCTAssertTrue(jwt.isEmpty)
                XCTAssertEqual(error?.foundationError.code, URLError.cancelled.rawValue)
                XCTAssertEqual(error?.humanReadableDescription, "An error occurred: cancelled")
                expectation.fulfill()
            })
        }
        wait(for: [expectation], timeout: 20)
    }
}
