//
//  JWTBodyResponse.swift
//  TrustPaymentsCore
//

struct JWTBodyPayload: Decodable {
    // MARK: Properties

    let newJWT: String?
    let responses: [JWTResponseObject]
    let requestReference: String?
}

private extension JWTBodyPayload {
    enum CodingKeys: String, CodingKey {
        case responses = "response"
        case newJWT = "jwt"
        case requestReference = "requestreference"
    }
}

struct JWTBodyResponse: APIResponse {
    // MARK: Properties

    // new JWT token to be swapped in the request sequence
    let newJWT: String

    // array of multiple responses is returned in the case of multiple type descriptions request
    // for instance account check and auth will result in 2 response objects
    let responses: [JWTResponseObject]

    // The "W-" request reference. Can be searched for on the Gateway side.
    let requestReference: String?

    // MARK: Initialization

    /// - SeeAlso: Swift.Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let payload = try container.decode(JWTBodyPayload.self, forKey: .payload)
        newJWT = payload.newJWT ?? .empty
        responses = payload.responses
        requestReference = payload.requestReference
    }
}

private extension JWTBodyResponse {
    enum CodingKeys: String, CodingKey {
        case payload
    }
}
