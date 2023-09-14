//
//  TestCacheTokenise.swift
//  ExampleTests
//

@testable import Trust_Payments
import XCTest

class TestCacheTokenise: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    private func jwtTokenWithFrictionlessCardDataAndBaseAmount(typeDescriptions: [TypeDescription]) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4000000000001026",
                                              expirydate: "12/2022",
                                              cvv: "123"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    private func jwtTokenWithFrictionlessCardDataAndMainAmount(typeDescriptions: [TypeDescription], billingData: BillingData?, deliveryData: DeliveryData?) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              mainamount: 11.00,
                                              pan: "4000000000001026",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              billingData: billingData,
                                              deliveryData: deliveryData))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    private func webServicesRequestWithCacheToken(typeDescriptions: [String], token: String, useMainAmount: Bool) -> URLRequest? {
        let payload = TPJSONPayload(alias: keys.wsUsername,
                                    request: TPJSONPayloadRequest(requesttypedescriptions: typeDescriptions,
                                                                  accounttypedescription: "ECOM",
                                                                  sitereference: keys.wsSiteReference,
                                                                  currencyiso3a: "GBP",
                                                                  baseamount: useMainAmount ? nil : "1100",
                                                                  mainamount: useMainAmount ? "11.0" : nil,
                                                                  cachetoken: token))

        guard let credentials = "\(keys.wsUsername):\(keys.wsPassword)".data(using: .utf8)?.base64EncodedString(), let jsonData = try? JSONEncoder().encode(payload) else { return nil }
        var request = URLRequest(url: URL(string: "https://webservices.securetrading.net/json/")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: Setup

    override func setUp() {
        super.setUp()
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
    }

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    // MARK: Tests

    func testCacheTokenise() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardDataAndBaseAmount(typeDescriptions: [.cacheTokenise]) ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] jwts, _, error in
            guard let cacheToken = try? TPHelper.getTPResponse(jwt: jwts.first ?? .empty).customerOutput?.cacheToken else {
                XCTFail("Missing cache token on CACHETOKENISE response")
                return
            }
            XCTAssertNotNil(cacheToken)
            XCTAssertNil(error)

            // Web services request.
            // Note: This request is for example purposes only. Normally, the webservices API should be used on server side, not SDK.
            guard let webServicesRequest = webServicesRequestWithCacheToken(typeDescriptions: ["REFUND"], token: cacheToken, useMainAmount: false) else {
                XCTFail("Could not create webservices request")
                return
            }
            URLSession.shared.dataTask(with: webServicesRequest) { data, response, _ in
                guard let response = response as? HTTPURLResponse, (200 ..< 300).contains(response.statusCode) else {
                    XCTFail("Response has invalid status code")
                    return
                }
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    XCTFail("Could not parse REFUND response")
                    return
                }
                let responseItem = (json["response"] as? [[String: String]])?.first
                XCTAssertEqual(responseItem?["errorcode"], "0")
                XCTAssertEqual(responseItem?["requesttypedescription"], "REFUND")
                expectation.fulfill()
            }.resume()
        })
        wait(for: [expectation], timeout: 10)
    }

    func testCacheTokeniseWithMainAmountAndAddresses() throws {
        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        let billingData = BillingData(firstName: "Ian",
                                      lastName: "Hewertson",
                                      street: "102, Bridgwater Road",
                                      town: "Taunton",
                                      county: "Blackpool",
                                      countryIso2a: "GB",
                                      postcode: "TA2 8BE",
                                      email: "test2@test.pl",
                                      telephone: "01823 335258")
        let deliveryData = DeliveryData(customerfirstname: "Hollie",
                                        customerlastname: "Artist",
                                        customerstreet: "Merrick Cottage, 194",
                                        customercounty: "Bedford",
                                        customercountryiso2a: "GB",
                                        customerpostcode: "MK42 9YD",
                                        customeremail: "test@test.pl",
                                        customertelephone: "07810 307057")

        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtTokenWithFrictionlessCardDataAndMainAmount(typeDescriptions: [.cacheTokenise],
                                                                                                                     billingData: billingData,
                                                                                                                     deliveryData: deliveryData) ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { [unowned self] jwts, _, error in
            guard let cacheToken = try? TPHelper.getTPResponse(jwt: jwts.first ?? .empty).customerOutput?.cacheToken else {
                XCTFail("Missing cache token on CACHETOKENISE response")
                return
            }
            XCTAssertNotNil(cacheToken)
            XCTAssertNil(error)

            // Web services request.
            // Note: This request is for example purposes only. Normally, the webservices API should be used on server side, not SDK.
            guard let webServicesRequest = webServicesRequestWithCacheToken(typeDescriptions: ["REFUND"], token: cacheToken, useMainAmount: true) else {
                XCTFail("Could not create webservices request")
                return
            }
            URLSession.shared.dataTask(with: webServicesRequest) { data, response, _ in
                guard let response = response as? HTTPURLResponse, (200 ..< 300).contains(response.statusCode) else {
                    XCTFail("Response has invalid status code")
                    return
                }
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    XCTFail("Could not parse REFUND response")
                    return
                }
                let responseItem = (json["response"] as? [[String: String]])?.first
                XCTAssertEqual(responseItem?["errorcode"], "0")
                XCTAssertEqual(responseItem?["requesttypedescription"], "REFUND")
                expectation.fulfill()
            }.resume()
        })
        wait(for: [expectation], timeout: 10)
    }
}
