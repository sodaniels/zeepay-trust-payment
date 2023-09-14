//
//  TPInitError.swift
//  TrustPaymentsCore
//

#if !COCOAPODS
    import TrustPayments3DSecure
#endif
import Foundation

/// An error object thrown when required parameters are missing in order to perform a transaction or the environment is not safe to perform the 3DS flow.
/// # Codes: #
/// 9000 - missing parameters
///
/// 9100 - environment is not safe to perform transaction
@objc public final class TPInitError: NSError {
    init(cardinalWarnings: [CardinalInitWarnings]) {
        let message = "[TP] Could not initialise PaymentTransactionManager due to: \(cardinalWarnings.map(\.localizedDescription).joined(separator: ", "))"
        super.init(domain: NSError.domain, code: 9100, userInfo: [NSLocalizedDescriptionKey: message])
    }

    init(missingValue: TPInitErrorType) {
        let message = "[TP] Could not initialise PaymentTransactionManager due to uninitialised property: \(missingValue.propertyName). Use TrustPayments.instance.configure() method to complete initialisation."
        super.init(domain: NSError.domain, code: 9000, userInfo: [NSLocalizedDescriptionKey: message])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TPInitError {
    enum TPInitErrorType {
        case missingUsername
        case missingGateway
        case missingEnvironment

        var propertyName: String {
            switch self {
            case .missingEnvironment: return "Environment"
            case .missingGateway: return "Gateway"
            case .missingUsername: return "Username"
            }
        }
    }
}
