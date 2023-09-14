//
//  JWTMerchantBodyResponse.swift
//  TrustPaymentsCore
//

struct JWTMerchantBodyPayload: Decodable {
    // MARK: Properties
    
    let typeDescriptions: [TypeDescription]
    let termUrl: String?
    let billingFirstname: String?
    let billingLastname: String?
    let billingStreet: String?
    let billingTown: String?
    let billingCounty: String?
    let billingCountryiso2a: String?
    let billingPostcode: String?
    let billingEmail: String?
    let billingPremise: String?
    let baseAmount: Int?
    let mainAmount: Double?
    let siteReference: String?
    let fraudControlTransactionId: String?
    let currencyIso3a: String?
    let customerFirstname: String?
    let customerLastname: String?
    let customerEmail: String?
    let customerPremise: String?
    let customerTown: String?
    let customerStreet: String?
    let customerPostcode: String?
    let customerCounty: String?
    let customerCountryiso2a: String?
    let returnUrl: String?
}

private extension JWTMerchantBodyPayload {
    enum CodingKeys: String, CodingKey {
        case typeDescriptions = "requesttypedescriptions"
        case termUrl = "termurl"
        case billingFirstname = "billingfirstname"
        case billingLastname = "billinglastname"
        case billingStreet = "billingstreet"
        case billingTown = "billingtown"
        case billingCounty = "billingcounty"
        case billingCountryiso2a = "billingcountryiso2a"
        case billingPostcode = "billingpostcode"
        case billingEmail = "billingemail"
        case billingPremise = "billingpremise"
        case baseAmount = "baseamount"
        case mainAmount = "mainamount"
        case siteReference = "sitereference"
        case fraudControlTransactionId = "fraudcontroltransactionid"
        case currencyIso3a = "currencyiso3a"
        case customerFirstname = "customerfirstname"
        case customerLastname = "customerlastname"
        case customerEmail = "customeremail"
        case customerPremise = "customerpremise"
        case customerTown = "customertown"
        case customerStreet = "customerstreet"
        case customerPostcode = "customerpostcode"
        case customerCounty = "customercounty"
        case customerCountryiso2a = "customercountryiso2a"
        case returnUrl = "returnurl"
    }
}

struct JWTMerchantBodyResponse: APIResponse {
    // MARK: Properties
    
    let typeDescriptions: [TypeDescription]
    let termUrl: String?
    let billingFirstname: String?
    let billingLastname: String?
    let billingStreet: String?
    let billingTown: String?
    let billingCounty: String?
    let billingCountryiso2a: String?
    let billingPostcode: String?
    let billingEmail: String?
    let billingPremise: String?
    let baseAmount: Int?
    let mainAmount: Double?
    let siteReference: String?
    let fraudControlTransactionId: String?
    let currencyIso3a: String?
    let customerFirstname: String?
    let customerLastname: String?
    let customerEmail: String?
    let customerPremise: String?
    let customerTown: String?
    let customerStreet: String?
    let customerPostcode: String?
    let customerCounty: String?
    let customerCountryiso2a: String?
    let returnUrl: String?
    
    // MARK: Initialization
    
    /// - SeeAlso: Swift.Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let payload = try container.decode(JWTMerchantBodyPayload.self, forKey: .payload)
        typeDescriptions = payload.typeDescriptions
        termUrl = payload.termUrl
        billingFirstname = payload.billingFirstname
        billingLastname = payload.billingLastname
        billingStreet = payload.billingStreet
        billingTown = payload.billingTown
        billingCounty = payload.billingCounty
        billingCountryiso2a = payload.billingCountryiso2a
        billingPostcode = payload.billingPostcode
        billingEmail = payload.billingEmail
        billingPremise = payload.billingPremise
        baseAmount = payload.baseAmount
        mainAmount = payload.mainAmount
        siteReference = payload.siteReference
        fraudControlTransactionId = payload.fraudControlTransactionId
        currencyIso3a = payload.currencyIso3a
        customerFirstname = payload.customerFirstname
        customerLastname = payload.customerLastname
        customerEmail = payload.customerEmail
        customerPremise = payload.customerPremise
        customerTown = payload.customerTown
        customerStreet = payload.customerStreet
        customerPostcode = payload.customerPostcode
        customerCounty = payload.customerCounty
        customerCountryiso2a = payload.customerCountryiso2a
        returnUrl = payload.returnUrl
    }
}

private extension JWTMerchantBodyResponse {
    enum CodingKeys: String, CodingKey {
        case payload
    }
}
