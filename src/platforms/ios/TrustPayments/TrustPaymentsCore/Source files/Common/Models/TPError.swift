//
//  TPError.swift
//  TrustPaymentsCore
//

import Foundation

public enum TPError: HumanReadableError {
    /// Error returned by gateway based on error code.
    case gatewayError(ResponseErrorCode, Error)

    /// Thrown when one of fields in JWT does not pass validation on gateway side
    case invalidField(ResponseErrorDetail, String?)

    /// - SeeAlso: HumanReadableStringConvertible.humanReadableDescription
    public var humanReadableDescription: String {
        switch self {
        case let .gatewayError(_, error as NSError):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(error.localizedDescription)"
        case let .invalidField(code, localizedError):
            return localizedError ?? code.message
        }
    }

    /// objc helpers
    var errorCode: Int {
        switch self {
        case let .gatewayError(_, error):
            return (error as NSError).code
        case let .invalidField(responseErrorDetail, _):
            return responseErrorDetail.rawValue
        }
    }

    /// expose error for objc
    public var foundationError: NSError {
        NSError(domain: NSError.domain, code: errorCode, userInfo: [
            NSLocalizedDescriptionKey: humanReadableDescription
        ])
    }

    static func composeGatewayOrValidationError(responseWithError: JWTResponseObject) -> TPError {
        if responseWithError.responseErrorCode == .fieldError {
            return TPError.invalidField(responseWithError.errorDetails, responseWithError.localizedError)
        } else {
            return TPError.gatewayError(responseWithError.responseErrorCode, NSError(domain: NSError.domain, code: responseWithError.errorCode, userInfo: [NSLocalizedDescriptionKey: responseWithError.localizedError ?? responseWithError.errorMessage]))
        }
    }
}
