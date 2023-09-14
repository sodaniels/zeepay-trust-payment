//
//  TestPaymentTransactionManager.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPayments3DSecure
@testable import TrustPaymentsCard
@testable import TrustPaymentsCore
import XCTest

class TestPaymentTransactionManager: XCTestCase {
    var isLiveStatus: Bool = false
    override func setUp() {
        TrustPayments.instance.configure(username: "", gateway: .eu, environment: .staging, translationsForOverride: nil)
    }
    
    func test_invalidConfig() throws {
        let expectation = XCTestExpectation()
        
        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        
        TrustPayments.instance.username = nil
        XCTAssertThrowsError(try PaymentTransactionManager(apiManager: apiManager, threeDSecureManager: nil, jwt: nil, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil)) { error in
            XCTAssertEqual(error.localizedDescription, "[TP] Could not initialise PaymentTransactionManager due to uninitialised property: Username. Use TrustPayments.instance.configure() method to complete initialisation.")
            expectation.fulfill()
        }
        TrustPayments.instance.username = ""
        
        TrustPayments.instance.gateway = nil
        XCTAssertThrowsError(try PaymentTransactionManager(apiManager: apiManager, threeDSecureManager: nil, jwt: nil, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil)) { error in
            XCTAssertEqual(error.localizedDescription, "[TP] Could not initialise PaymentTransactionManager due to uninitialised property: Gateway. Use TrustPayments.instance.configure() method to complete initialisation.")
            expectation.fulfill()
        }
        TrustPayments.instance.gateway = .eu
        
        TrustPayments.instance.environment = nil
        XCTAssertThrowsError(try PaymentTransactionManager(apiManager: apiManager, threeDSecureManager: nil, jwt: nil, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil)) { error in
            XCTAssertEqual(error.localizedDescription, "[TP] Could not initialise PaymentTransactionManager due to uninitialised property: Environment. Use TrustPayments.instance.configure() method to complete initialisation.")
            expectation.fulfill()
        }
        TrustPayments.instance.environment = .staging
        
        wait(for: [expectation], timeout: 1)
        TrustPayments.instance.configure(username: "", gateway: .eu, environment: .staging, translationsForOverride: nil)
    }

    func test_assignAllParameters() throws {
        let jwt = "jwt"
        let ptm = try PaymentTransactionManager(jwt: jwt)
        XCTAssertEqual(ptm.jwt, jwt)
        XCTAssertEqual(ptm.isLiveStatus, isLiveStatus)
    }

    func test_requestIdStartsWithJ() throws {
        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(),
                                                jwt: "")
        ptm.performTransaction(card: nil, transactionResponseClosure: nil)
        XCTAssertTrue(ptm.requestId.hasPrefix("J-"))
    }

    func test_requestIdHasLengthOf10() throws {
        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(),
                                                jwt: "")
        ptm.performTransaction(card: nil, transactionResponseClosure: nil)
        XCTAssertEqual(ptm.requestId.count, 10)
    }

    func test_requestIDsDiffer() throws {
        var requestIDs: Set<String> = []
        let numberOfIterations = 10
        for _ in 0 ..< numberOfIterations {
            let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(),
                                                    jwt: "")
            ptm.performTransaction(card: nil, transactionResponseClosure: nil)
            requestIDs.insert(ptm.requestId)
        }
        XCTAssertEqual(requestIDs.count, numberOfIterations)
    }

    func test_updatesJWT() throws {
        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(),
                                                jwt: "")
        XCTAssertEqual(ptm.jwt, "")
        ptm.performTransaction(jwt: "jwt", card: nil, transactionResponseClosure: nil)
        XCTAssertEqual(ptm.jwt, "jwt")
    }

    func test_setCard() throws {
        let card = Card(cardNumber: CardNumber(rawValue: "1234"), cvv: CVV(rawValue: "123"), expiryDate: ExpiryDate(rawValue: "10/22"))

        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(),
                                                jwt: "")
        XCTAssertNil(ptm.card)
        ptm.performTransaction(card: card, transactionResponseClosure: nil)
        XCTAssertEqual(ptm.card?.cardNumber?.rawValue, card.cardNumber?.rawValue)
        XCTAssertEqual(ptm.card?.cvv?.rawValue, card.cvv?.rawValue)
        XCTAssertEqual(ptm.card?.expiryDate?.rawValue, card.expiryDate?.rawValue)
    }

    func test_throwsForJailbreakWarningIsLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW01")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: true, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_throwsForJailbreakWarningNotLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW01")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: isLiveStatus, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_throwsForTamperedSDKWarningIsLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW02")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: true, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_throwsForTamperedSDKWarningNotLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW02")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: isLiveStatus, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_throwsForOSNotSupportedWarning() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW05")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: isLiveStatus, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_throwsForEmulatorRunningWarningIsLive() throws {
        TrustPayments.instance.updateEnvironment(to: .production)
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW03")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: true, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_doesntThrowsForEmulatorRunningWarningNotLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW03")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: isLiveStatus, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        XCTAssertNotNil(ptm)
    }

    func test_throwsForDebuggerAttachedWarningIsLive() throws {
        TrustPayments.instance.updateEnvironment(to: .production)
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW04")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: true, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_doesntThrowsForDebuggerAttachedWarningNotLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW04")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: isLiveStatus, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        XCTAssertNotNil(ptm)
    }

    func test_throwsForUntrustedSourceWarningIsLive() throws {
        TrustPayments.instance.updateEnvironment(to: .production)
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW06")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: true, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        XCTAssertThrowsError(
            try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        )
    }

    func test_doesntThrowsForUntrustedSourceWarningNotLive() throws {
        let sessionMock = CardinalSessionMock()
        sessionMock.setWarnings(warnings: [CardinalSessionMock.WarningStub(code: "SW06")])
        let threeDSecureManager = TP3DSecureManager(isLiveStatus: isLiveStatus, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: sessionMock)

        let ptm = try PaymentTransactionManager(apiManager: APIManagerMock(), threeDSecureManager: threeDSecureManager, jwt: "")
        XCTAssertNotNil(ptm)
    }
}
