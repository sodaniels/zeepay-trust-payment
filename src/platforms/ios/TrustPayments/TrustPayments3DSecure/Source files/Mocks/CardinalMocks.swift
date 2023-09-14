//
//  CardinalMocks.swift
//  TrustPayments3DSecure
//

import CardinalMobile

/// Returns all warnings
class CardinalSessionMock: CardinalSession {
    class WarningStub: Warning {
        init(code: String? = nil) {
            super.init()
            warningID = code!
        }
    }

    private var mockedWarnings: [WarningStub] = [
        CardinalSessionMock.WarningStub(code: "SW01"),
        CardinalSessionMock.WarningStub(code: "SW02"),
        CardinalSessionMock.WarningStub(code: "SW03"),
        CardinalSessionMock.WarningStub(code: "SW04"),
        CardinalSessionMock.WarningStub(code: "SW05"),
        CardinalSessionMock.WarningStub(code: "SW06")
    ]
    func setWarnings(warnings: [WarningStub]) {
        mockedWarnings = warnings
    }

    override func getWarnings() -> [Warning] {
        mockedWarnings
    }
}

/// Returns response for given code
class CardinalResponseMock: NSObject {
    let code: CardinalResponseActionCode
    init(_ action: CardinalResponseActionCode = .noAction) {
        code = action
    }

    var actionCode: CardinalResponseActionCode {
        code
    }
}

extension TP3DSecureManager {
    func cardinalSession(cardinalSession _: CardinalSession!, stepUpValidated validateResponse: CardinalResponseMock!, serverJWT: String!) {
        switch validateResponse.actionCode {
        case .noAction:
            fallthrough
        case .success:
            sessionAuthenticationValidateJWT?(serverJWT)
        case .timeout:
            fallthrough
        case .cancel:
            fallthrough
        case .failure:
            fallthrough
        case .error:
            fallthrough
        @unknown default:
            sessionAuthenticationFailure?()
        }
    }
}
