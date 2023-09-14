//
//  APIClientError.swift
//  TrustPaymentsCore
//

import Foundation

/// Contains errors that can be thrown by `APIClient`.
public enum APIClientError: HumanReadableError {
    /// The request could not be built.
    case requestBuildError(Error)
    /// There was a connection error.
    case connectionError(Error)
    /// Received response is not valid.
    case responseValidationError(APIResponseValidationError)
    /// Received response could not be parsed.
    case responseParseError(Error)
    /// A server-side error has occurred.
    case serverError(HumanReadableError)
    /// A custom error has occurred.
    case customError(HumanReadableError)
    /// Something really weird happend. Cannot detect the error.
    case unknownError
    /// Missing jwt
    case jwtMissing
    /// jwtDecodingError
    case jwtDecodingInvalidBase64Url
    /// jwtDecodingError
    case jwtDecodingInvalidJSON
    /// jwtDecodingError
    case jwtDecodingInvalidPartCount
    /// request inaccessible after retries
    case inaccessible
    /// `URLSession` errors are passed-through, handle as appropriate.
    /// needed to determine whether a retry of request should happen
    case urlError(URLError)
    /// cardinal setup error (problem with authenticating merchant's credentials (jwt) and completing the data collection process)
    case cardinalSetupInternalError
    /// some problem occurred in the authentication session (performing the challenge between the user and the issuing bank)
    case cardinalAuthenticationError
    /// if settle_status parameter from APM is different than 0, an error occured
    case apmSettleStatusError

    // MARK: Properties

    /// Whether error is caused by "400 BAD REQUEST" status code.
    var isBadRequestStatusCode: Bool {
        error(dueToStatusCode: 400)
    }

    /// Whether error is caused by "401 UNAUTHORIZED" status code.
    var isUnauthorizedStatusCode: Bool {
        error(dueToStatusCode: 401)
    }

    /// Whether error is caused by timed out request.
    var isTimeoutError: Bool {
        if case let .connectionError(error) = self {
            return (error as NSError).code == NSURLErrorTimedOut
        }
        return false
    }

    /// - SeeAlso: HumanReadableStringConvertible.humanReadableDescription
    public var humanReadableDescription: String {
        switch self {
        case let .requestBuildError(error as NSError):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(error.humanReadableDescription)"
        case let .connectionError(error as HumanReadableStringConvertible):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(error.humanReadableDescription)"
        case let .responseValidationError(error):
            return error.localizedDescription
        case let .responseParseError(error as NSError):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(error.localizedDescription)"
        case let .serverError(error):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(error.humanReadableDescription)"
        case let .customError(error):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(error.humanReadableDescription)"
        case .unknownError:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .jwtMissing:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .jwtDecodingInvalidBase64Url:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .jwtDecodingInvalidJSON:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .jwtDecodingInvalidPartCount:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .inaccessible:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case let .urlError(urlError):
            return "\(LocalizableKeys.Errors.general.localizedStringOrEmpty): \(urlError.localizedDescription)"
        case .cardinalSetupInternalError:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .cardinalAuthenticationError:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        case .apmSettleStatusError:
            return LocalizableKeys.Errors.general.localizedStringOrEmpty
        }
    }

    /// Used to determine whether a network request should be retried
    var shouldRetry: Bool {
        switch self {
        case let .urlError(urlError):
            //  retry for network issues
            switch urlError.code {
            case URLError.timedOut,
                 URLError.cannotFindHost,
                 URLError.cannotConnectToHost,
                 URLError.networkConnectionLost,
                 URLError.dnsLookupFailed:
                return true
            default: break
            }
        default: break
        }
        return false
    }

    /// objc helpers
    var errorCode: Int {
        switch self {
        case .requestBuildError:
            return 10_000
        case .connectionError:
            return 11_000
        case let .responseValidationError(validationError):
            return validationError.errorCode
        case .responseParseError:
            return 13_000
        case .serverError:
            return 14_000
        case .customError:
            return 15_000
        case .unknownError:
            return 16_000
        case .jwtMissing:
            return 17_000
        case .jwtDecodingInvalidBase64Url:
            return 17_100
        case .jwtDecodingInvalidJSON:
            return 17_200
        case .jwtDecodingInvalidPartCount:
            return 17_300
        case .inaccessible:
            return 20_000
        case let .urlError(urlError):
            return urlError.code.rawValue
        case .cardinalSetupInternalError:
            return 1010
        case .cardinalAuthenticationError:
            return 21_000
        case .apmSettleStatusError:
            return 24_000
        }
    }

    /// expose error for objc
    public var foundationError: NSError {
        NSError(domain: NSError.domain, code: errorCode, userInfo: [
            NSLocalizedDescriptionKey: humanReadableDescription
        ])
    }

    // MARK: Functions

    /// Checks whether error is caused by given status code.
    ///
    /// - Parameter code: Code to check.
    /// - Returns: Flag inficating whether error is status cause by given code or not.
    private func error(dueToStatusCode statusCode: Int) -> Bool {
        if case .responseValidationError(.unacceptableStatusCode(statusCode, _)) = self {
            return true
        }
        return false
    }
}

/// Contains API response validation errors.
///
/// - unacceptableStatusCode: Thrown if response's status code is not acceptable.
/// - missingResponse: Thrown if response is missing.
/// - missingData: Thrown if response is missing data.
public enum APIResponseValidationError: Error {
    case unacceptableStatusCode(actual: Int, expected: CountableClosedRange<Int>)
    case missingResponse
    case missingData
    case missingJwt
    case missingTypeDescriptions
    case missingTermUrl
    case missingReturnUrl

    // MARK: Properties

    /// - SeeAlso: Error.localizedDescription
    public var localizedDescription: String {
        switch self {
        case let .unacceptableStatusCode(actual, _):
            return "Unsupported status code: \(actual)."
        case .missingResponse, .missingData, .missingJwt, .missingTypeDescriptions, .missingTermUrl, .missingReturnUrl:
            return "Missing data."
        }
    }

    var errorCode: Int {
        // The error code adds to the error code value of responseValidationError in APIClientError
        // which it extends to more detailed level
        switch self {
        case .missingData: return 12_200
        case .missingResponse: return 12_300
        case .unacceptableStatusCode: return 12_400
        case .missingJwt: return 12_500
        case .missingTypeDescriptions: return 12_600
        case .missingTermUrl: return 12_700
        case .missingReturnUrl: return 12_800
        }
    }
}
