//
//  DecodedMerchantJWT.swift
//  TrustPaymentsCore
//

public class DecodedMerchantJWT: BaseDecodedJWT {
    // MARK: Properties

    private let jwtMerchantBodyResponse: JWTMerchantBodyResponse

    public var typeDescriptions: [TypeDescription] { jwtMerchantBodyResponse.typeDescriptions }
    public var termUrl: String? { jwtMerchantBodyResponse.termUrl }
    public var billingFirstname: String? { jwtMerchantBodyResponse.billingFirstname }
    public var billingLastname: String? { jwtMerchantBodyResponse.billingLastname }
    public var billingStreet: String? { jwtMerchantBodyResponse.billingStreet }
    public var billingTown: String? { jwtMerchantBodyResponse.billingTown }
    public var billingCounty: String? { jwtMerchantBodyResponse.billingCounty }
    public var billingCountryiso2a: String? { jwtMerchantBodyResponse.billingCountryiso2a }
    public var billingPostcode: String? { jwtMerchantBodyResponse.billingPostcode }
    public var billingEmail: String? { jwtMerchantBodyResponse.billingEmail }
    public var billingPremise: String? { jwtMerchantBodyResponse.billingPremise }
    public var baseAmount: Int? { jwtMerchantBodyResponse.baseAmount }
    public var mainAmount: Double? { jwtMerchantBodyResponse.mainAmount }
    public var siteReference: String? { jwtMerchantBodyResponse.siteReference }
    public var fraudControlTransactionId: String? { jwtMerchantBodyResponse.fraudControlTransactionId }
    public var currencyIso3a: String? { jwtMerchantBodyResponse.currencyIso3a }
    public var customerFirstname: String? { jwtMerchantBodyResponse.customerFirstname }
    public var customerLastname: String? { jwtMerchantBodyResponse.customerLastname }
    public var customerEmail: String? { jwtMerchantBodyResponse.customerEmail }
    public var customerPremise: String? { jwtMerchantBodyResponse.customerPremise }
    public var customerTown: String? { jwtMerchantBodyResponse.customerTown }
    public var customerStreet: String? { jwtMerchantBodyResponse.customerStreet }
    public var customerPostcode: String? { jwtMerchantBodyResponse.customerPostcode }
    public var customerCounty: String? { jwtMerchantBodyResponse.customerCounty }
    public var customerCountryiso2a: String? { jwtMerchantBodyResponse.customerCountryiso2a }
    public var returnUrl: String? { jwtMerchantBodyResponse.returnUrl }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameter jwt: encoded JWT token
    /// - Throws: error occurred when decoding the JWT
    override public init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw APIClientError.jwtDecodingInvalidPartCount
        }
        jwtMerchantBodyResponse = try DecodedMerchantJWT.decodeJWTMerchantBodyByDecoder(parts[1])
        try super.init(jwt: jwt)
    }

    private static func decodeJWTMerchantBodyByDecoder(_ value: String) throws -> JWTMerchantBodyResponse {
        guard let bodyData = base64UrlDecode(value) else {
            throw APIClientError.jwtDecodingInvalidBase64Url
        }

        let decoder = JWTMerchantBodyResponse.decoder
        guard let payload = try? decoder.decode(JWTMerchantBodyResponse.self, from: bodyData) else {
            throw APIClientError.jwtDecodingInvalidJSON
        }

        return payload
    }
}
