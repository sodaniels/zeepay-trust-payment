//
//  CocoapodsIntegrationTests.swift
//  CocoapodsIntegrationTests
//

@testable import CocoapodsIntegration
import TrustPayments
import XCTest

class CocoapodsIntegrationTests: XCTestCase {

    private let keys = CocoapodsIntegrationKeys()

    func test_visa() throws {
        TrustPayments.instance.configure(username: keys.mERCHANT_USERNAME, gateway: .eu, environment: .staging, translationsForOverride: nil)
        let jwtToken = getJwtTokenWith(cardNumber: "4000 0000 0000 1026", cvv: "123")
        try performTestWith(jwt: jwtToken)
    }

    func test_productionEnvironment() throws {
        TrustPayments.instance.configure(username: .empty, gateway: .eu, environment: .production, translationsForOverride: nil)

        do {
            _ = try PaymentTransactionManager(jwt: .empty)
        } catch let error as TPInitError {
            XCTAssertEqual(error.code, 9100)
        } catch {
            XCTFail("it should not throw an error other than TPInitError")
        }
    }

    func test_jwtResponseVerification() throws {
        TrustPayments.instance.configure(username: keys.mERCHANT_USERNAME, gateway: .eu, environment: .staging, translationsForOverride: nil)
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        let jwt = getJwtTokenWith(typeDescriptions: [.auth], cardNumber: "4000 0000 0000 1026", cvv: "123", bypass3DS: false)
        let paymentTransactionManager = try PaymentTransactionManager(jwt: jwt)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] jwtForVerification, _, _ in
            XCTAssertNotNil(jwtForVerification.first)
            guard let response = jwtForVerification.first else {
                XCTFail("Expected valid response")
                return
            }
            let isVerified = JWTHelper.verifyJwt(jwt: response, secret: keys.jWTSecret)
            let isNotVerified = JWTHelper.verifyJwt(jwt: response, secret: "5-zzz33gg222h11hhbbbbbiii44ooo77fffffqqdd3aaaaabbbbbccccc77777ssss")
            let tpResponseClaims = try? JWTHelper.getTPResponseClaims(jwt: response, secret: keys.jWTSecret)
            XCTAssertTrue(isVerified)
            XCTAssertFalse(isNotVerified)
            let payload = tpResponseClaims?.payload
            let authResponse = payload?.response.first
            XCTAssertNotNil(payload?.requestreference)
            XCTAssertNotNil(payload?.version)
            XCTAssertTrue(payload?.response.count == 1) // auth
            XCTAssertTrue(authResponse?.requesttypedescription == "AUTH") // auth
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 4)
    }

    // MARK: - Helpers

    private func getJwtTokenWith(typeDescriptions: [TypeDescription] = [.threeDQuery, .auth], cardNumber: String, cvv: String?, bypass3DS: Bool = true) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let cardTypesToBypass = bypass3DS ? [CardType.visa, .amex, .mastercard, .discover, .jcb, .diners].map(\.stringValue) : []
        let claim = TPClaims(iss: keys.mERCHANT_USERNAME,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.mERCHANT_SITEREFERENCE,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: cardNumber,
                                              expirydate: "12/2022",
                                              cvv: cvv))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jWTSecret) else { return nil }
        return jwt
    }

    private func performTestWith(jwt: String?) throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        let paymentTransactionManager = try PaymentTransactionManager(jwt: jwt ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] responseJwt, _, _ in
            let tpResponses = try? TPHelper.getTPResponses(jwt: responseJwt)
            let responseObjects = tpResponses?.flatMap(\.responseObjects)

            let typeDescriptions = jwt?.requesttypedescriptions?.compactMap { TypeDescription(rawValue: $0) }
            let typeDescriptionsWithoutThreeDQuery = typeDescriptions?.filter { $0 != .threeDQuery }
            let responseTypeDescriptions = responseObjects?.compactMap(\.requestTypeDescription)

            XCTAssertNotNil(responseTypeDescriptions)
            XCTAssertEqual(responseTypeDescriptions, typeDescriptionsWithoutThreeDQuery)

            let authResponse = responseObjects?.first(where: { $0.requestTypeDescription == .auth })
            XCTAssertNil(authResponse?.status)
            XCTAssertNil(authResponse?.cardEnrolled)
            XCTAssertNil(authResponse?.threeDVersion)

            let tpResponseClaims = try? JWTHelper.getTPResponseClaims(jwt: responseJwt.last ?? .empty, secret: self.keys.jWTSecret)
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
}
