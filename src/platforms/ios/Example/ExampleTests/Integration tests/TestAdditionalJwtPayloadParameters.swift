//
//  TestAdditionalJwtPayloadParameters.swift
//  ExampleTests
//

@testable import Trust_Payments
import XCTest

class TestAdditionalJwtPayloadParameters: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

    // MARK: Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        TrustPayments.instance.configure(username: keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride: nil)
        paymentTransactionManager = try PaymentTransactionManager(jwt: nil)
    }

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_JWTAdditionalPayloadParameters() throws {
        // swiftlint:disable line_length
        let billingData = BillingData(firstName: "Ian",
                                      lastName: "Hewertson",
                                      street: "102, Bridgwater Road",
                                      town: "Taunton",
                                      county: "Blackpool",
                                      countryIso2a: "GB",
                                      postcode: "TA2 8BE",
                                      email: "test2@test.pl",
                                      telephone: "01823 335258")

        let deliveryData = DeliveryData(customerprefixname: nil, customerfirstname: "Hollie", customermiddlename: nil, customerlastname: "Artist", customersuffixname: nil, customerstreet: "Merrick Cottage, 194", customertown: nil, customercounty: "Bedford", customercountryiso2a: "GB", customerpostcode: "MK42 9YD", customeremail: "test@test.pl", customertelephone: "07810 307057")
        // swiftlint:enable line_length

        let typeDescriptions = [TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              pan: "4000000000001026",
                                              expirydate: "12/2022",
                                              cvv: "123",
                                              billingData: billingData,
                                              deliveryData: deliveryData))

        let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey)

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")

        paymentTransactionManager.performTransaction(jwt: jwt, card: nil, transactionResponseClosure: { [unowned self] jwtForVerification, _, _ in
            XCTAssertNotNil(jwtForVerification.first)
            let tpResponseClaims = try? JWTHelper.getTPResponseClaims(jwt: jwtForVerification.first ?? .empty, secret: self.keys.jwtSecretKey)
            let responseJwt = tpResponseClaims?.payload.jwt ?? .empty
            let tpClaims = try? JWTHelper.getTPClaims(jwt: responseJwt, secret: self.keys.jwtSecretKey)
            let tpClaimsPayload = tpClaims?.payload
            /*
                 XCTAssertEqual(billingData.billingfirstname, tpClaimsPayload?.billingfirstname)
                 XCTAssertEqual(deliveryData.customerfirstname, tpClaimsPayload?.customerfirstname)
                 XCTAssertEqual(billingData.billinglastname, tpClaimsPayload?.billinglastname)
                 XCTAssertEqual(deliveryData.customerlastname, tpClaimsPayload?.customerlastname)
                 XCTAssertEqual(billingData.billingstreet, tpClaimsPayload?.billingstreet)
                 XCTAssertEqual(deliveryData.customerstreet, tpClaimsPayload?.customerstreet)
                 XCTAssertEqual(billingData.billingtown, tpClaimsPayload?.billingtown)
                 XCTAssertEqual(deliveryData.customertown, tpClaimsPayload?.customertown)
                 XCTAssertEqual(billingData.billingcountryiso2a, tpClaimsPayload?.billingcountryiso2a)
                 XCTAssertEqual(deliveryData.customercountryiso2a, tpClaimsPayload?.customercountryiso2a)
                 XCTAssertEqual(billingData.billingcounty, tpClaimsPayload?.billingcounty)
                 XCTAssertEqual(deliveryData.customercounty, tpClaimsPayload?.customercounty)
                 XCTAssertEqual(billingData.billingpostcode, tpClaimsPayload?.billingpostcode)
                 XCTAssertEqual(deliveryData.customerpostcode, tpClaimsPayload?.customerpostcode)
                 XCTAssertEqual(billingData.billingemail, tpClaimsPayload?.billingemail)
                 XCTAssertEqual(deliveryData.customeremail, tpClaimsPayload?.customeremail)
                 XCTAssertEqual(billingData.billingtelephone, tpClaimsPayload?.billingtelephone)
                 XCTAssertEqual(deliveryData.customertelephone, tpClaimsPayload?.customertelephone)
             */
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 4)
    }
}
