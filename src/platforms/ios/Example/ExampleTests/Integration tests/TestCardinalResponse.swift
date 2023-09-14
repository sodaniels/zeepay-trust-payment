//
//  TestCardinalResponse.swift
//  ExampleTests
//  12/08/2020
//  https://cardinaldocs.atlassian.net/wiki/spaces/CCen/pages/903577725/EMV+3DS+2.0+Test+Cases

@testable import Trust_Payments
import XCTest

class TestCardinalResponse: KIFTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    override func setUpWithError() throws {
        try super.setUpWithError()
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
        paymentTransactionManager = try PaymentTransactionManager(jwt: "")
    }

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    // MARK: Test Case 1: Successful Frictionless Authentication

    func test_successfulFrictionlessAuthenticationAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001007", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNotNil(response?.cavv)
            XCTAssertNotNil(response?.xid)
            XCTAssertEqual("05", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("Y", response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_successfulFrictionlessAuthenticationMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001005", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNotNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("02", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("Y", response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 2: Failed Frictionless Authentication

    func test_failedFrictionlessAuthenticationMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001013", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
            // The gateway does not include Cardinal properties on failure, cannot check parameters
            let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
            let firstTPError = tpResponses?.compactMap(\.tpError).first
            XCTAssertNotNil(firstTPError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 3: Attempts Stand-In Frictionless Authentication

    func test_attemptsStandInFrictionlessAuthenticationAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001023", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNotNil(response?.cavv)
            XCTAssertNotNil(response?.xid)
            XCTAssertEqual("06", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("A", response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_attemptsStandInFrictionlessAuthenticationMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001021", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNotNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("01", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("A", response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 4: Unavailable Frictionless Authentication from the Issuer

    func test_unavailableFrictionlessAuthenticationFromTheIssuerMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001039", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("00", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("U", response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_unavailableFrictionlessAuthenticationFromTheIssuerAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001031", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNotNil(response?.xid)
            XCTAssertEqual("07", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("U", response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 5: Rejected Frictionless Authentication by the Issuer

    func test_rejectedFrictionlessAuthenticationByTheIssuerAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001049", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
            // The gateway does not include Cardinal properties on failure, cannot check parameters
            let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
            let firstTPError = tpResponses?.compactMap(\.tpError).first
            XCTAssertNotNil(firstTPError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 6: Authentication Not Available on Lookup

    func test_authenticationNotAvailableOnLookupAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001056", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("07", response?.eci)
            XCTAssertEqual("U", response?.enrolled)
            XCTAssertNil(response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_authenticationNotAvailableOnLookupMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001054", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("00", response?.eci)
            XCTAssertEqual("U", response?.enrolled)
            XCTAssertNil(response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 7: Error on Lookup

    func test_errorOnLookupAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001064", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
            // The gateway does not include Cardinal properties on failure, cannot check parameters
            let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
            let firstTPError = tpResponses?.compactMap(\.tpError).first
            XCTAssertNotNil(firstTPError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 8: Timeout on cmpi_lookup Transaction

    func test_timeoutOnCMPILookupTransactionVisa() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "4000000000001075", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
            // The gateway does not include Cardinal properties on failure, cannot check parameters
            let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
            let firstTPError = tpResponses?.compactMap(\.tpError).first
            XCTAssertEqual(firstTPError?.foundationError.code, ResponseErrorCode.bankSystemError.rawValue)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 60)
    }

    // MARK: Test Case 9: Bypassed Authentication

    func test_bypassedAuthenticationAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001080", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let responses = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response
            let response = responses?.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNotNil(response?.xid)
            XCTAssertEqual("07", response?.eci)
            XCTAssertEqual("B", response?.enrolled)
            XCTAssertNil(response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_bypassedAuthenticationMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001088", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let responses = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response
            let response = responses?.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("00", response?.eci)
            XCTAssertEqual("B", response?.enrolled)
            XCTAssertNil(response?.status)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Case 10: Successful Step Up Authentication
    
    func test_successfulStepUpAuthenticationMastercard() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001096", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNotNil(response?.cavv)
            XCTAssertNil(response?.xid)
            XCTAssertEqual("02", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("Y", response?.status)
            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }
    
    func test_successfulStepUpAuthenticationAmex() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001098", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNotNil(response?.cavv)
            XCTAssertNotNil(response?.xid)
            XCTAssertEqual("05", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("Y", response?.status)
            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }

    // MARK: Test Case 11: Failed Step Up Authentication

    func test_failedStepUpAuthentication() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001104", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { _, _, error in
            // Expected cardinal authentication error
            XCTAssertEqual(error?.foundationError.code, APIClientError.cardinalAuthenticationError.foundationError.code)
            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }

    // MARK: Test Case 12: Step Up Authentication is Unavailable
    
    func test_stepUpAuthenticationIsUnavailable() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000001114", cvv: "1234")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
            let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
            XCTAssertNil(response?.cavv)
            XCTAssertNotNil(response?.xid)
            XCTAssertEqual("07", response?.eci)
            XCTAssertEqual("Y", response?.enrolled)
            XCTAssertEqual("U", response?.status)
            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }

    // MARK: Test Case 13: Error on Authentication

    func test_errorOnAuthentication() throws {
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000001120", cvv: "123")
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { _, _, error in
            // Expected cardinal authentication error
            XCTAssertEqual(error?.foundationError.code, APIClientError.cardinalAuthenticationError.foundationError.code)
            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }
}

extension TestCardinalResponse {
    private func jwtWithCard(typeDescriptions: [TypeDescription], _ number: String, cvv: String) -> String {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: number,
                                              expirydate: "12/2022",
                                              cvv: cvv,
                                              parenttransactionreference: nil))

        return JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey)!
    }
}
