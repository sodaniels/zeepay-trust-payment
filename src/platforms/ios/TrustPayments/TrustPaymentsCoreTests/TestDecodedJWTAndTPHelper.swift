//
//  TestDecodedJWT.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestDecodedJWTAndTPHelper: XCTestCase {
    // MARK: Test Decoded JWT
    
    func test_throwsForEmptyJWT() {
        let jwt = ""
        let expectedError = APIClientError.jwtDecodingInvalidPartCount
        XCTAssertThrowsError(try DecodedJWT(jwt: jwt)) { error in
            let receivedError = (error as? APIClientError)?.humanReadableDescription
            XCTAssertEqual(expectedError.humanReadableDescription, receivedError)
        }
    }
    
    func test_throwsForTooManyJWTComponent() {
        let jwt = "aa.bb.cc.dd"
        let expectedError = APIClientError.jwtDecodingInvalidPartCount
        XCTAssertThrowsError(try DecodedJWT(jwt: jwt)) { error in
            let receivedError = (error as? APIClientError)?.humanReadableDescription
            XCTAssertEqual(expectedError.humanReadableDescription, receivedError)
        }
    }
    
    func test_throwsForInvalidResponseBody() {
        let jwt = [
            headerJSON.data.base64URLEncoded,
            headerJSON.data.base64URLEncoded,
            signature
        ].joined(separator: ".")
        XCTAssertThrowsError(try DecodedJWT(jwt: jwt))
    }
    
    func test_DoesntThrowForValidResponseBody() {
        XCTAssertNoThrow(try DecodedJWT(jwt: getJWT()))
    }
    
    func test_responseHasAudience() {
        XCTAssertNotNil(try DecodedJWT(jwt: getJWT()).audience)
    }
    
    func test_responseHasIssuedAt() {
        XCTAssertNotNil(try DecodedJWT(jwt: getJWT()).issuedAt)
    }
    
    func test_responseHasTransactionReference() throws {
        let responses = try DecodedJWT(jwt: getJWT()).jwtBodyResponse.responses
        for response in responses {
            XCTAssertNotNil(response.transactionReference)
        }
    }
    
    func test_responseHasErrorCodeZeroForSuccess() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "0"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.successful)
        }
    }
    
    func test_responseHasErrorCode70_000DeclinedByBank() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "70000"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.declinedByIssuingBank)
        }
    }
    
    func test_responseHasErrorCode60_022Unauthorized() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "60022"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.transactionNotAuhorised)
        }
    }
    
    func test_responseHasErrorCode30000FieldError() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "30000"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.fieldError)
        }
    }
    
    func test_responseHasErrorCode60034ManualInvestigationError() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "60034"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.manualInvestigationRequired)
        }
    }
    
    func test_responseHasErrorCodeMinus2Unknown() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "-2"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.unknown)
        }
    }
    
    func test_responseHasErrorCodeMissingUnknown() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": ""])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseErrorCode, ResponseErrorCode.unknown)
        }
    }
    
    func test_responseHasSettleCode0AutoPending() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "0"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.pendingAutomaticSettlement)
        }
    }
    
    func test_responseHasSettleCode1ManualPending() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "1"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.pendingManualSettlement)
        }
    }
    
    func test_responseHasSettleCode2Suspended() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "2"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.paymentAuthorisedButSuspended)
        }
    }
    
    func test_responseHasSettleCode3Cancelled() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "3"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.paymentCancelled)
        }
    }
    
    func test_responseHasSettleCode10InPogress() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "10"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.settlementInProgress)
        }
    }
    
    func test_responseHasSettleCode100InstantSettlement() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "100"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.instantSettlement)
        }
    }
    
    func test_responseHasSettleCodeMinus1ErrorUnhandled() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": "-1"])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.error)
        }
    }
    
    func test_responseHasSettleCodeMinus1Empty() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["settlestatus": ""])
        let jwt = getJWT(withBody: body)
        let responses = try DecodedJWT(jwt: jwt).jwtBodyResponse.responses
        for response in responses {
            XCTAssertEqual(response.responseSettleStatus, ResponseSettleStatus.error)
        }
    }
    
    func test_bodyHasIssuer() throws {
        let expected = "Secure Trading"
        let body = modify(newBodyFields: ["iss": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.issuer, expected)
    }
    
    func test_bodyHasSubject() throws {
        let expected = "Secure Trading"
        let body = modify(newBodyFields: ["sub": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.subject, expected)
    }
    
    func test_bodyHasIdentifier() throws {
        let expected = "Secure Trading"
        let body = modify(newBodyFields: ["jti": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.identifier, expected)
    }
    
    func test_bodyHasNotBeforeDate() throws {
        let expected = Date().addingTimeInterval(1).timeIntervalSince1970
        let body = modify(newBodyFields: ["nbf": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.notBefore, Date(timeIntervalSince1970: expected))
    }
    
    func test_bodyHasExpirationDate() throws {
        let expected = Date().addingTimeInterval(1).timeIntervalSince1970
        let body = modify(newBodyFields: ["exp": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.expiresAt, Date(timeIntervalSince1970: expected))
    }
    
    func test_bodyExpirationDateValidForEmpty() throws {
        let body = modify(newBodyFields: [:], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertFalse(decodedJWT.expired)
    }
    
    func test_bodyExpirationDateInPastIsExpired() throws {
        let expected = Date().addingTimeInterval(-1).timeIntervalSince1970
        let body = modify(newBodyFields: ["exp": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertTrue(decodedJWT.expired)
    }
    
    func test_claimCanReadInt() throws {
        let expected = 10
        let body = modify(newBodyFields: ["int": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.claim(name: "int").integer, expected)
    }
    
    func test_claimCanReadIntFromString() throws {
        let expected = 10
        let body = modify(newBodyFields: ["int": "\(expected)"], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.claim(name: "int").integer, expected)
    }
    
    func test_bodyHasFraudControlTransactionId() throws {
        let expected = "manualFraudControl"
        let body = modify(newBodyFields: ["fraudControlTransactionId": expected], newResponseFields: [:])
        let jwt = getJWT(withBody: body)
        let decodedJWT = try DecodedJWT(jwt: jwt)
        XCTAssertEqual(decodedJWT.claim(name: "fraudControlTransactionId").string, expected)
    }
    
    func test_tpHelperNoError() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "0"])
        let jwt = getJWT(withBody: body)
        let tpResponse = try TPHelper.getTPResponse(jwt: jwt)
        let tpResponses = try TPHelper.getTPResponses(jwt: [jwt])
        XCTAssertEqual(tpResponses.count, 1)
        let firstTPError = tpResponse.tpError
        let cardReference = tpResponse.cardReference
        let customerOutput = tpResponse.customerOutput
        let responses = tpResponse.responseObjects
        XCTAssertNil(firstTPError)
        XCTAssertNotNil(cardReference)
        XCTAssertNotNil(customerOutput)
        XCTAssertFalse(responses.isEmpty)
        XCTAssertEqual(customerOutput?.errorMessage, "Ok")
        XCTAssertEqual(cardReference?.maskedPan, "411111######1111")
        XCTAssertEqual(cardReference?.transactionReference, "57-9-18087")
    }
    
    func test_tpHelperWithError() throws {
        let body = modify(newBodyFields: [:], newResponseFields: ["errorcode": "30000"])
        let jwt = getJWT(withBody: body)
        let tpResponse = try TPHelper.getTPResponse(jwt: jwt)
        let firstTPError = tpResponse.tpError
        let cardReference = tpResponse.cardReference
        let customerOutput = tpResponse.customerOutput
        let responses = tpResponse.responseObjects
        XCTAssertNotNil(firstTPError)
        XCTAssertNotNil(cardReference)
        XCTAssertNotNil(customerOutput)
        XCTAssertFalse(responses.isEmpty)
        XCTAssertEqual(customerOutput?.errorMessage, "Ok")
        XCTAssertEqual(cardReference?.maskedPan, "411111######1111")
        XCTAssertEqual(cardReference?.transactionReference, "57-9-18087")
        XCTAssertEqual(firstTPError?.foundationError.code, 12_500)
    }
    
    func test_claim() throws {
        let dict: [[String: Any]] = [["Foo": 0], ["Woo": 1]]
        var claim = Claim(value: dict)
        XCTAssertEqual(claim.arrayOfObjects?.count, 2)
        
        XCTAssertNotNil(claim.rawValue)
        
        claim = Claim(value: "1657545189")
        XCTAssertNotNil(claim.string)
        XCTAssertNotNil(claim.integer)
        XCTAssertNotNil(claim.double)
        
        claim = Claim(value: Double(0.1))
        XCTAssertNotNil(claim.integer)
        
        claim = Claim(value: ["c", "b"])
        XCTAssertNotNil(claim.array)
        XCTAssertNil(claim.arrayOfObjects)
        
        claim = Claim(value: nil)
        XCTAssertNil(claim.arrayOfObjects)
        XCTAssertNil(claim.array)
        XCTAssertNil(claim.integer)
        XCTAssertNil(claim.double)
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.date)
    }
}

// MARK: Helper methods

func getJWT(withBody body: [String: Any]? = nil) -> String {
    if let body = body {
        return [
            headerJSON.data.base64URLEncoded,
            body.data.base64URLEncoded,
            signature
        ].joined(separator: ".")
    } else {
        return [
            headerJSON.data.base64URLEncoded,
            modify(newBodyFields: [:], newResponseFields: [:]).data.base64URLEncoded,
            signature
        ].joined(separator: ".")
    }
}

func modify(newBodyFields: [String: Any], newResponseFields: [String: Any]) -> [String: Any] {
    var response = baseResponseJSON
    for field in newResponseFields {
        response[field.key] = field.value
    }
    var baseResponse = baseResponseBodyJSON
    for field in newBodyFields {
        baseResponse[field.key] = field.value
    }
    baseResponse["payload"] = ["response": [response], "jwt": ""]
    return baseResponse
}

private var headerJSON: [String: String] {
    [
        "alg": "HS256",
        "typ": "JWT"
    ]
}

private var baseResponseBodyJSON: [String: Any] {
    [
        "aud": "jwt",
        "iat": 1_590_582_142,
        "payload":
            [
                "response": [baseResponseJSON],
                "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJqd3QiLCJpYXQiOjE1OTQyODU0MzMsInBheWxvYWQiOnsiYmFzZWFtb3VudCI6MTA1MCwiY3VycmVuY3lpc28zYSI6IkdCUCIsInNpdGVyZWZlcmVuY2UiOiJ0ZXN0IiwiYWNjb3VudHR5cGVkZXNjcmlwdGlvbiI6IkVDT00ifX0.9t7Hq_aKbywIj1yuv8cuFpzXa2MPlNh8f2rH4DRPnYg"
            ]
    ]
}

private var baseResponseJSON: [String: Any] {
    [
        "transactionstartedtimestamp": "2020-05-27 12:22:22",
        "livestatus": "0",
        "issuer": "TrustPayments Test Issuer1",
        "splitfinalnumber": "1",
        "dccenabled": "0",
        "settleduedate": "2020-05-27",
        "errorcode": "0",
        "tid": "27882788",
        "merchantnumber": "00000000",
        "securityresponsepostcode": "0",
        "transactionreference": "57-9-18087",
        "merchantname": "pgs mobile sdk",
        "paymenttypedescription": "VISA",
        "baseamount": "1050",
        "accounttypedescription": "ECOM",
        "acquirerresponsecode": "00",
        "requesttypedescription": "AUTH",
        "securityresponsesecuritycode": "2",
        "currencyiso3a": "GBP",
        "authcode": "TEST95",
        "errormessage": "Ok",
        "issuercountryiso2a": "US",
        "merchantcountryiso2a": "GB",
        "maskedpan": "411111######1111",
        "securityresponseaddress": "0",
        "operatorname": "jwt-pgsmobilesdk",
        "settlestatus": "0",
        "cachetoken": "",
        "threedinit": ""
    ]
}

private var signature: String {
    "signature"
}

private extension Dictionary where Key == String, Value: Any {
    var data: Data {
        // swiftlint:disable force_try
        try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
}

private extension Data {
    var base64URLEncoded: String {
        let result = base64EncodedString()
        return result.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
