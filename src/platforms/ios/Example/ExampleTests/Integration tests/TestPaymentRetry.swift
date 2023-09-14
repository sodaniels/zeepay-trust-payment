//
//  TestPaymentRetry.swift
//  ExampleTests
//

import Foundation
@testable import Trust_Payments
import XCTest

class TestPaymentRetry: KIFTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    // MARK: Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
    }

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    // MARK: Tests
    
    func test_paymentRetry() throws {
        let jwtToCheck = jwtWith3dqAndErrorBaseAmountValue()
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")

        // JWT passed on initialization - no update in the performTransaction method, to check if it is restored to its original value in case of transaction termination - in case you need to repeat payment
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToCheck)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] responseJwt, _, _ in

            let tpResponses = try? TPHelper.getTPResponses(jwt: responseJwt)
            let responseWithAuth = tpResponses?.first(where: { $0.responseObjects.contains(where: { $0.requestTypeDescription(contains: TypeDescription.auth) }) })
            let authError = responseWithAuth?.tpError
            XCTAssertNotNil(authError)

            // JWT should has the original value (not overwritten by the backend)
            XCTAssertEqual(self.paymentTransactionManager.jwt, jwtToCheck)

            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 20)
        wait(for: [expectation], timeout: 60)
    }

    private func jwtWith3dqAndErrorBaseAmountValue() -> String {
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: [TypeDescription.threeDQuery.rawValue, TypeDescription.auth.rawValue],
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 14_492,
                                              pan: "4000000000002008",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              parenttransactionreference: nil))

        return JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey)!
    }
}
