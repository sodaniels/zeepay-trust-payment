//
//  TestRequestTypes.swift
//  ExampleTests
//

import Foundation

@testable import Trust_Payments
import XCTest

class TestRequestTypes: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    private func jwtTokenWithFrictionlessCardData(typeDescriptions: [TypeDescription]) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
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

    private func jwtTokenWithSubscriptionData(typeDescriptions: [TypeDescription]) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 199,
                                              pan: "4000000000001026",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              subscriptiontype: "RECURRING",
                                              subscriptionfinalnumber: "12",
                                              subscriptionunit: "MONTH",
                                              subscriptionfrequency: "1",
                                              subscriptionnumber: "1",
                                              credentialsonfile: "1"))

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

    func test_accountCheck() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.accountCheck]))
    }

    func test_accountCheckAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.accountCheck, .auth]))
    }

    func test_accountCheckAndThreeDQuery() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.accountCheck, .threeDQuery]))
    }

    func test_accountCheckAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.accountCheck, .subscription]))
    }

    func test_accountCheckAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.accountCheck, .auth, .subscription]))
    }

    func test_accountCheckThreeDQueryAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.accountCheck, .threeDQuery, .auth]))
    }

    func test_accountCheckThreeDQueryAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.accountCheck, .threeDQuery, .auth, .subscription]))
    }

    func test_auth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.auth]))
    }

    func test_authAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.auth, .subscription]))
    }

    func test_authAndThreeDQuery() {
        performNegativeTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.auth, .threeDQuery]))
    }

    func test_authAndRiskdec() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.auth, .riskDec]))
    }

    func test_threeDQuery() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery]))
    }

    func test_threeDQueryAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .auth]))
    }

    func test_threeDQueryAndAccountCheck() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .accountCheck]))
    }

    func test_threeDQueryAccountCheckAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.threeDQuery, .accountCheck, .subscription]))
    }

    func test_threeDQueryAuthAndRiskDec() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .auth, .riskDec]))
    }

    func test_threeDQueryAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.threeDQuery, .auth, .subscription]))
    }

    func test_riskDecAndAccountCheck() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .accountCheck]))
    }

    func test_riskDecAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .auth]))
    }

    func test_riskDecAndThreeDQuery() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .threeDQuery]))
    }

    func test_riskDecAccountCheckAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .accountCheck, .auth]))
    }

    func test_riskDecAccountCheckAndThreeDQuery() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .accountCheck, .threeDQuery]))
    }

    func test_riskDecAccountCheckAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.riskDec, .accountCheck, .subscription]))
    }

    func test_riskDecAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.riskDec, .auth, .subscription]))
    }

    func test_riskDecThreeDQueryAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .threeDQuery, .auth]))
    }

    func test_riskDecThreeDQueryAndAccountCheck() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .threeDQuery, .accountCheck]))
    }

    func test_riskDecAccountCheckAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.riskDec, .accountCheck, .auth, .subscription]))
    }

    func test_riskDecAccountCheckThreeDQueryAndAuth() {
        performTestWith(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.riskDec, .accountCheck, .threeDQuery, .auth]))
    }

    func test_riskDecThreeDQueryAccountCheckAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.riskDec, .threeDQuery, .accountCheck, .subscription]))
    }

    func test_riskDecThreeDQueryAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.riskDec, .threeDQuery, .auth, .subscription]))
    }

    func test_riskDecAccountCheckThreeDQueryAuthAndSubscription() {
        performTestWith(jwt: jwtTokenWithSubscriptionData(typeDescriptions: [.riskDec, .accountCheck, .threeDQuery, .auth, .subscription]))
    }

    // MARK: Helpers

    private func performTestWith(jwt: String?) {
        let expectation = XCTestExpectation()
        paymentTransactionManager.performTransaction(jwt: jwt ?? .empty, card: nil, transactionResponseClosure: { responseJwt, _, _ in
            let tpResponses = try? TPHelper.getTPResponses(jwt: responseJwt)
            let responseObjects = tpResponses?.flatMap(\.responseObjects)

            let typeDescriptions = jwt?.requesttypedescriptions?.compactMap { TypeDescription(rawValue: $0) }
            let responseTypeDescriptions = responseObjects?.compactMap(\.requestTypeDescription)
            XCTAssertNotNil(responseTypeDescriptions)
            XCTAssertTrue(responseTypeDescriptions?.isNotEmpty ?? false)
            XCTAssertEqual(responseTypeDescriptions, typeDescriptions)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    private func performNegativeTestWith(jwt: String?) {
        let expectation = XCTestExpectation()
        paymentTransactionManager.performTransaction(jwt: jwt ?? .empty, card: nil, transactionResponseClosure: { jwt, _, _ in
            var isExpectedError = false
            if let tpResponses = try? TPHelper.getTPResponses(jwt: jwt), let firstTPError = tpResponses.compactMap(\.tpError).first, case let .invalidField(code, _) = firstTPError, code == .invalidTypeDescriptions {
                isExpectedError = true
                XCTAssertEqual(firstTPError.humanReadableDescription, "Invalid field: requesttypedescriptions")
            }
            XCTAssertTrue(isExpectedError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }
}
