//
//  TestCardinalLiveStatus.swift
//  ExampleTests
//

import Foundation
@testable import Trust_Payments
import XCTest

class TestCardinalLiveStatus: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    private var jwtTokenWithFrictionlessCardData: String? {
        let typeDescriptions = [TypeDescription.threeDQuery].map(\.rawValue)
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

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    func testStagingEnvironment() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardData ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { _, _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func testProductionEnvironment() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        // for targets with integration tests the handling of cardinal errors has been disabled, so we can perform requests
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .production, translationsForOverride: nil)
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardData ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { _, _, error in
            var isExpectedError = false
            if let error = error, case APIClientError.cardinalSetupInternalError = error {
                isExpectedError = true
            }

            XCTAssertTrue(isExpectedError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 4)
    }
}
