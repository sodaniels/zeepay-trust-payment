//
//  TestBypassCard.swift
//  ExampleTests
//

import Foundation
@testable import Trust_Payments
import XCTest

class TestCardBypassing: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    // MARK: Setup

    override func setUp() {
        super.setUp()
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
    }

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_visa() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "4000 0000 0000 1026", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_mastercard() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "5200 0000 000 01005", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_secondMastercard() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "2221 0000 0000 0801", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_maestro() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "5000 0000 0000 0611", cvv: "123")
        try performTestForCardThatNeeds3dsWith(jwt: jwtToken)
    }

    func test_discover() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "6011 0000 0000 0004", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_amex() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "3400 00000001 007", cvv: "1234")
        try performTestWith(jwt: jwtToken)
    }

    func test_jcb() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "3528 0000 0000 0411", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_diners() throws {
        let jwtToken = getJwtTokenWith(cardNumber: "3005 0000 0000 6246", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_visaWithThreeDQueryOnly() throws {
        let jwtToken = getJwtTokenWith(typeDescriptions: [.threeDQuery], cardNumber: "4000 0000 0000 1026", cvv: "123")
        try performTestWithThreeDQuery(jwt: jwtToken)
    }

    func test_visaWithMultipleTypeDescriptions() throws {
        let jwtToken = getJwtTokenWithSubscriptionDataAnd(cardNumber: "4000 0000 0000 1026", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    // MARK: Helpers

    private func getJwtTokenWith(typeDescriptions: [TypeDescription] = [.threeDQuery, .auth], cardNumber: String, cvv: String?) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let cardTypesToBypass = [CardType.visa, .amex, .mastercard, .discover, .jcb, .diners].map(\.stringValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: cardNumber,
                                              expirydate: "12/2022",
                                              cvv: cvv))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    private func getJwtTokenWithSubscriptionDataAnd(cardNumber: String, cvv: String?) -> String? {
        let typeDescriptions = [TypeDescription.accountCheck, .threeDQuery, .auth, .subscription].map(\.rawValue)
        let cardTypesToBypass = [CardType.visa, .amex, .mastercard, .discover, .jcb, .diners].map(\.stringValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 199,
                                              pan: cardNumber,
                                              expirydate: "12/2022",
                                              cvv: cvv,
                                              subscriptiontype: "RECURRING",
                                              subscriptionfinalnumber: "12",
                                              subscriptionunit: "MONTH",
                                              subscriptionfrequency: "1",
                                              subscriptionnumber: "1",
                                              credentialsonfile: "1"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    private func performTestWith(jwt: String?) throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwt ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] responseJwt, _, _ in
            let tpResponses = try? TPHelper.getTPResponses(jwt: responseJwt)
            let responseObjects = tpResponses?.flatMap(\.responseObjects)

            let typeDescriptions = jwt?.requesttypedescriptions?.compactMap { TypeDescription(rawValue: $0) }
            let typeDescriptionsWithoutThreeDQuery = typeDescriptions?.filter { $0 != .threeDQuery }
            let responseTypeDescriptions = responseObjects?.compactMap(\.requestTypeDescription)

            XCTAssertNotNil(responseTypeDescriptions)
            XCTAssertTrue(responseTypeDescriptions?.isNotEmpty ?? false)
            XCTAssertEqual(responseTypeDescriptions, typeDescriptionsWithoutThreeDQuery)

            let authResponse = responseObjects?.first(where: { $0.requestTypeDescription == .auth })
            XCTAssertNil(authResponse?.status)
            XCTAssertNil(authResponse?.cardEnrolled)
            XCTAssertNil(authResponse?.threeDVersion)

            let tpResponseClaims = try? JWTHelper.getTPResponseClaims(jwt: responseJwt.last ?? .empty, secret: self.keys.jwtSecretKey)
            let jwtResponses = tpResponseClaims?.payload.response
            let jwtAuthResponse = jwtResponses?.first(where: { $0.requesttypedescription == "AUTH" })
            XCTAssertNil(jwtAuthResponse?.cavv)
            XCTAssertNil(jwtAuthResponse?.eci)
            XCTAssertNil(jwtAuthResponse?.status)
            XCTAssertNil(jwtAuthResponse?.enrolled)
            XCTAssertNil(jwtAuthResponse?.threedversion)

            let jwtResponsesTypeDescriptions = jwtResponses?.compactMap { TypeDescription(rawValue: $0.requesttypedescription) }
            XCTAssertEqual(jwtResponsesTypeDescriptions, typeDescriptionsWithoutThreeDQuery)

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    private func performTestForCardThatNeeds3dsWith(jwt: String?) throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwt ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, _, _ in
            let tpResponses = try? TPHelper.getTPResponses(jwt: responseJwt)
            let responseObjects = tpResponses?.flatMap(\.responseObjects)

            let typeDescriptions = jwt?.requesttypedescriptions?.compactMap { TypeDescription(rawValue: $0) }
            let responseTypeDescriptions = responseObjects?.compactMap(\.requestTypeDescription)
            XCTAssertNotNil(responseTypeDescriptions)
            XCTAssertTrue(responseTypeDescriptions?.isNotEmpty ?? false)
            XCTAssertEqual(responseTypeDescriptions, typeDescriptions)

            let authResponse = responseObjects?.first(where: { $0.requestTypeDescription == .auth })
            XCTAssertNil(authResponse?.status)
            XCTAssertEqual(authResponse?.cardEnrolled, "U")
            XCTAssertNotNil(authResponse?.threeDVersion)

            let jwtResponse = try? JWTHelper.getTPResponseClaims(jwt: responseJwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(jwtResponse?.cavv)
            XCTAssertNotNil(jwtResponse?.eci)
            XCTAssertNil(jwtResponse?.status)
            XCTAssertEqual(jwtResponse?.enrolled, "U")
            XCTAssertNotNil(jwtResponse?.threedversion)

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    private func performTestWithThreeDQuery(jwt: String?) throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwt ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { jwt, _, _ in
            var isExpectedError = false
            if let tpResponses = try? TPHelper.getTPResponses(jwt: jwt), let firstTPError = tpResponses.compactMap(\.tpError).first, case let .gatewayError(code, _) = firstTPError, code == .bypass {
                isExpectedError = true
            }
            XCTAssertTrue(isExpectedError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }
}
