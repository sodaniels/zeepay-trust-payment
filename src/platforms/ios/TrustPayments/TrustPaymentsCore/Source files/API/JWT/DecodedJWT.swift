//
//  DecodedJWT.swift
//  TrustPaymentsCore
//

class DecodedJWT: BaseDecodedJWT {
    // MARK: Properties

    let jwtBodyResponse: JWTBodyResponse
    let string: String

    var hasErrors: Bool {
        jwtBodyResponse.responses.contains { $0.responseErrorCode != ResponseErrorCode.successful }
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameter jwt: encoded JWT token
    /// - Throws: error occurred when decoding the JWT
    override init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw APIClientError.jwtDecodingInvalidPartCount
        }
        jwtBodyResponse = try DecodedJWT.decodeJWTBodyByDecoder(parts[1])
        string = jwt
        try super.init(jwt: jwt)
    }

    private static func decodeJWTBodyByDecoder(_ value: String) throws -> JWTBodyResponse {
        guard let bodyData = DecodedJWT.base64UrlDecode(value) else {
            throw APIClientError.jwtDecodingInvalidBase64Url
        }

        let decoder = JWTBodyResponse.decoder
        guard let payload = try? decoder.decode(JWTBodyResponse.self, from: bodyData) else {
            throw APIClientError.jwtDecodingInvalidJSON
        }

        return payload
    }
}
