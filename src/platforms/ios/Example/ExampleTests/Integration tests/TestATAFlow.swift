//
//  TestATAFlow.swift
//  ExampleTests
//

@testable import Trust_Payments
@testable import TrustPaymentsCore
import TrustPaymentsUI
import XCTest

class TestATAFlow: XCTestCase {
    
    func testATAButtonVisibleForValidRequestTypes() throws {
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

        let apmConfig = TPAPMConfiguration(supportedAPMs: [.ata])

        for typeDescriptions in validRequestTypes {
            guard let jwt = jwt(with: typeDescriptions, currency: "GBP", billingData: validBillingData) else {
                XCTFail("Missing JWT")
                return
            }
            let controller = try ViewControllerFactory.shared.dropInViewController(jwt: jwt, apmsConfiguration: apmConfig, payButtonTappedClosureBeforeTransaction: nil, transactionResponseClosure: { _, _, _ in })
            guard let ataButton = getATAButton(view: controller.viewController.view) else {
                XCTFail("Missing ATA button in view's hierarchy")
                continue
            }
            XCTAssertFalse(ataButton.isHidden)
        }

        for typeDescriptions in invalidRequestTypes {
            guard let jwt = jwt(with: typeDescriptions, currency: "GBP", billingData: validBillingData) else {
                XCTFail("Missing JWT")
                return
            }
            let controller = try ViewControllerFactory.shared.dropInViewController(jwt: jwt, apmsConfiguration: apmConfig, payButtonTappedClosureBeforeTransaction: nil, transactionResponseClosure: { _, _, _ in })
            guard let ataButton = getATAButton(view: controller.viewController.view) else {
                XCTFail("Missing ATA button in view's hierarchy")
                continue
            }
            XCTAssertFalse(ataButton.isHidden)
        }
    }
    
    func testATAMissingBillingDataCountryIso2a() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.ata])
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: nil, postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], currency: "GBP", billingData: billing) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isATAButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
    
    func testATACurrencyGBPCurrencyIso3a() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.ata])
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "GB", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], currency: "GBP", billingData: billing) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertFalse(try isATAButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
    
    func testATACurrencyEURCurrencyIso3a() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.ata])
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "GB", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], currency: "EUR", billingData: billing) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertFalse(try isATAButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
    
    func testATAUnsupportedCurrencyCurrencyIso3a() throws {
        let apmConfig = TPAPMConfiguration(supportedAPMs: [.ata])
        let billing = BillingData(firstName: "test", lastName: "test", street: "test", town: "test", county: "test", countryIso2a: "GB", postcode: "test", email: "test", premise: "test")
        guard let jwt = jwt(with: [.auth], currency: "JPY", billingData: billing) else {
            XCTFail("Missing JWT")
            return
        }

        XCTAssertTrue(try isATAButtonHidden(jwt: jwt, apmConfig: apmConfig))
    }
}

private extension TestATAFlow {
    
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
    
    func jwt(with requestTypes: [TypeDescription], currency: String, billingData: BillingData) -> String? {
        let keys = ApplicationKeys(keys: ExampleKeys())
        let typeDescriptions = requestTypes.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              locale: "en_GB",
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: currency,
                                              billingData: billingData))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }
    
    func isATAButtonHidden(jwt: String, apmConfig: TPAPMConfiguration) throws -> Bool {
        let controller = try ViewControllerFactory.shared.dropInViewController(jwt: jwt, apmsConfiguration: apmConfig, payButtonTappedClosureBeforeTransaction: nil, transactionResponseClosure: { _, _, _ in })
        guard let ataButton = getATAButton(view: controller.viewController.view) else {
            XCTFail("Missing ATA button in view's hierarchy")
            throw NSError()
        }
        return ataButton.isHidden
    }
    
    func getATAButton(view: UIView) -> ATAButton? {
        func allSubviews(of mainView: UIView) -> ATAButton? {
            if mainView.subviews.contains(where: { $0 is ATAButton }) == true {
                return mainView.subviews.first(where: { $0 is ATAButton }) as? ATAButton
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
}
