//
//  TestVisaCardBypass.swift
//  ExampleTests
//

@testable import Trust_Payments
import XCTest

class TestVisaCardBypass: XCTestCase {
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

    func test_threeDQuery_auth() throws {
        try performTestWith(typeDescriptions: [.threeDQuery, .auth])
    }

    func test_accountCheck_threeDQuery_auth() throws {
        try performTestWith(typeDescriptions: [.accountCheck, .threeDQuery, .auth])
    }

    func test_accountCheck_threeDQuery_auth_subscription() throws {
        try performTestWith(typeDescriptions: [.accountCheck, .threeDQuery, .auth, .subscription])
    }

    func test_riskDec_accountCheck_threeDQuery_auth() throws {
        try performTestWith(typeDescriptions: [.riskDec, .accountCheck, .threeDQuery, .auth])
    }

    func test_threeDQuery_auth_riskDec() throws {
        try performTestWith(typeDescriptions: [.threeDQuery, .auth, .riskDec])
    }

    func test_threeDQuery() throws {
        try performTestWith(typeDescriptions: [.threeDQuery])
    }

    // MARK: Helpers

    private func jwtToken(typeDescriptions: [TypeDescription]) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let cardTypesToBypass = [CardType.visa].map(\.stringValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4000000000001026",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              subscriptiontype: "RECURRING",
                                              subscriptionfinalnumber: "12",
                                              subscriptionunit: "MONTH",
                                              subscriptionfrequency: "1",
                                              subscriptionnumber: "1",
                                              credentialsonfile: "1"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else {
            XCTFail("Error while creating JWT")
            return nil
        }
        return jwt
    }

    private func performTestWith(typeDescriptions: [TypeDescription]) throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        let jwt = jwtToken(typeDescriptions: typeDescriptions)
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwt)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, _, _ in

            let tpResponses = try? TPHelper.getTPResponses(jwt: responseJwt)

            guard typeDescriptions != [.threeDQuery] else {
                var isExpectedError = false
                if let firstTPError = tpResponses?.compactMap(\.tpError).first, case let .gatewayError(code, _) = firstTPError, code == .bypass {
                    isExpectedError = true
                }
                XCTAssertTrue(isExpectedError)
                expectation.fulfill()
                return
            }

            let responseObjects = tpResponses?.flatMap(\.responseObjects)

            let typeDescriptionsWithoutThreeDQuery = typeDescriptions.filter { $0 != .threeDQuery }
            let responseTypeDescriptions = responseObjects?.compactMap(\.requestTypeDescription)
            XCTAssertEqual(responseTypeDescriptions, typeDescriptionsWithoutThreeDQuery)

            let authResponse = responseObjects?.first(where: { $0.requestTypeDescription == .auth })
            XCTAssertNil(authResponse?.status)
            XCTAssertNil(authResponse?.cardEnrolled)
            XCTAssertNil(authResponse?.threeDVersion)

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
}
