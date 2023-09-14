//
//  GeneralResponse.swift
//  TrustPaymentsCore
//

import Foundation

struct GeneralResponse: APIResponse {
    // MARK: Properties

    let jwt: String
    let newJWT: String
    let jwtDecoded: DecodedJWT
    let jwtResponses: [JWTResponseObject]
    let requestReference: String?

    // MARK: Initialization

    /// - SeeAlso: Swift.Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jwt = try container.decode(String.self, forKey: .jwt)
        jwtDecoded = try DecodedJWT(jwt: jwt)
        newJWT = jwtDecoded.jwtBodyResponse.newJWT
        jwtResponses = jwtDecoded.jwtBodyResponse.responses
        requestReference = jwtDecoded.jwtBodyResponse.requestReference
    }
}

private extension GeneralResponse {
    enum CodingKeys: String, CodingKey {
        case jwt
    }
}
