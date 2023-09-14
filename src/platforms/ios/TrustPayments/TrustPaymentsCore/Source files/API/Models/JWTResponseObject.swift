//
//  JWTResponse.swift
//  TrustPaymentsCore
//

/// enum that determines the flow of a transaction
@objc public enum CustomerOutput: Int, CaseIterable {
    // stop and return the transaction closure (ignore any remaining request types in jwt response)
    case result
    // return the transaction closure and the merchant should ask the customer to try the payment process all over again
    case tryAgain
    // perform step-up authentication
    case threeDRedirect
    // missing customer output property - check the last response in the JWT (customerResponse will be created from the last response)
    case unknown

    public var stringValue: String {
        switch self {
        case .result:
            return "RESULT"
        case .tryAgain:
            return "TRYAGAIN"
        case .threeDRedirect:
            return "THREEDREDIRECT"
        case .unknown:
            return "unknown"
        }
    }
}

/// Maps error code from gateway to enum for easier error handling. Consists of most common errors.
@objc public enum ResponseErrorCode: Int {
    case successful = 0
    case transactionNotAuhorised = 60_022
    case declinedByIssuingBank = 70_000
    case fieldError = 30_000
    case bankSystemError = 60_010
    case manualInvestigationRequired = 60_034
    case bypass = 22_000
    case unknown = 99_999
    case other
}

/// Maps settle status code from gateway to enum.
@objc public enum ResponseSettleStatus: Int {
    case pendingAutomaticSettlement = 0
    case pendingManualSettlement = 1
    case settlementInProgress = 10
    case instantSettlement = 100
    case paymentAuthorisedButSuspended = 2
    case paymentCancelled = 3
    case error
}

/// Extends error codes to provide more details if available. Currently available only for invalid field error.
/// ```
/// switch errorDetails {
///    case .invalidPAN: // Highlight PAN field
///    default: break
/// }
/// ```
@objc public enum ResponseErrorDetail: Int {
    case invalidPAN = 12_501
    case invalidCVV = 12_502
    case invalidJWT = 12_503
    case invalidExpiryDate = 12_504
    case invalidTermURL = 12_505
    case invalidParentTransactionReference = 12_506
    case invalidSiteReference = 12_507
    case invalidSubscriptionNumber = 12_508
    case invalidTypeDescriptions = 12_509
    case unknown = 12_500

    /// Error detail message
    ///
    /// As the message is not localized, use it mainly for logs, not intended to be presented to the end user.
    /// The text may change in future updates
    /// - warning: The message is not localized
    public var message: String {
        switch self {
        case .invalidPAN: return "Invalid field: PAN"
        case .invalidCVV: return "Invalid field: CVV"
        case .invalidJWT: return "Invalid field: JWT"
        case .invalidExpiryDate: return "Invalid field: Expiry date"
        case .invalidTermURL: return "Invalid field: Term URL"
        case .invalidParentTransactionReference: return "Invalid field: Parent transaction reference"
        case .invalidSiteReference: return "Invalid field: Site reference"
        case .invalidSubscriptionNumber: return "Invalid field: Subscription number"
        case .invalidTypeDescriptions: return "Invalid field: Type descriptions"
        case .unknown: return "Invalid field: Unknown"
        }
    }
}

/// Acquirer's recommendation action regarding the transaction and posibility of fraud.
/// - warning: Note that this ONLY a recommendation. Protect Plus does not guarantee against fraud.
@objc public enum ResponseAcquirerRecommendedAction: Int, CaseIterable {
    // Continue with the transaction.
    case continueTransaction
    // Stop transaction.
    case stopTransaction

    case unknown

    public var stringValue: String {
        switch self {
        case .continueTransaction:
            return "C"
        case .stopTransaction:
            return "S"
        case .unknown:
            return "unknown"
        }
    }
}

/// Fraud control shield status code.
@objc public enum ResponseFraudControlShieldStatusCode: Int, CaseIterable {
    // The details are not deemed suspicious.
    case accept
    // Further investigation is recommended.
    case challenge
    // The details are suspicious and a transaction should not be performed.
    case deny
    // Returned when a parent AUTH Request has been declined.
    case noScore

    case unknown

    public var stringValue: String {
        switch self {
        case .accept:
            return "ACCEPT"
        case .challenge:
            return "CHALLENGE"
        case .deny:
            return "DENY"
        case .noScore:
            return "NOSCORE"
        case .unknown:
            return "unknown"
        }
    }
}

/// Response object from gateway.
///
/// Check for errors and transaction status.
///
/// Use `cardReference` property to store cards for future use, if user agreed to it (credentialsonfile).
@objc public class JWTResponseObject: NSObject, Decodable {
    // MARK: Properties

    @objc public let customerOutput: String?

    @objc public var responseCustomerOutput: CustomerOutput {
        CustomerOutput.allCases.first(where: { $0.stringValue == customerOutput }) ?? .unknown
    }

    @objc public let errorCode: Int
    @objc public let errorMessage: String

    @objc public let settleStatus: NSNumber?

    @objc public let transactionReference: String?

    @objc public let errorData: [String]?

    @objc public let threeDInit: String?

    @objc public let cacheToken: String?

    @objc public let cardEnrolled: String?

    @objc public let threeDPayload: String?

    @objc public let threeDVersion: String?

    @objc public let acsUrl: String?

    @objc public let acquirerTransactionReference: String?

    // authentication status - when the status is “N”, indicating the customer failed authentication, the errorcode “60022” will be returned.
    @objc public let status: String?

    @objc public var responseErrorCode: ResponseErrorCode {
        ResponseErrorCode(rawValue: errorCode) ?? .unknown
    }

    // returns localized error from gateway
    @objc public var localizedError: String? {
        if let errorData = errorData?.first {
            return errorMessage + ": " + "\(errorData)"
        }
        return nil
    }

    @objc public var responseSettleStatus: ResponseSettleStatus {
        ResponseSettleStatus(rawValue: settleStatus?.intValue ?? -1) ?? .error
    }

    @objc public let cardReference: TPCardReference?

    @objc public var errorDetails: ResponseErrorDetail {
        // confirmed with TP, error data will only have max 1 element at the time,
        // even when there are multiple errors
        // errors are parsed one by one on the gateway

        switch responseErrorCode {
        case .fieldError:
            switch errorData?.first {
            case "pan": return ResponseErrorDetail.invalidPAN
            case "jwt": return ResponseErrorDetail.invalidJWT
            case "securitycode": return ResponseErrorDetail.invalidCVV
            case "expirydate": return ResponseErrorDetail.invalidExpiryDate
            case "termurl": return ResponseErrorDetail.invalidTermURL
            case "parenttransactionreference": return ResponseErrorDetail.invalidParentTransactionReference
            case "sitereference": return ResponseErrorDetail.invalidSiteReference
            case "subscriptionnumber": return ResponseErrorDetail.invalidSubscriptionNumber
            case "requesttypedescriptions": return ResponseErrorDetail.invalidTypeDescriptions
            default: return ResponseErrorDetail.unknown
            }
        default: return ResponseErrorDetail.unknown
        }
    }

    public let requestTypeDescription: TypeDescription?

    // MARK: RISKDEC properties

    @objc public let fraudControlShieldStatusCode: String?

    @objc public var responseFraudControlShieldStatusCode: ResponseFraudControlShieldStatusCode {
        ResponseFraudControlShieldStatusCode.allCases.first(where: { $0.stringValue == fraudControlShieldStatusCode }) ?? .unknown
    }

    @objc public let fraudControlReference: String?
    @objc public let fraudControlResponseCode: String?
    @objc public let acquirerRecommendedAction: String?

    @objc public var responseAcquirerRecommendedAction: ResponseAcquirerRecommendedAction {
        ResponseAcquirerRecommendedAction.allCases.first(where: { $0.stringValue == acquirerRecommendedAction }) ?? .unknown
    }

    @objc public let ruleCategoryFlag: String?
    @objc public let ruleCategoryMessage: String?

    // MARK: APM

    let redirectUrl: String?

    // MARK: Initialization

    /// - SeeAlso: Swift.Decodable
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorCodeString = try container.decode(String.self, forKey: .errorCode)
        customerOutput = try container.decodeIfPresent(String.self, forKey: .customerOutput)
        errorCode = Int(errorCodeString) ?? -1
        errorMessage = try container.decode(String.self, forKey: .errorMessage)
        errorData = try container.decodeIfPresent([String].self, forKey: .errorData)
        if let settleStatusString = try container.decodeIfPresent(String.self, forKey: .settleStatus), let settleStatusInt = Int(settleStatusString) {
            settleStatus = NSNumber(value: settleStatusInt)
        } else {
            settleStatus = nil
        }
        transactionReference = try container.decodeIfPresent(String.self, forKey: .transactionReference)
        if let maskedPan = try container.decodeIfPresent(String.self, forKey: .maskedPan), let paymentDescription = try container.decodeIfPresent(String.self, forKey: .paymentDescription) {
            cardReference = TPCardReference(reference: transactionReference, cardType: paymentDescription, pan: maskedPan)
        } else {
            cardReference = nil
        }
        if let type = try container.decodeIfPresent(String.self, forKey: .requestTypeDescription), let typeDescription = TypeDescription(rawValue: type) {
            requestTypeDescription = typeDescription
        } else {
            requestTypeDescription = nil
        }
        threeDInit = try container.decodeIfPresent(String.self, forKey: .threeDInit)
        cacheToken = try container.decodeIfPresent(String.self, forKey: .cacheToken)
        cardEnrolled = try container.decodeIfPresent(String.self, forKey: .cardEnrolled)
        threeDPayload = try container.decodeIfPresent(String.self, forKey: .threeDPayload)
        threeDVersion = try container.decodeIfPresent(String.self, forKey: .threeDVersion)
        acsUrl = try container.decodeIfPresent(String.self, forKey: .acsUrl)
        acquirerTransactionReference = try container.decodeIfPresent(String.self, forKey: .acquirerTransactionReference)
        status = try container.decodeIfPresent(String.self, forKey: .status)

        // riskdec
        fraudControlShieldStatusCode = try container.decodeIfPresent(String.self, forKey: .fraudControlShieldStatusCode)
        fraudControlReference = try container.decodeIfPresent(String.self, forKey: .fraudControlReference)
        fraudControlResponseCode = try container.decodeIfPresent(String.self, forKey: .fraudControlResponseCode)
        acquirerRecommendedAction = try container.decodeIfPresent(String.self, forKey: .acquirerRecommendedAction)
        ruleCategoryFlag = try container.decodeIfPresent(String.self, forKey: .ruleCategoryFlag)
        ruleCategoryMessage = try container.decodeIfPresent(String.self, forKey: .ruleCategoryMessage)
        redirectUrl = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
    }

    // MARK: Methods

    public func requestTypeDescription(contains description: TypeDescription) -> Bool {
        guard let type = requestTypeDescription else { return false }
        return description.rawValue == type.rawValue
    }

    @objc public func requestTypeDescription(contains description: TypeDescriptionObjc) -> Bool {
        guard let type = requestTypeDescription else { return false }
        return description.rawValue == type.code
    }
}

private extension JWTResponseObject {
    enum CodingKeys: String, CodingKey {
        case customerOutput = "customeroutput"
        case errorCode = "errorcode"
        case errorMessage = "errormessage"
        case errorData = "errordata"
        case settleStatus = "settlestatus"
        case transactionReference = "transactionreference"
        case requestTypeDescription = "requesttypedescription"
        case maskedPan = "maskedpan"
        case paymentDescription = "paymenttypedescription"
        case threeDInit = "threedinit"
        case cacheToken = "cachetoken"
        case cardEnrolled = "enrolled"
        case threeDPayload = "threedpayload"
        case threeDVersion = "threedversion"
        case acsUrl = "acsurl"
        case acquirerTransactionReference = "acquirertransactionreference"
        case status

        // riskdec
        case fraudControlShieldStatusCode = "fraudcontrolshieldstatuscode"
        case fraudControlReference = "fraudcontrolreference"
        case fraudControlResponseCode = "fraudcontrolresponsecode"
        case acquirerRecommendedAction = "acquirerrecommendedaction"
        case ruleCategoryFlag = "rulecategoryflag"
        case ruleCategoryMessage = "rulecategorymessage"

        // APM
        case redirectUrl = "redirecturl"
    }
}
