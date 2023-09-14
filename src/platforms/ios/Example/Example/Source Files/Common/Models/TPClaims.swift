//
//  TPClaims.swift
//  Example
//

import SwiftJWT

struct BillingData {
    let billingprefixname: String?
    let billingfirstname: String?
    let billingmiddlename: String?
    let billinglastname: String?
    let billingsuffixname: String?
    let billingstreet: String?
    let billingtown: String?
    let billingcounty: String?
    let billingcountryiso2a: String?
    let billingpostcode: String?
    let billingemail: String?
    let billingtelephone: String?
    let billingpremise: String?

    init(prefixName: String? = nil,
         firstName: String? = nil,
         middleName: String? = nil,
         lastName: String? = nil,
         suffixName: String? = nil,
         street: String? = nil,
         town: String? = nil,
         county: String? = nil,
         countryIso2a: String? = nil,
         postcode: String? = nil,
         email: String? = nil,
         telephone: String? = nil,
         premise: String? = nil) {
        billingprefixname = prefixName
        billingfirstname = firstName
        billingmiddlename = middleName
        billinglastname = lastName
        billingsuffixname = suffixName
        billingstreet = street
        billingtown = town
        billingcounty = county
        billingcountryiso2a = countryIso2a
        billingpostcode = postcode
        billingemail = email
        billingtelephone = telephone
        billingpremise = premise
    }
}

struct DeliveryData {
    let customerprefixname: String?
    let customerfirstname: String?
    let customermiddlename: String?
    let customerlastname: String?
    let customersuffixname: String?
    let customerstreet: String?
    let customertown: String?
    let customercounty: String?
    let customercountryiso2a: String?
    let customerpostcode: String?
    let customeremail: String?
    let customertelephone: String?
    let customerpremise: String?

    init(customerprefixname: String? = nil,
         customerfirstname: String? = nil,
         customermiddlename: String? = nil,
         customerlastname: String? = nil,
         customersuffixname: String? = nil,
         customerstreet: String? = nil,
         customertown: String? = nil,
         customercounty: String? = nil,
         customercountryiso2a: String? = nil,
         customerpostcode: String? = nil,
         customeremail: String? = nil,
         customertelephone: String? = nil,
         customerpremise: String? = nil) {
        self.customerprefixname = customerprefixname
        self.customerfirstname = customerfirstname
        self.customermiddlename = customermiddlename
        self.customerlastname = customerlastname
        self.customersuffixname = customersuffixname
        self.customerstreet = customerstreet
        self.customertown = customertown
        self.customercounty = customercounty
        self.customercountryiso2a = customercountryiso2a
        self.customerpostcode = customerpostcode
        self.customeremail = customeremail
        self.customertelephone = customertelephone
        self.customerpremise = customerpremise
    }
}

struct TPResponseClaims: Claims {
    let iat: Date
    let payload: ResponsePayload
}

struct ResponsePayload: Claims {
    let requestreference: String
    let version: String
    let response: [ResponseObject]
    let jwt: String?
}

struct ResponseObject: Claims {
    let requesttypedescription: String
    let errorcode: String

    // threeDQuery / Cardinal
    let xid: String?
    let status: String? // pares
    let eci: String?
    let cavv: String?
    let enrolled: String?
    let threedversion: String?
}

struct TPClaims: Claims {
    let iss: String
    let iat: Date // no later than 60mins from now
    let payload: Payload
}

struct Payload: Codable {
    let requesttypedescriptions: [String]
    let threedbypasspaymenttypes: [String]?
    let termurl: String
    let locale: String?
    let accounttypedescription: String
    let sitereference: String
    let currencyiso3a: String?
    let baseamount: Int?
    let mainamount: Double?
    let pan: String?
    let expirydate: String?
    let securitycode: String?
    let parenttransactionreference: String?
    let cachetoken: String?
    let subscriptiontype: String?
    let subscriptionfinalnumber: String?
    let subscriptionunit: String?
    let subscriptionfrequency: String?
    let subscriptionnumber: String?
    let credentialsonfile: String?
    let threedresponse: String?
    let pares: String?
    // billing data
    let billingprefixname: String?
    let billingfirstname: String?
    let billingmiddlename: String?
    let billinglastname: String?
    let billingsuffixname: String?
    let billingstreet: String?
    let billingtown: String?
    let billingcounty: String?
    let billingcountryiso2a: String?
    let billingpostcode: String?
    let billingemail: String?
    let billingtelephone: String?
    let billingpremise: String?
    // delivery data
    let customerprefixname: String?
    let customerfirstname: String?
    let customermiddlename: String?
    let customerlastname: String?
    let customersuffixname: String?
    let customerstreet: String?
    let customertown: String?
    let customercounty: String?
    let customercountryiso2a: String?
    let customerpostcode: String?
    let customeremail: String?
    let customertelephone: String?
    let customerpremise: String?
    // APM
    let returnurl: String

    init(requesttypedescriptions: [String],
         threedbypasspaymenttypes: [String]? = nil,
         termurl: String = "https://payments.securetrading.net/process/payments/mobilesdklistener",
         locale: String? = nil,
         accounttypedescription: String,
         sitereference: String,
         currencyiso3a: String? = nil,
         baseamount: Int? = nil,
         mainamount: Double? = nil,
         pan: String? = nil,
         expirydate: String? = nil,
         cvv: String? = nil,
         parenttransactionreference: String? = nil,
         cachetoken: String? = nil,
         subscriptiontype: String? = nil,
         subscriptionfinalnumber: String? = nil,
         subscriptionunit: String? = nil,
         subscriptionfrequency: String? = nil,
         subscriptionnumber: String? = nil,
         credentialsonfile: String? = nil,
         threedresponse: String? = nil,
         pares: String? = nil,
         billingData: BillingData? = nil,
         deliveryData: DeliveryData? = nil,
         returnUrl: String = "https://mobile-app-specific.url") {
        self.requesttypedescriptions = requesttypedescriptions
        self.threedbypasspaymenttypes = threedbypasspaymenttypes
        self.termurl = termurl
        self.locale = locale
        self.accounttypedescription = accounttypedescription
        self.sitereference = sitereference
        self.currencyiso3a = currencyiso3a
        self.baseamount = baseamount
        self.mainamount = mainamount
        self.pan = pan
        self.expirydate = expirydate
        securitycode = cvv
        self.parenttransactionreference = parenttransactionreference
        self.cachetoken = cachetoken
        self.subscriptiontype = subscriptiontype
        self.subscriptionfinalnumber = subscriptionfinalnumber
        self.subscriptionunit = subscriptionunit
        self.subscriptionfrequency = subscriptionfrequency
        self.subscriptionnumber = subscriptionnumber
        self.credentialsonfile = credentialsonfile
        self.threedresponse = threedresponse
        self.pares = pares
        billingprefixname = billingData?.billingprefixname
        billingfirstname = billingData?.billingfirstname
        billingmiddlename = billingData?.billingmiddlename
        billinglastname = billingData?.billinglastname
        billingsuffixname = billingData?.billingsuffixname
        billingstreet = billingData?.billingstreet
        billingtown = billingData?.billingtown
        billingcounty = billingData?.billingcounty
        billingcountryiso2a = billingData?.billingcountryiso2a
        billingpostcode = billingData?.billingpostcode
        billingemail = billingData?.billingemail
        billingtelephone = billingData?.billingtelephone
        billingpremise = billingData?.billingpremise
        customerprefixname = deliveryData?.customerprefixname
        customerfirstname = deliveryData?.customerfirstname
        customermiddlename = deliveryData?.customermiddlename
        customerlastname = deliveryData?.customerlastname
        customersuffixname = deliveryData?.customersuffixname
        customerstreet = deliveryData?.customerstreet
        customertown = deliveryData?.customertown
        customercounty = deliveryData?.customercounty
        customercountryiso2a = deliveryData?.customercountryiso2a
        customerpostcode = deliveryData?.customerpostcode
        customeremail = deliveryData?.customeremail
        customertelephone = deliveryData?.customertelephone
        customerpremise = deliveryData?.customerpremise
        returnurl = returnUrl
    }
}

extension String {
    private func base64UrlDecode(_ value: String) -> Data? {
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

    private var payload: Payload? {
        let body = components(separatedBy: ".")[1]
        guard let decoded = base64UrlDecode(body) else { return nil }
        guard let payload = try? JSONDecoder().decode(TPClaims.self, from: decoded).payload else { return nil }
        return payload
    }

    var parentReference: String? {
        payload?.parenttransactionreference
    }

    var requesttypedescriptions: [String]? {
        payload?.requesttypedescriptions
    }
}

// MARK: Web services

struct TPJSONPayload: Encodable {
    let alias: String
    let version: String = "1.00"
    let request: TPJSONPayloadRequest
}

struct TPJSONPayloadRequest: Encodable {
    let requesttypedescriptions: [String]
    let accounttypedescription: String
    let sitereference: String
    let currencyiso3a: String
    let baseamount: String?
    let mainamount: String?
    let cachetoken: String
}
