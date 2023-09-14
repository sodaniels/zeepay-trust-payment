//
//  TPClaims.swift
//  Example
//
 
import Foundation
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
         deliveryData: DeliveryData? = nil) {
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
