//
//  APIManager.swift
//  TrustPaymentsCore
//

import Foundation

/// Performs payment transactions.
protocol APIManager {
    /// Performs the payment transaction request
    /// - Parameters:
    ///   - jwt: encoded JWT token
    ///   - request: object in which transaction parameters should be specified (e.g. what type - auth, 3dsecure etc)
    ///   - success: success closure with response objects (decoded transaction responses, in which settle status and transaction error code can be checked), and a JWT key that allows you to check the signature, and new JWT to be swapped in the request sequence
    ///   - failure: failure closure with general APIClient error like: connection error, server error, decoding problem
    func makeGeneralRequest(jwt: String, request: RequestObject, success: @escaping ((_ response: GeneralRequest.Response) -> Void), failure: @escaping ((_ error: APIClientError) -> Void))
    /// Performs the payment transaction requests
    /// - Parameters:
    ///   - jwt: encoded JWT token
    ///   - requests: request objects (in each object transaction parameters should be specified - e.g. what type - auth, 3dsecure etc)
    ///   - success: success closure with response objects (decoded transaction responses, in which settle status and transaction error code can be checked), and a JWT key that allows you to check the signature, and new JWT to be swapped in the request sequence
    ///   - failure: failure closure with general APIClient error like: connection error, server error, decoding problem
    func makeGeneralRequests(jwt: String, requests: [RequestObject], success: @escaping ((_ jwtResponses: [JWTResponseObject], _ jwt: String, _ newJWT: String) -> Void), failure: @escaping ((_ error: APIClientError) -> Void))
}
