//
//  TestCardinalV1Response.swift
//  ExampleTests
//  27/08/2020
//  https://cardinaldocs.atlassian.net/wiki/spaces/CCen/pages/400654355/3DS+1.0+Test+Cases

@testable import Trust_Payments
import WebKit
import XCTest

class TestCardinalV1Response: KIFTestCase {
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

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     
     // MARK: Test Case 1: Successful Authentication

     func test_successfulAuthenticationAmex() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000003961", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNotNil(response?.cavv)
             XCTAssertNotNil(response?.xid)
             XCTAssertEqual("05", response?.eci)
             XCTAssertEqual("Y", response?.enrolled)
             XCTAssertEqual("Y", response?.status)
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     func test_successfulAuthenticationMastercard() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000007", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNotNil(response?.cavv)
             XCTAssertNotNil(response?.xid)
             XCTAssertEqual("02", response?.eci)
             XCTAssertEqual("Y", response?.enrolled)
             XCTAssertEqual("Y", response?.status)
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 2: Failed Signature

     func test_failedSignature() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000015", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
             let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
             let firstTPError = tpResponses?.compactMap(\.tpError).first
             XCTAssertNotNil(firstTPError)
             XCTAssertEqual(firstTPError?.humanReadableDescription, "Invalid field: status")
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 3: Failed Authentication

     func test_failedAuthentication() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000000033", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
             let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
             let firstTPError = tpResponses?.compactMap(\.tpError).first
             XCTAssertNotNil(firstTPError)
             XCTAssertEqual(firstTPError?.humanReadableDescription, "An error occurred: Unauthenticated")
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 4: Attempts/Non-Participating

     func test_attemptsNonParticipatingMastercard() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000908", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNotNil(response?.cavv)
             XCTAssertNotNil(response?.xid)
             XCTAssertEqual("01", response?.eci)
             XCTAssertEqual("Y", response?.enrolled)
             XCTAssertEqual("A", response?.status)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     func test_attemptsNonParticipatingAmex() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000003391", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNotNil(response?.cavv)
             XCTAssertNotNil(response?.xid)
             XCTAssertEqual("06", response?.eci)
             XCTAssertEqual("Y", response?.enrolled)
             XCTAssertEqual("A", response?.status)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 5: Timeout

     func test_timeout() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000049", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertNil(response?.eci)
             XCTAssertNil(response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 60)
     }

     // MARK: Test Case 6: Not Enrolled

     func test_notEnrolledMastercard() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000056", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertEqual("00", response?.eci)
             XCTAssertEqual("N", response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     func test_notEnrolledAmex() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000008135", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertEqual("07", response?.eci)
             XCTAssertEqual("N", response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 7: Unavailable

     func test_unavailableMastercard() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000064", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertEqual("00", response?.eci)
             XCTAssertEqual("U", response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     func test_unavailableAmex() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000007780", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertEqual("07", response?.eci)
             XCTAssertEqual("U", response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 8: Merchant Not Active

     func test_merchantNotActive() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000008416", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
             let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
             let firstTPError = tpResponses?.compactMap(\.tpError).first
             XCTAssertNotNil(firstTPError)
             XCTAssertEqual(firstTPError?.humanReadableDescription, "An error occurred: Bank System Error")
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 9: cmpi_lookup error

     func test_cmpiLookupError() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000080", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
             let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
             let firstTPError = tpResponses?.compactMap(\.tpError).first
             XCTAssertNotNil(firstTPError)
             XCTAssertEqual(firstTPError?.humanReadableDescription, "An error occurred: Bank System Error")
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 10: cmpi_authenticate error

     func test_cmpiAuthenticateError() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000009299", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
             let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
             let firstTPError = tpResponses?.compactMap(\.tpError).first
             XCTAssertNotNil(firstTPError)
             XCTAssertEqual(firstTPError?.humanReadableDescription, "Invalid field: status")
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 11: Authentication Unavailable

     func test_authenticationUnavailableMastercard() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200000000000031", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNotNil(response?.xid)
             XCTAssertEqual("00", response?.eci)
             XCTAssertEqual("U", response?.status)
             XCTAssertEqual("Y", response?.enrolled)
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     func test_authenticationUnavailableAmex() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340000000000116", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNotNil(response?.xid)
             XCTAssertEqual("07", response?.eci)
             XCTAssertEqual("U", response?.status)
             XCTAssertEqual("Y", response?.enrolled)
             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 10)
         wait(for: [expectation], timeout: 30)
     }

     // MARK: Test Case 12: Bypassed Authentication

     func test_bypassedAuthenticationAmex() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "340099000000001", cvv: "1234")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertEqual("07", response?.eci)
             XCTAssertEqual("B", response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }

     func test_bypassedAuthenticationMastercard() {
         let expectation = XCTestExpectation()
         let jwt = jwtWithCard(typeDescriptions: [.threeDQuery, .auth], "5200990000000009", cvv: "123")
         paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwt, _, _ in
             let response = try? JWTHelper.getTPResponseClaims(jwt: jwt.last ?? .empty, secret: self.keys.jwtSecretKey)?.payload.response.first(where: { $0.requesttypedescription == TypeDescription.auth.rawValue })
             XCTAssertNil(response?.cavv)
             XCTAssertNil(response?.xid)
             XCTAssertEqual("00", response?.eci)
             XCTAssertEqual("B", response?.enrolled)
             expectation.fulfill()
         })
         wait(for: [expectation], timeout: 30)
     }
      */
}

extension TestCardinalV1Response {
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
