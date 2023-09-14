//
//  TestGatewayLocale.swift
//  ExampleTests
//

@testable import Trust_Payments
import XCTest

class TestGatewayLocale: XCTestCase {
    private let keys = ApplicationKeys(keys: ExampleKeys())

    // MARK: locale: es_ES

    // decline payment response from gateway (in Spanish)
    func test_jwtWithSpanishLocale() throws {
        // An error occured: Declined
        try validateErrorMessage(for: "es_ES", cardNumber: "4242424242424242", expectedMessage: "Se ha producido un error: Rechazar")
    }

    // MARK: locale: de_DE

    // bank system error payment response from gateway (in German)
    func test_jwtWithGermanLocale() throws {
        // An error occurred: Bank System Error
        try validateErrorMessage(for: "de_DE", cardNumber: "4000000000001067", expectedMessage: "Ein Fehler ist aufgetreten: Banksystemfehler")
    }

    // MARK: locale: fr_FR

    // unauthenticated 3DS payment response from gateway (in French)
    func test_jwtWithFrenchLocale() throws {
        // An error occurred: Unauthenticated
        try validateErrorMessage(for: "fr_FR", cardNumber: "4000000000001018", expectedMessage: "Une erreur est survenue: Non authentifié")
    }

    // MARK: locale: sv_SE

    // Invalid field payment response from gateway (in Swedish)
    func test_jwtWithSwedishLocale() throws {
        // Invalid field: pan
        try validateErrorMessage(for: "sv_SE", cardNumber: "1111111111111111", expectedMessage: "Ogiltigt fält: pan")
    }

    // MARK: locale: cy_GB Welsh

    // TODO: re-enable this test in scope of MSDK-1285 and remove switflint rule disable
    // This test was disabled because of wrong translation returned from backend, which caused test failure.
    // Bank system error (response in Welsh)
//    func test_jwtWithWelshLocale() throws {
//        // An error occurred: Bank System Error
//        try validateErrorMessage(for: "cy_GB", cardNumber: "4000000000001067", expectedMessage: "Digwyddodd gwall: Gwall yn System y Banc")
//    }

    // Bank system error (response in Italian)
    func test_jwtWithItalianLocale() throws {
        // An error occurred: Bank System Error
        try validateErrorMessage(for: "it_IT", cardNumber: "4000000000001067", expectedMessage: "Si è verificato un errore: Errore di sistema bancario")
    }
}

extension TestGatewayLocale {
    private func jwtWithCard(_ locale: String, _ number: String) -> String {
        let typeDescriptions = [TypeDescription.threeDQuery, .auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              locale: locale,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 199,
                                              pan: number,
                                              expirydate: "12/2022",
                                              cvv: "123"))

        return JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey)!
    }

    private func validateErrorMessage(for locale: String, cardNumber: String, expectedMessage: String) throws {
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, locale: Locale(identifier: locale), translationsForOverride: nil)
        let paymentTransactionManager = try PaymentTransactionManager(jwt: "")
        let expectation = XCTestExpectation()
        let jwt = jwtWithCard(locale, cardNumber)
        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { jwt, _, _ in
            let tpResponses = try? TPHelper.getTPResponses(jwt: jwt)
            let firstTPError = tpResponses?.compactMap(\.tpError).first
            // compare the response message with expected
            XCTAssertEqual(firstTPError?.humanReadableDescription, expectedMessage)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 30)
    }
}
