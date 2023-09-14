//
//  TPResponse.swift
//  TrustPaymentsCore
//

/// a class representing the parsed, decoded form of the JWT response token
@objc public final class TPResponse: NSObject {
    @objc public let customerOutput: JWTResponseObject?
    @objc public let responseObjects: [JWTResponseObject]
    @objc public let cardReference: TPCardReference?
    public let tpError: TPError?
    @objc public var tpErrorFoundation: NSError? {
        tpError?.foundationError
    }

    /// Initializes an instance of the receiver
    /// - Parameters:
    ///   - customerOutput: response object telling about the transaction result (containing the customerOutput property or the last response in the sequence)
    ///   - responseObjects: response objects (each object with the most important properties parsed like settleStatus etc.)
    ///   - cardReference: card reference (containing masked card number, card type and transaction reference)
    ///   - tpError: error returned by gateway based on error code or error thrown when one of fields in JWT does not pass validation on gateway side
    init(customerOutput: JWTResponseObject?, responseObjects: [JWTResponseObject], cardReference: TPCardReference?, tpError: TPError?) {
        self.customerOutput = customerOutput
        self.responseObjects = responseObjects
        self.cardReference = cardReference
        self.tpError = tpError
        super.init()
    }
}
