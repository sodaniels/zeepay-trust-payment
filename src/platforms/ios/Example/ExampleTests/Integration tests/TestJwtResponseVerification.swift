//
//  IntegrationTests.swift
//  ExampleTests
//

@testable import Trust_Payments
import XCTest

class TestJwtResponseVerification: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())
    private let fakeSecretKey = "5-zzz33gg222h11hhbbbbbiii44ooo77fffffqqdd3aaaaabbbbbccccc77777ssss"

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

    private func jwtTokenWithBankErrorCardData(typeDescriptions: [TypeDescription]) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4000000000001067",
                                              expirydate: "12/2022",
                                              cvv: "123"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

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

    func test_JWTResponseVerification() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.auth]) ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] jwtForVerification, _, _ in
            XCTAssertNotNil(jwtForVerification.first)
            self.performChecksForAuthWithJwt(jwtForVerification.first ?? .empty)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 4)
    }

    func test_JWTResponseVerificationForMultipleTypeDescriptions() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .auth, .riskDec]) ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] jwtForVerification, _, _ in
            XCTAssertNotNil(jwtForVerification.first)
            self.performChecksForMultipleTypeDescriptionsWithJwt(jwtForVerification.first ?? .empty)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 15)
    }

    // MARK: Helpers

    func performChecksForAuthWithJwt(_ jwtForVerification: String) {
        let isVerified = JWTHelper.verifyJwt(jwt: jwtForVerification, secret: keys.jwtSecretKey)
        let isNotVerified = JWTHelper.verifyJwt(jwt: jwtForVerification, secret: fakeSecretKey)
        let tpResponseClaims = try? JWTHelper.getTPResponseClaims(jwt: jwtForVerification, secret: keys.jwtSecretKey)
        XCTAssertTrue(isVerified)
        XCTAssertFalse(isNotVerified)
        let payload = tpResponseClaims?.payload
        let authResponse = payload?.response[safe: 0]
        XCTAssertNotNil(payload?.requestreference)
        XCTAssertNotNil(payload?.version)
        XCTAssertTrue(payload?.response.count == 1) // auth
        XCTAssertTrue(authResponse?.requesttypedescription == "AUTH") // auth
    }

    func performChecksForMultipleTypeDescriptionsWithJwt(_ jwtForVerification: String) {
        let isVerified = JWTHelper.verifyJwt(jwt: jwtForVerification, secret: keys.jwtSecretKey)
        let isNotVerified = JWTHelper.verifyJwt(jwt: jwtForVerification, secret: fakeSecretKey)
        let tpResponseClaims = try? JWTHelper.getTPResponseClaims(jwt: jwtForVerification, secret: keys.jwtSecretKey)
        XCTAssertTrue(isVerified)
        XCTAssertFalse(isNotVerified)

        let payload = tpResponseClaims?.payload
        let threeDQueryResponse = payload?.response[safe: 0]
        let authResponse = payload?.response[safe: 1]
        let riskDecResponse = payload?.response[safe: 2]
        XCTAssertNotNil(payload?.requestreference)
        XCTAssertNotNil(payload?.version)
        XCTAssertTrue(payload?.response.count == 3) // threeDQuery, auth and riskdec
        XCTAssertTrue(threeDQueryResponse?.requesttypedescription == "THREEDQUERY") // threeDQuery
        XCTAssertTrue(authResponse?.requesttypedescription == "AUTH") // auth
        XCTAssertTrue(riskDecResponse?.requesttypedescription == "RISKDEC") // riskdec
    }

    func testSecondTransactionAfterFailureFinishWithSuccess() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithBankErrorCardData(typeDescriptions: [.threeDQuery, .auth]) ?? .empty)

        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            var isExpectedError = false
            if let tpResponses = try? TPHelper.getTPResponses(jwt: jwt), let firstTPError = tpResponses.compactMap(\.tpError).first, case let TPError.gatewayError(errorCode, _) = firstTPError, case .bankSystemError = errorCode {
                isExpectedError = true
                // expected bank system error
                XCTAssertEqual(firstTPError.humanReadableDescription, "An error occurred: Bank System Error")
            }
            XCTAssertTrue(isExpectedError)

            self.paymentTransactionManager.performTransaction(jwt: self.jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .auth]), card: nil, transactionResponseClosure: { jwt, _, _ in
                let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
                let responses = tpResponses?.flatMap(\.responseObjects)
                let responseRequestTypes = responses?.compactMap(\.requestTypeDescription)
                XCTAssertEqual(responseRequestTypes, [.threeDQuery, .auth])
                let errorCodes = responses?.map(\.errorCode)
                XCTAssertEqual(errorCodes?.count, 2)
                XCTAssertEqual(errorCodes?.reduce(0, +), 0) // error code for success = 0
                expectation.fulfill()
            })
        })
        wait(for: [expectation], timeout: 10)
    }

    func testPerformRequestWithJWTSetOnInit() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .auth]) ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { _, _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func testPerformRequestWithJWTSetOnPerformTransaction() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: nil)
        paymentTransactionManager.performTransaction(jwt: jwtTokenWithFrictionlessCardData(typeDescriptions: [.threeDQuery, .auth]), card: nil, transactionResponseClosure: { _, _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func testDoesntPerformRequestWithoutJWT() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: nil)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { _, _, error in
            var isExpectedError = false
            if case .jwtMissing = error {
                isExpectedError = true
            }
            XCTAssertTrue(isExpectedError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }
}
