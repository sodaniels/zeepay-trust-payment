//
//  DecodedJWTObject.swift
//  TrustPaymentsCore
//

import Foundation

extension JWT {
    var issuer: String? { claim(name: "iss").string }
    var audience: [String]? { claim(name: "aud").array }
    var expiresAt: Date? { claim(name: "exp").date }
    var subject: String? { claim(name: "sub").string }
    var issuedAt: Date? { claim(name: "iat").date }
    var notBefore: Date? { claim(name: "nbf").date }
    var identifier: String? { claim(name: "jti").string }

    var expired: Bool {
        guard let date = expiresAt else {
            return false
        }
        return date.compare(Date()) != ComparisonResult.orderedDescending
    }

    /// Return a claim by it's name
    /// - Parameter name: name of the claim in the JWT object
    /// - Returns: a claim of the JWT
    func claim(name: String) -> Claim {
        let value = body[name]
        return Claim(value: value)
    }
}

public class BaseDecodedJWT: JWT {
    // MARK: Properties

    let header: [String: Any]
    let body: [String: Any]
    let signature: String?

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameter jwt: encoded JWT token
    /// - Throws: error occurred when decoding the JWT
    public init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw APIClientError.jwtDecodingInvalidPartCount
        }

        header = try BaseDecodedJWT.decodeJWTPart(parts[0])
        body = try BaseDecodedJWT.decodeJWTPart(parts[1])
        signature = parts[2]
    }

    // MARK: Decoding methods

    static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    private static func decodeJWTPart(_ value: String) throws -> [String: Any] {
        guard let bodyData = base64UrlDecode(value) else {
            throw APIClientError.jwtDecodingInvalidBase64Url
        }

        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            throw APIClientError.jwtDecodingInvalidJSON
        }

        return payload
    }
}
