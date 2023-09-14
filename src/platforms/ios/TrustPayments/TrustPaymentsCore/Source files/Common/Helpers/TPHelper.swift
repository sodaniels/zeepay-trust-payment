//
//  TPHelper.swift
//  TrustPaymentsCore
//

import Foundation

/// a helpful class to parse the JWT response token
@objc public final class TPHelper: NSObject {
    override private init() {}

    /// a helpful method to parse the JWT response token
    /// - Parameter jwt: a verified JWT token returned in response from the server
    /// - Returns: a TPResponse instance with parsed, decoded response objects
    @objc public static func getTPResponse(jwt: String) throws -> TPResponse {
        let jwtDecoded = try DecodedJWT(jwt: jwt)
        let responseObjects = jwtDecoded.jwtBodyResponse.responses
        let customerOutput = responseObjects.first(where: { $0.responseCustomerOutput != .unknown }) ?? responseObjects.last
        let cardReference = responseObjects.last?.cardReference

        var tpError: TPError?
        if let responseWithError = responseObjects.first(where: { $0.responseErrorCode != .successful }) {
            tpError = TPError.composeGatewayOrValidationError(responseWithError: responseWithError)
        }

        return TPResponse(customerOutput: customerOutput, responseObjects: responseObjects, cardReference: cardReference, tpError: tpError)
    }

    /// a helpful method to parse an array of JWT response tokens
    /// - Parameter jwt: an array of verified JWT tokens  returned in response from the server
    /// - Returns: an array of TPResponse instances containing the parsed, decoded response objects
    @objc public static func getTPResponses(jwt: [String]) throws -> [TPResponse] {
        try jwt.map { try TPHelper.getTPResponse(jwt: $0) }
    }
}
