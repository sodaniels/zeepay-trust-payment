//
//  TestApplePayRequest.swift
//  TrustPaymentsCoreTests
//

import Foundation

@testable import TrustPaymentsCore
import XCTest

class TestApplePayRequest: XCTestCase {
    // swiftlint:disable line_length
    private let validJWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqd3QtcGdzbW9iaWxlc2RrIiwiaWF0IjoxNjM0MjA2NDY1LjkxMzk0LCJwYXlsb2FkIjp7ImxvY2FsZSI6ImVuX0dCIiwicmVxdWVzdHR5cGVkZXNjcmlwdGlvbnMiOlsiQVVUSCJdLCJiYXNlYW1vdW50IjoxMTAwLCJzaXRlcmVmZXJlbmNlIjoidGVzdF9wZ3Ntb2JpbGVzZGs3OTQ1OCIsImFjY291bnR0eXBlZGVzY3JpcHRpb24iOiJFQ09NIiwiY3VycmVuY3lpc28zYSI6IkdCUCIsInRlcm11cmwiOiJodHRwczpcL1wvcGF5bWVudHMuc2VjdXJldHJhZGluZy5uZXRcL3Byb2Nlc3NcL3BheW1lbnRzXC9tb2JpbGVzZGtsaXN0ZW5lciJ9fQ.24dQFkTwov3deonewrEmVI3EXBQrywKuhXdoTa_w0DU"
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
    
    private let validJWTManualFraudControl = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqd3QtcGdzbW9iaWxlc2RrIiwiaWF0IjoxNjM0MjA2NDY1LjkxMzk0LCJwYXlsb2FkIjp7ImxvY2FsZSI6ImVuX0dCIiwicmVxdWVzdHR5cGVkZXNjcmlwdGlvbnMiOlsiQVVUSCJdLCJiYXNlYW1vdW50IjoxMTAwLCJzaXRlcmVmZXJlbmNlIjoidGVzdF9wZ3Ntb2JpbGVzZGs3OTQ1OCIsImFjY291bnR0eXBlZGVzY3JpcHRpb24iOiJFQ09NIiwiY3VycmVuY3lpc28zYSI6IkdCUCIsImZyYXVkY29udHJvbHRyYW5zYWN0aW9uaWQiOiJtYW51YWxGcmF1ZENvbnRyb2wiLCJ0ZXJtdXJsIjoiaHR0cHM6XC9cL3BheW1lbnRzLnNlY3VyZXRyYWRpbmcubmV0XC9wcm9jZXNzXC9wYXltZW50c1wvbW9iaWxlc2RrbGlzdGVuZXIifX0.24dQFkTwov3deonewrEmVI3EXBQrywKuhXdoTa_w0DU"
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
    //        "fraudcontroltransactionid": "manualFraudControl"
    //      }
    
    //    }
    
    override func setUp() {
        TrustPayments.instance.configure(username: "", gateway: .eu, environment: .staging, translationsForOverride: nil)
    }
    
    func test_applePayRequest() throws {
        let expectation = XCTestExpectation(description: "Expecting wallettoken and walletsource parameters in request.")
        let expectedWalletToken = "wallet token - string representation of PKPayment object provided by merchant after Apple Pay authorization."
        let expectedWalletSource = "APPLEPAY"
        
        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        apiClient.requestParameters = { json, _, _ in
            guard let firstRequest = (json["request"] as? [[String: String]])?.first else {
                XCTFail("Expected single request")
                return
            }
            XCTAssertEqual(firstRequest["wallettoken"], expectedWalletToken)
            XCTAssertEqual(firstRequest["walletsource"], expectedWalletSource)
            XCTAssertNotNil(firstRequest["fraudcontroltransactionid"])
            // Expected 3 fields, those above + requestId
            XCTAssertEqual(firstRequest.count, 4)
            expectation.fulfill()
        }
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        let ptm = try PaymentTransactionManager(apiManager: apiManager, jwt: nil)
        ptm.performWalletTransaction(walletSource: .applePay, walletToken: expectedWalletToken, jwt: validJWT, transactionResponseClosure: nil)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_applePayRequestFraudControlManual() throws {
        let expectation = XCTestExpectation(description: "Expecting wallettoken and walletsource parameters in request.")
        let expectedWalletToken = "wallet token - string representation of PKPayment object provided by merchant after Apple Pay authorization."
        let expectedWalletSource = "APPLEPAY"
        
        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        apiClient.requestParameters = { json, _, _ in
            guard let firstRequest = (json["request"] as? [[String: String]])?.first else {
                XCTFail("Expected single request")
                return
            }
            XCTAssertEqual(firstRequest["wallettoken"], expectedWalletToken)
            XCTAssertEqual(firstRequest["walletsource"], expectedWalletSource)
            XCTAssertNil(firstRequest["fraudcontroltransactionid"])
            // Expected 3 fields, those above + requestId
            XCTAssertEqual(firstRequest.count, 3)
            expectation.fulfill()
        }
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        let ptm = try PaymentTransactionManager(apiManager: apiManager, jwt: nil)
        ptm.performWalletTransaction(walletSource: .applePay, walletToken: expectedWalletToken, jwt: validJWTManualFraudControl, transactionResponseClosure: nil)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_applePayMissingTypeDescriptions() throws {
        let expectation = XCTestExpectation(description: "Expecting wallettoken and walletsource parameters in request.")
        let expectedWalletToken = "wallet token - string representation of PKPayment object provided by merchant after Apple Pay authorization."
        let apiClient = APIClientMock(configuration: DefaultAPIClientConfiguration(scheme: .https, host: .empty))
        let apiManager = DefaultAPIManager(username: "trust", apiClient: apiClient)
        let ptm = try PaymentTransactionManager(apiManager: apiManager, jwt: nil)
        ptm.performWalletTransaction(walletSource: .applePay, walletToken: expectedWalletToken, jwt: "") { _, _, error in
            XCTAssertNotNil(error)
            switch error {
            case let .responseValidationError(apiResp):
                switch apiResp {
                case .missingTypeDescriptions:
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
