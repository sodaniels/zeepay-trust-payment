//
//  TestZIPFlow.swift
//  ExampleTests
//

@testable import Trust_Payments
@testable import TrustPaymentsCore
import TrustPaymentsUI
import XCTest

class TestZIPFlow: KIFTestCase {
    
    func testErrorForCancel() throws {
        let expectation = XCTestExpectation(description: "APM web view")
        let jwt = mockedZIPResponse()
        let data = try JSONSerialization.data(withJSONObject: ["jwt": jwt], options: JSONSerialization.WritingOptions(rawValue: 0))
        let response = try JSONDecoder().decode(GeneralResponse.self, from: data)

        let apiManagerMock = APIManagerMock()
        apiManagerMock.successBlock = {
            response
        }

        let paymentManager = try PaymentTransactionManager(apiManager: apiManagerMock, jwt: validJWT)
        paymentManager.performAPMTransaction(jwt: nil, apm: .zip) { _, _, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(interval: 6, completion: { [unowned self] in
            // Tap cancel button for now
            self.tester().tapView(withAccessibilityLabel: "Cancel")
        })
        wait(for: [expectation], timeout: 20)
    }

    func testZipButtonVisibleForValidRequestTypes() throws {
        let validRequestTypes: [[TypeDescription]] = [
            [.auth],
            [.threeDQuery, .auth],
            [.threeDQuery, .auth, .riskDec]
        ]
        let invalidRequestTypes: [[TypeDescription]] = [
            [.accountCheck],
            [.threeDQuery],
            [.subscription],
            [.threeDQuery, .accountCheck],
            [.threeDQuery, .accountCheck, .subscription],
            [.threeDQuery, .accountCheck, .auth],
            [.threeDQuery, .accountCheck, .auth, .subscription],
            [.riskDec, .accountCheck, .threeDQuery, .auth]
        ]

        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: nil, zipMaxAmount: nil)

        for typeDescriptions in validRequestTypes {
            guard let jwt = jwt(with: typeDescriptions, billingData: validBillingData, deliveryData: validDeliveryData) else {
                XCTFail("Missing JWT")
                return
            }
            let controller = try ViewControllerFactory.shared.dropInViewController(jwt: jwt, apmsConfiguration: apmConfig, payButtonTappedClosureBeforeTransaction: nil, transactionResponseClosure: { _, _, _ in })
            guard let zipButton = getButton(view: controller.viewController.view) else {
                XCTFail("Missing ZIP button in view's hierarchy")
                continue
            }
            XCTAssertFalse(zipButton.isHidden)
        }

        for typeDescriptions in invalidRequestTypes {
            guard let jwt = jwt(with: typeDescriptions, billingData: validBillingData, deliveryData: validDeliveryData) else {
                XCTFail("Missing JWT")
                return
            }
            let controller = try ViewControllerFactory.shared.dropInViewController(jwt: jwt, apmsConfiguration: apmConfig, payButtonTappedClosureBeforeTransaction: nil, transactionResponseClosure: { _, _, _ in })
            guard let zipButton = getButton(view: controller.viewController.view) else {
                XCTFail("Missing ZIP button in view's hierarchy")
                continue
            }
            XCTAssertTrue(zipButton.isHidden)
        }
    }

    func testZipNotAllowedForBaseamountLowerThanMin() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)

        guard let jwt = jwt(with: [.auth], baseamount: 1400, billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testZipNotAllowedForBaseamountGreaterThanMax() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)

        guard let jwt = jwt(with: [.auth], baseamount: 4100, billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testZipAllowedForBaseamountWithingMinMaxRange() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)

        guard let jwt = jwt(with: [.auth], baseamount: 2100, billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertFalse(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testZipNotAllowedForMainamountLowerThanMin() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)

        guard let jwt = jwt(with: [.auth], mainamount: 10.00, billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testZipNotAllowedForMainamountGreaterThanMax() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)

        guard let jwt = jwt(with: [.auth], mainamount: 54.00, billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testZipAllowedForMainamountWithingMinMaxRange() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)

        guard let jwt = jwt(with: [.auth], mainamount: 17.00, billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertFalse(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataFirstname() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: nil, lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "test", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataLastname() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: nil, street: "test", town: "test", county: "test", countryIso2a: "test", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataStreet() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: nil, town: "test", county: "test", countryIso2a: "test", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataTown() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: nil, county: "test", countryIso2a: "test", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataCounty() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: nil, countryIso2a: "test", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataCountryIso2a() { let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: nil, postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataPostcode() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "test", postcode: nil, email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataEmail() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "test", postcode: "test", email: nil, premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingBillingDataPremise() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "test", postcode: "test", email: "test", premise: nil)
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
    
    func testMissingDeliveryDataFirstname() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: nil, customerlastname: "test", customerstreet: "test", customertown: "test", customercounty: "test", customercountryiso2a: "test", customerpostcode: "test", customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataLastname() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: nil, customerstreet: "test", customertown: "test", customercounty: "test", customercountryiso2a: "test", customerpostcode: "test", customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataStreet() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: nil, customertown: "test", customercounty: "test", customercountryiso2a: "test", customerpostcode: "test", customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataTown() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: "test", customertown: nil, customercounty: "test", customercountryiso2a: "test", customerpostcode: "test", customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataCounty() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: "test", customertown: "test", customercounty: nil, customercountryiso2a: "test", customerpostcode: "test", customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataCountryIso2a() { let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: "test", customertown: "test", customercounty: "test", customercountryiso2a: nil, customerpostcode: "test", customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataPostcode() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: "test", customertown: "test", customercounty: "test", customercountryiso2a: "test", customerpostcode: nil, customeremail: "test", customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataEmail() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: "test", customertown: "test", customercounty: "test", customercountryiso2a: "test", customerpostcode: "test", customeremail: nil, customerpremise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testMissingDeliveryDataPremise() {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let delivery = DeliveryData(customerfirstname: "test", customerlastname: "test", customerstreet: "test", customertown: "test", customercounty: "test", customercountryiso2a: "test", customerpostcode: "test", customeremail: "test", customerpremise: nil)
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: validBillingData, deliveryData: delivery) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }

    func testAllDataAreProvided() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip], zipMinAmount: 15.00, zipMaxAmount: 40.00)
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "test", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], mainamount: 19.00, billingData: billing, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertFalse(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
    
    func testValidCurrencyCurrencyIso3a() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip])
        guard let jwt = jwt(with: [.auth], currency: "GBP", billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertFalse(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
    
    func testInvalidCurrencyCurrencyIso3a() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.zip])
        guard let jwt = jwt(with: [.auth], currency: "JPY", billingData: validBillingData, deliveryData: validDeliveryData) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isZipButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
}

private extension TestZIPFlow {

    var validBillingData: BillingData {
        BillingData(prefixName: nil,
                    firstName: "name",
                    middleName: "middle",
                    lastName: "last",
                    street: "street",
                    town: "town",
                    county: "county",
                    countryIso2a: "iso",
                    postcode: "postcode",
                    email: "email",
                    premise: "premise")
    }
    
    var validDeliveryData: DeliveryData {
        DeliveryData(customerfirstname: "Trust",
                     customerlastname: "Payments",
                     customerstreet: "1 Royal Exchange",
                     customertown: "London",
                     customercounty: "England",
                     customercountryiso2a: "GB",
                     customerpostcode: "EC3V 3DG",
                     customeremail: "example@mail.com",
                     customerpremise: "34")
    }

    func getButton(view: UIView) -> ZIPButton? {
        func allSubviews(of mainView: UIView) -> ZIPButton? {
            if mainView.subviews.contains(where: { $0 is ZIPButton }) == true {
                return mainView.subviews.first(where: { $0 is ZIPButton }) as? ZIPButton
            }
            for subView in mainView.subviews {
                if let button = allSubviews(of: subView) {
                    return button
                }
                continue
            }
            return nil
        }
        return allSubviews(of: view)
    }

    func jwt(with requestTypes: [TypeDescription], baseamount: Int? = nil, mainamount: Double? = nil, currency: String? = nil, billingData: BillingData, deliveryData: DeliveryData) -> String? {
        let keys = ApplicationKeys(keys: ExampleKeys())
        let typeDescriptions = requestTypes.map(\.rawValue)
        let currencyType: String = currency ?? "GBP"
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              locale: "en_GB",
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: currencyType,
                                              baseamount: baseamount,
                                              mainamount: mainamount,
                                              billingData: billingData,
                                              deliveryData: deliveryData))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    func isZipButtonHidden(jwt: String, apmConfig: TPAPMConfiguration) throws -> Bool {
        let controller = try ViewControllerFactory.shared.dropInViewController(jwt: jwt, apmsConfiguration: apmConfig, payButtonTappedClosureBeforeTransaction: nil, transactionResponseClosure: { _, _, _ in })
        guard let zipButton = getButton(view: controller.viewController.view) else {
            XCTFail("Missing ZIP button in view's hierarchy")
            throw NSError()
        }
        return zipButton.isHidden
    }

    // swiftlint:disable line_length
    var validJWT: String { "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqd3QtcGdzbW9iaWxlc2RrIiwiaWF0IjoxNjM0MjA2NDY1LjkxMzk0LCJwYXlsb2FkIjp7ImxvY2FsZSI6ImVuX0dCIiwicmVxdWVzdHR5cGVkZXNjcmlwdGlvbnMiOlsiQVVUSCJdLCJiYXNlYW1vdW50IjoxMTAwLCJzaXRlcmVmZXJlbmNlIjoidGVzdF9wZ3Ntb2JpbGVzZGs3OTQ1OCIsImFjY291bnR0eXBlZGVzY3JpcHRpb24iOiJFQ09NIiwiY3VycmVuY3lpc28zYSI6IkdCUCIsInRlcm11cmwiOiJodHRwczpcL1wvcGF5bWVudHMuc2VjdXJldHJhZGluZy5uZXRcL3Byb2Nlc3NcL3BheW1lbnRzXC9tb2JpbGVzZGtsaXN0ZW5lciJ9fQ.24dQFkTwov3deonewrEmVI3EXBQrywKuhXdoTa_w0DU"
    }

    func mockedZIPResponse() -> String? {
        var response = baseResponseJSON
        var baseResponse = baseResponseBodyJSON
        response["redirecturl"] = "https://redirect.url.app.specific.com"
        baseResponse["payload"] = ["response": [response], "jwt": ""]

        let jwt = [
            [
                "alg": "HS256",
                "typ": "JWT"
            ].data.base64URLEncoded,
            baseResponse.data.base64URLEncoded,
            "signature"
        ].joined(separator: ".")
        return jwt
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
