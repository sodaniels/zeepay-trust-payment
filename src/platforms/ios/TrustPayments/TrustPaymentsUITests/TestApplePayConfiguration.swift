//
//  TestApplePayConfiguration.swift
//  TrustPaymentsUITests
//

import PassKit
@testable import TrustPaymentsUI
import XCTest

class TestApplePayConfiguration: XCTestCase {
    let handlerMock = ConfigurationHandlerMock()
    let controller = PKPaymentAuthorizationViewController()
    var config: TPApplePayConfiguration!
    let summaryItem = PKPaymentSummaryItem(label: "Test Apple Pay", amount: 1.9)

    override func setUp() {
        let request = PKPaymentRequest()
        request.merchantCapabilities = [.capability3DS]
        request.supportedNetworks = [.visa]
        request.countryCode = "GB"
        request.currencyCode = "GBP"
        request.merchantIdentifier = ""
        config = TPApplePayConfiguration(handler: handlerMock, request: request, buttonStyle: .black, buttonDarkModeStyle: .white, buttonType: .buy)
    }

    func test_initValuesAreAssigned() {
        let request = PKPaymentRequest()
        request.merchantCapabilities = [.capability3DS]
        request.supportedNetworks = [.visa]
        let config = TPApplePayConfiguration(handler: handlerMock, request: request, buttonStyle: .black, buttonDarkModeStyle: .white, buttonType: .buy)

        XCTAssertNotNil(config.configurationHandler)
        XCTAssertEqual(config.buttonStyle, .black)
        XCTAssertEqual(config.buttonDarkModeStyle, .white)
        XCTAssertEqual(config.buttonType, .buy)
        XCTAssertEqual(config.request.merchantCapabilities, [.capability3DS])
        XCTAssertEqual(config.request.supportedNetworks, [.visa])
    }

    func test_applePayIsAvailable() {
        let expected = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: config.request.supportedNetworks, capabilities: config.request.merchantCapabilities)
        XCTAssertEqual(expected, config.isApplePayAvailable)
    }

    func test_didFinishCallsDidCancelHandler() {
        config.paymentAuthorizationViewControllerDidFinish(controller)
        XCTAssertTrue(handlerMock.didCancelPaymentAuthorizationCalled)
    }

    // MARK: Update shipping method

    func test_updateShippingMethodCallsHandler() {
        let expectations = XCTestExpectation()
        config.paymentAuthorizationViewController(controller, didSelect: PKShippingMethod()) { _ in
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
        XCTAssertTrue(handlerMock.shippingMethodChangedCalled)
    }

    func test_updateShippingMethodSetNewSummaryItems() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        config.paymentAuthorizationViewController(controller, didSelect: PKShippingMethod()) { updateMethod in
            XCTAssertEqual(updateMethod.paymentSummaryItems.first?.amount, self.summaryItem.amount)
            XCTAssertEqual(updateMethod.paymentSummaryItems.first?.label, self.summaryItem.label)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    func test_updateShippingMethodCallsCompletionOnNilHandler() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        config.configurationHandler = nil
        config.paymentAuthorizationViewController(controller, didSelect: PKShippingMethod()) { updateMethod in
            XCTAssertTrue(updateMethod.paymentSummaryItems.isEmpty)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    // MARK: Update shipping contact

    func test_updateShippingContactCallsCompletionOnNilHandler() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        config.configurationHandler = nil
        let contact = PKContact()
        config.paymentAuthorizationViewController(controller, didSelectShippingContact: contact) { updateMethod in
            XCTAssertTrue(updateMethod.paymentSummaryItems.isEmpty)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    func test_updateShippingContactCallsCompletionOnNilPostalAddress() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        let contact = PKContact()
        config.paymentAuthorizationViewController(controller, didSelectShippingContact: contact) { updateMethod in
            XCTAssertTrue(updateMethod.paymentSummaryItems.isEmpty)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    func test_updateShippingContactSetNewSummaryItems() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        let contact = PKContact()
        contact.postalAddress = CNPostalAddress()
        config.paymentAuthorizationViewController(controller, didSelectShippingContact: contact) { updateMethod in
            XCTAssertEqual(updateMethod.paymentSummaryItems.first?.amount, self.summaryItem.amount)
            XCTAssertEqual(updateMethod.paymentSummaryItems.first?.label, self.summaryItem.label)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    // MARK: Update payment method

    func test_updatePaymentMethodCallsCompletionOnNilHandler() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        config.configurationHandler = nil
        config.paymentAuthorizationViewController(controller, didSelect: PKPaymentMethod()) { updateMethod in
            XCTAssertTrue(updateMethod.paymentSummaryItems.isEmpty)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    func test_updatePaymentMethodCallsCompletionOnNilPostalAddress() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [self.summaryItem])
        }
        let paymentMethod = PKPaymentMethod()
        config.paymentAuthorizationViewController(controller, didSelect: paymentMethod) { updateMethod in
            XCTAssertTrue(updateMethod.paymentSummaryItems.isEmpty)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1)
    }

    // MARK: Update authorized transaction method

    func test_authorizedPaymentMethodReturnsErrorOnNilHandler() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [])
        }
        config.configurationHandler = nil
        config.paymentAuthorizationViewController(controller, didAuthorizePayment: PKPayment(), handler: { result in
            XCTAssertEqual(result.errors?.first as? PKPaymentError, PKPaymentError(.unknownError))
            expectations.fulfill()
        })
        wait(for: [expectations], timeout: 1)
    }

    func test_authorizedPaymentMethodReturnsSuccessForEmptyError() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            (nil, [])
        }
        config.paymentAuthorizationViewController(controller, didAuthorizePayment: PKPayment(), handler: { result in
            XCTAssertEqual(result.status, .success)
            expectations.fulfill()
        })
        wait(for: [expectations], timeout: 1)
    }

    func test_authorizedPaymentMethodReturnsFailureForNonEmptyError() {
        let expectations = XCTestExpectation()
        handlerMock.completionHandler = {
            ([PKPaymentError(.billingContactInvalidError)], [])
        }
        config.paymentAuthorizationViewController(controller, didAuthorizePayment: PKPayment(), handler: { result in
            XCTAssertEqual(result.status, .failure)
            expectations.fulfill()
        })
        wait(for: [expectations], timeout: 1)
    }
}

class ConfigurationHandlerMock: TPApplePayConfigurationHandler {
    var shippingMethodChangedCalled = false
    var shippingAddressChangedCalled = false
    var didAuthorizedPaymentCalled = false
    var didCancelPaymentAuthorizationCalled = false
    var completionHandler: (() -> ([Error]?, [PKPaymentSummaryItem]))?

    func shippingMethodChanged(to _: PKShippingMethod, updatedWith: @escaping ([PKPaymentSummaryItem]) -> Void) {
        shippingMethodChangedCalled = true
        let summaryItems = completionHandler?().1 ?? []
        updatedWith(summaryItems)
    }

    func shippingAddressChanged(to _: CNPostalAddress, updatedWith: @escaping ([Error]?, [PKPaymentSummaryItem]) -> Void) {
        shippingAddressChangedCalled = true
        let errors = completionHandler?().0 ?? nil
        let summaryItems = completionHandler?().1 ?? []
        updatedWith(errors, summaryItems)
    }

    func didAuthorizedPayment(payment _: PKPayment, updatedRequestParameters: @escaping ((String?, String?, [Error]?) -> Void)) {
        didAuthorizedPaymentCalled = true
        let error = completionHandler?().0
        updatedRequestParameters(nil, nil, error)
    }

    func didCancelPaymentAuthorization() {
        didCancelPaymentAuthorizationCalled = true
    }
}
