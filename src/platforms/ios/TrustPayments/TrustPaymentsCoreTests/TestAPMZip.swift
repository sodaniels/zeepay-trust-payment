//
//  TestAPMZip.swift
//  TrustPaymentsCoreTests
//

import Foundation

@testable import TrustPaymentsCore
import XCTest

class TestAPMZip: XCTestCase {
    // swiftlint:disable line_length
    private let validJWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqd3QtcGdzbW9iaWxlc2RrIiwiaWF0IjoxNjM0MjA2NDY1LjkxMzk0LCJwYXlsb2FkIjp7ImxvY2FsZSI6ImVuX0dCIiwicmVxdWVzdHR5cGVkZXNjcmlwdGlvbnMiOlsiQVVUSCJdLCJiYXNlYW1vdW50IjoxMTAwLCJzaXRlcmVmZXJlbmNlIjoidGVzdF9wZ3Ntb2JpbGVzZGs3OTQ1OCIsImFjY291bnR0eXBlZGVzY3JpcHRpb24iOiJFQ09NIiwiY3VycmVuY3lpc28zYSI6IkdCUCIsInRlcm11cmwiOiJodHRwczovL3BheW1lbnRzLnNlY3VyZXRyYWRpbmcubmV0L3Byb2Nlc3MvcGF5bWVudHMvbW9iaWxlc2RrbGlzdGVuZXIiLCJyZXR1cm51cmwiOiJodHRwczovL21vYmlsZS1hcHAtc3BlY2lmaWMudXJsIn19.SkpCUSlzPJmAaY6S_p1a4lLKMWrLS0XGbUjtcJ1AhZU"
//    Payload
//    {
//      "iss": "",
//      "iat": 1634206465.91394,
//      "payload": {
//        "locale": "en_GB",
//        "requesttypedescriptions": [
//          "AUTH"
//        ],
//        "baseamount": 1100,
//        "sitereference": "",
//        "accounttypedescription": "ECOM",
//        "currencyiso3a": "GBP",
//        "termurl": "https://payments.securetrading.net/process/payments/mobilesdklistener",
//        "returnurl": "https://mobile-app-specific.url"
//      }
//    }
    
    private let invalidJWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqd3QtcGdzbW9iaWxlc2RrIiwiaWF0IjoxNjM0MjA2NDY1LjkxMzk0LCJwYXlsb2FkIjp7ImxvY2FsZSI6ImVuX0dCIiwicmVxdWVzdHR5cGVkZXNjcmlwdGlvbnMiOlsiQVVUSCJdLCJiYXNlYW1vdW50IjoxMTAwLCJzaXRlcmVmZXJlbmNlIjoidGVzdF9wZ3Ntb2JpbGVzZGs3OTQ1OCIsImFjY291bnR0eXBlZGVzY3JpcHRpb24iOiJFQ09NIiwiY3VycmVuY3lpc28zYSI6IkdCUCIsInRlcm11cmwiOiJodHRwczovL3BheW1lbnRzLnNlY3VyZXRyYWRpbmcubmV0L3Byb2Nlc3MvcGF5bWVudHMvbW9iaWxlc2RrbGlzdGVuZXIifX0.ErAkU9tlNY8f2tZ_oAEAJq-qxRPRkW1T2Sxr0R0shQI"
//    Payload
//    {
//      "iss": "",
//      "iat": 1634206465.91394,
//      "payload": {
//        "locale": "en_GB",
//        "requesttypedescriptions": [
//          "AUTH"
//        ],
//        "baseamount": 1100,
//        "sitereference": "",
//        "accounttypedescription": "ECOM",
//        "currencyiso3a": "GBP",
//        "termurl": "https://payments.securetrading.net/process/payments/mobilesdklistener"
//      }
//    }

    override func setUp() {
        TrustPayments.instance.configure(username: "", gateway: .eu, environment: .staging, translationsForOverride: nil)
    }

    func test_returnsErrorForInvalidJWTAtInit() throws {
        let jwt = "jwtInit"
        let ptm = try PaymentTransactionManager(jwt: jwt)
        ptm.performAPMTransaction(jwt: nil, apm: .zip) { _, _, error in
            XCTAssertEqual(error?.errorCode, APIClientError.responseValidationError(.missingTypeDescriptions).errorCode)
        }
    }

    func test_returnsErrorForInvalidJWTAtPerform() throws {
        let jwt = "jwtPerform"
        let ptm = try PaymentTransactionManager(jwt: nil)
        ptm.performAPMTransaction(jwt: jwt, apm: .zip) { _, _, error in
            XCTAssertEqual(error?.errorCode, APIClientError.responseValidationError(.missingTypeDescriptions).errorCode)
        }
    }

    func test_useJWTFromInit() throws {
        let expectation = XCTestExpectation()

        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        apiClient.requestParameters = { json, _, _ in
            guard let firstRequest = (json["request"] as? [[String: String]])?.first else {
                XCTFail("Expected single request")
                return
            }
            XCTAssertEqual(firstRequest["paymenttypedescription"], "ZIP")
            XCTAssertNil(firstRequest["returnurl"]) // Should be inside JWT
            // Expected 2 fields, paymenttypedescription + requestId
            XCTAssertEqual(firstRequest.count, 2)
            expectation.fulfill()
        }
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        let ptm = try PaymentTransactionManager(apiManager: apiManager, jwt: validJWT)
        ptm.performAPMTransaction(jwt: nil, apm: .zip) { _, _, _ in }
        wait(for: [expectation], timeout: 1)
    }

    func test_useJWTFromPerform() throws {
        let expectation = XCTestExpectation()

        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        apiClient.requestParameters = { json, _, _ in
            guard let firstRequest = (json["request"] as? [[String: String]])?.first else {
                XCTFail("Expected single request")
                return
            }
            XCTAssertEqual(firstRequest["paymenttypedescription"], "ZIP")
            XCTAssertNil(firstRequest["returnurl"]) // Should be inside JWT
            // Expected 2 fields, paymenttypedescription + requestId
            XCTAssertEqual(firstRequest.count, 2)
            expectation.fulfill()
        }
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        let ptm = try PaymentTransactionManager(apiManager: apiManager, jwt: nil)
        ptm.performAPMTransaction(jwt: validJWT, apm: .zip) { _, _, _ in }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_useInvalidJWTFromPerform() throws {
        let expectation = XCTestExpectation()
        
        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        let ptm = try PaymentTransactionManager(apiManager: apiManager, jwt: nil)
        ptm.performAPMTransaction(jwt: invalidJWT, apm: .zip) { _, _, error in
            XCTAssertNotNil(error)
            switch error {
            case let .responseValidationError(apiResp):
                switch apiResp {
                case .missingReturnUrl:
                    expectation.fulfill()
                default:
                    assertionFailure("Invalid error type")
                }
            default:
                assertionFailure("Invalid error type")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}
