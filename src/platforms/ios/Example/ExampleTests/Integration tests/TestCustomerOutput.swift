//
//  TestCustomerOutput.swift
//  ExampleTests
//

import Foundation
@testable import Trust_Payments
import XCTest

class TestCustomerOutput: KIFTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!
    private let keys = ApplicationKeys(keys: ExampleKeys())

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

    func test_positive_3DQv2_frictionless() throws {
        let frictionlessMasterCardNumber = "5200000000001005"
        let jwtToken = getJwtTokenWith(typeDescriptions: [.threeDQuery], cardNumber: frictionlessMasterCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertNil(error)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 1)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.first)
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .threeDQuery)
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .result)

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }
    
    func test_positive_3DQv2_auth_challenge() throws {
        let nonFrictionlessVisaCardNumber = "4000000000001091"
        let jwtToken = getJwtTokenWith(typeDescriptions: [.threeDQuery, .auth], cardNumber: nonFrictionlessVisaCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 2)
            XCTAssertNotNil(transactionResult?.threeDResponse)
            XCTAssertNil(transactionResult?.pares)
            XCTAssertNil(error)

            guard let parsedResponse = try? TPHelper.getTPResponses(jwt: responseJwt) else {
                XCTFail("jwt cannot be parsed")
                return
            }

            XCTAssertEqual(parsedResponse.count, 2)
            XCTAssertEqual(parsedResponse[safe: 0]?.responseObjects.count, 1)
            XCTAssertEqual(parsedResponse[safe: 1]?.responseObjects.count, 1)

            XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput, parsedResponse[safe: 0]?.responseObjects.first)
            XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput?.requestTypeDescription, .threeDQuery)
            XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput?.responseCustomerOutput, .threeDRedirect)

            XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput, parsedResponse[safe: 1]?.responseObjects.first)
            XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput?.requestTypeDescription, .auth)
            XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput?.responseCustomerOutput, .result)

            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func test_positive_3DQv1_nonfrictionless() throws {
         let visaCardNumber = "4000000000000036"
         let jwtToken = getJwtTokenWith(typeDescriptions: [.threeDQuery], cardNumber: visaCardNumber, cvv: "123")

         let expectation = XCTestExpectation(description: "Expectation: \(#function)")
         paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
         paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

             XCTAssertEqual(responseJwt.count, 1)
             XCTAssertNil(transactionResult?.threeDResponse)
             XCTAssertNotNil(transactionResult?.pares)
             XCTAssertNil(error)

             let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

             XCTAssertEqual(parsedResponse?.responseObjects.count, 1)
             XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.first)
             XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .threeDQuery)
             XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .threeDRedirect)

             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 20)
         wait(for: [expectation], timeout: 40)
     }

     func test_positive_3DQv1_auth_challenge() throws {
         let masterCardNumber = "5200000000000007"
         let jwtToken = getJwtTokenWith(typeDescriptions: [.threeDQuery, .auth], cardNumber: masterCardNumber, cvv: "123")

         let expectation = XCTestExpectation(description: "Expectation: \(#function)")
         paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
         paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

             XCTAssertEqual(responseJwt.count, 2)
             XCTAssertNil(transactionResult?.threeDResponse)
             XCTAssertNotNil(transactionResult?.pares)
             XCTAssertNil(error)

             guard let parsedResponse = try? TPHelper.getTPResponses(jwt: responseJwt) else {
                 XCTFail("jwt cannot be parsed")
                 return
             }

             XCTAssertEqual(parsedResponse.count, 2)
             XCTAssertEqual(parsedResponse[safe: 0]?.responseObjects.count, 1)
             XCTAssertEqual(parsedResponse[safe: 1]?.responseObjects.count, 1)

             XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput, parsedResponse[safe: 0]?.responseObjects.first)
             XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput?.requestTypeDescription, .threeDQuery)
             XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput?.responseCustomerOutput, .threeDRedirect)

             XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput, parsedResponse[safe: 1]?.responseObjects.first)
             XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput?.requestTypeDescription, .auth)
             XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput?.responseCustomerOutput, .result)

             expectation.fulfill()
         })
         enterCardinalSecurityCodeV1(delay: 20)
         wait(for: [expectation], timeout: 40)
     }
      */

    func test_negative_3DQ_auth_unauthenticatedCard() throws {
        let unauthenticatedErrorVisaCardNumber = "4000000000001018"
        let jwtToken = getJwtTokenWith(typeDescriptions: [.threeDQuery, .auth], cardNumber: unauthenticatedErrorVisaCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertNil(error)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 2)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.last)
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .none) // error
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .tryAgain)
            XCTAssertEqual(parsedResponse?.responseObjects.first?.responseCustomerOutput, .unknown) // No customer output for 3DQ

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_negative_accountCheck_3DQ_auth_bankErrorCard() throws {
        let bankSystemErrorVisaCardNumber = "4000000000001067"
        let jwtToken = getJwtTokenWith(typeDescriptions: [.accountCheck, .threeDQuery, .auth], cardNumber: bankSystemErrorVisaCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertNil(error)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 3)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.last)
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .auth)
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .result)

            XCTAssertEqual(parsedResponse?.responseObjects[safe: 0]?.responseCustomerOutput, .unknown) // No customer output for account check
            XCTAssertEqual(parsedResponse?.responseObjects[safe: 1]?.responseCustomerOutput, .unknown) // No customer output for 3DQ

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_positive_accountCheck_3DQ_auth_subscription_frictionless() throws {
        let frictionlessVisaCardNumber = "4000000000001026"
        let jwtToken = getJwtTokenWithSubscriptionDataAnd(typeDescriptions: [.accountCheck, .threeDQuery, .auth, .subscription], cardNumber: frictionlessVisaCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertNil(error)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 4)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects[safe: 2])
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .auth)
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .result) // Customer output set for Auth

            XCTAssertEqual(parsedResponse?.responseObjects[safe: 0]?.responseCustomerOutput, .unknown) // No customer output for account check
            XCTAssertEqual(parsedResponse?.responseObjects[safe: 1]?.responseCustomerOutput, .unknown) // No customer output for 3DQ
            XCTAssertEqual(parsedResponse?.responseObjects[safe: 3]?.responseCustomerOutput, .unknown) // No customer output for subscription

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }
    
    func test_positive_accountCheck_3DQ_auth_subscription_challenge() throws {
        let nonFrictionlessMasterCardNumber = "5200000000001096"
        let jwtToken = getJwtTokenWithSubscriptionDataAnd(typeDescriptions: [.accountCheck, .threeDQuery, .auth, .subscription], cardNumber: nonFrictionlessMasterCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 2)
            XCTAssertNotNil(transactionResult?.threeDResponse)
            XCTAssertNil(transactionResult?.pares)
            XCTAssertNil(error)

            guard let parsedResponse = try? TPHelper.getTPResponses(jwt: responseJwt) else {
                XCTFail("jwt cannot be parsed")
                return
            }

            XCTAssertEqual(parsedResponse.count, 2)
            XCTAssertEqual(parsedResponse[safe: 0]?.responseObjects.count, 2)
            XCTAssertEqual(parsedResponse[safe: 1]?.responseObjects.count, 2)

            XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput, parsedResponse[safe: 0]?.responseObjects.last)
            XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput?.requestTypeDescription, .threeDQuery)
            XCTAssertEqual(parsedResponse[safe: 0]?.customerOutput?.responseCustomerOutput, .threeDRedirect)
            XCTAssertEqual(parsedResponse[safe: 0]?.responseObjects[safe: 0]?.responseCustomerOutput, .unknown) // No customer output for account check

            XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput, parsedResponse[safe: 1]?.responseObjects.first)
            XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput?.requestTypeDescription, .auth)
            XCTAssertEqual(parsedResponse[safe: 1]?.customerOutput?.responseCustomerOutput, .result)
            XCTAssertEqual(parsedResponse[safe: 1]?.responseObjects[safe: 1]?.responseCustomerOutput, .unknown) // No customer output for subscription

            expectation.fulfill()
        })
        enterCardinalSecurityCodeV2(delay: 6)
        wait(for: [expectation], timeout: 60)
    }

    func test_negative_accountCheck_3DQ_auth_subscription_failedChallenge() throws {
        let nonFrictionlessMasterCardNumber = "5200000000001096"
        let jwtToken = getJwtTokenWithSubscriptionDataAnd(typeDescriptions: [.accountCheck, .threeDQuery, .auth, .subscription], cardNumber: nonFrictionlessMasterCardNumber, cvv: "123")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertEqual(error?.humanReadableDescription, APIClientError.cardinalAuthenticationError.humanReadableDescription)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 2)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.last)
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .threeDQuery)
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .threeDRedirect)
            XCTAssertEqual(parsedResponse?.responseObjects.first?.responseCustomerOutput, .unknown) // No customer output for account check

            expectation.fulfill()
        })
        wait(interval: 6) { [unowned self] in
            self.tester().tapView(withAccessibilityLabel: "Cancel")
        }
        wait(for: [expectation], timeout: 10)
    }

    func test_negative_auth_subscription_failedSubscription() throws {
        let correctVisaCardNumber = "4111111111111111"
        let jwtToken = getJwtTokenWithSubscriptionDataAnd(typeDescriptions: [.auth, .subscription], cardNumber: correctVisaCardNumber, cvv: "123", currency: "JPY")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertNil(error)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 2)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.first)
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .auth)
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .result) // Customer output set for Auth

            XCTAssertNotEqual(parsedResponse?.responseObjects.last?.responseErrorCode, .successful)
            XCTAssertEqual(parsedResponse?.responseObjects.last?.responseCustomerOutput, .unknown) // No customer output for subscription

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    func test_negative_auth_subscription_noAccountFound() throws {
        let correctVisaCardNumber = "4111111111111111"
        let jwtToken = getJwtTokenWithSubscriptionDataAnd(typeDescriptions: [.auth, .subscription], cardNumber: correctVisaCardNumber, cvv: "123", currency: "CAD")

        let expectation = XCTestExpectation(description: "Expectation: \(#function)")
        paymentTransactionManager = try PaymentTransactionManager(jwt: jwtToken ?? .empty)
        paymentTransactionManager.performTransaction(card: nil, transactionResponseClosure: { responseJwt, transactionResult, error in

            XCTAssertEqual(responseJwt.count, 1)
            XCTAssertNil(transactionResult)
            XCTAssertNil(error)

            let parsedResponse = try? TPHelper.getTPResponse(jwt: responseJwt.first ?? .empty)

            XCTAssertEqual(parsedResponse?.responseObjects.count, 1)
            XCTAssertEqual(parsedResponse?.customerOutput, parsedResponse?.responseObjects.first)
            XCTAssertEqual(parsedResponse?.customerOutput?.requestTypeDescription, .none) // error
            XCTAssertEqual(parsedResponse?.customerOutput?.responseCustomerOutput, .tryAgain) // Customer output set for Auth

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Helpers

    private func getJwtTokenWith(typeDescriptions: [TypeDescription], cardNumber: String, cvv: String, currency: String = "GBP") -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: currency,
                                              baseamount: 1100,
                                              pan: cardNumber,
                                              expirydate: "12/2022",
                                              cvv: cvv))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    private func getJwtTokenWithSubscriptionDataAnd(typeDescriptions: [TypeDescription], cardNumber: String, cvv: String, currency: String = "GBP") -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: currency,
                                              baseamount: 199,
                                              pan: cardNumber,
                                              expirydate: "12/2022",
                                              cvv: cvv,
                                              subscriptiontype: "RECURRING",
                                              subscriptionfinalnumber: "12",
                                              subscriptionunit: "MONTH",
                                              subscriptionfrequency: "1",
                                              subscriptionnumber: "1",
                                              credentialsonfile: "1"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }
}
