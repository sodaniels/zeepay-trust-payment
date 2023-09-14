//
//  Test3DSecureManager.swift
//  Test3DSecureManager
//

import CardinalMobile
@testable import TrustPayments3DSecure
import XCTest

class Test3DSecureManager: XCTestCase {
    var sut: TP3DSecureManager!

    override func setUp() {
        sut = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil)
    }

    func test_validateJWTClosureForNoActionResponse() {
        continueSessionForJWTValidationWith(action: .noAction, jwt: "serverJWT-noAction")
    }

    func test_validateJWTClosureForSuccessResponse() {
        continueSessionForJWTValidationWith(action: .success, jwt: "serverJWT-success")
    }

    func test_failureClosureForCancelResponse() {
        continueSessionForFailureResponse(action: .cancel)
    }

    func test_failureClosureForTimeoutResponse() {
        continueSessionForFailureResponse(action: .timeout)
    }

    func test_failureClosureForFailureResponse() {
        continueSessionForFailureResponse(action: .failure)
    }

    func test_failureClosureForErrorResponse() {
        continueSessionForFailureResponse(action: .error)
    }

    func test_allCardinalWarnings() {
        let mock = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: nil, cardinalDarkModeStyleManager: nil, session: CardinalSessionMock())
        let sut = mock.warnings
        let expectedWarning: [CardinalInitWarnings] = [
            .jailbroken,
            .integrityTampered,
            .emulatorBeingUsed,
            .debuggerAttached,
            .osNotSupported,
            .appFromNotTrustedSource
        ]
        XCTAssertEqual(sut.count, expectedWarning.count)
        for warning in expectedWarning {
            XCTAssertTrue(sut.contains(warning))
        }
    }
}

// MARK: Helper methods

extension Test3DSecureManager {
    private func continueSessionForFailureResponse(action: CardinalResponseActionCode) {
        let expectations = XCTestExpectation()

        sut.continueSession(with: "", payload: "", sessionAuthenticationValidateJWT: { _ in
            XCTFail("Should not call this closure")
        }, sessionAuthenticationFailure: {
            expectations.fulfill()
        })
        sut.cardinalSession(cardinalSession: CardinalSession(), stepUpValidated: CardinalResponseMock(action), serverJWT: "")
        wait(for: [expectations], timeout: 1)
    }

    private func continueSessionForJWTValidationWith(action: CardinalResponseActionCode, jwt serverJWT: String) {
        let expectation = XCTestExpectation()

        sut.continueSession(with: "", payload: "", sessionAuthenticationValidateJWT: { jwt in
            XCTAssertEqual(serverJWT, jwt)
            expectation.fulfill()
        }, sessionAuthenticationFailure: {
            expectation.fulfill()
            XCTFail("Should not call this closure")
        })
        sut.cardinalSession(cardinalSession: CardinalSession(), stepUpValidated: CardinalResponseMock(action), serverJWT: serverJWT)
        wait(for: [expectation], timeout: 1)
    }
}
