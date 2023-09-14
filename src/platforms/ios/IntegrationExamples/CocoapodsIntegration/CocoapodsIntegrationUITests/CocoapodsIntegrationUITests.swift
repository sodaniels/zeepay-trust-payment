//
//  CocoapodsIntegrationUITests.swift
//  CocoapodsIntegrationUITests
//

import XCTest

class CocoapodsIntegrationUITests: XCTestCase {

    private var app: XCUIApplication!

    private var checkoutButton: XCUIElement {
        app.buttons["Checkout"]
    }

    private var cardNumberField: XCUIElement {
        app.textFields["st-card-number-input-textfield"]
    }

    private var monthInput: XCUIElement {
        app.textFields["st-expiration-date-input-month-textfield"].firstMatch
    }

    private var yearInput: XCUIElement {
        app.textFields["st-expiration-date-input-year-textfield"].firstMatch
    }

    private var cvvInput: XCUIElement {
        app.secureTextFields["st-security-code-input-textfield"].firstMatch
    }

    private var submitButton: XCUIElement {
        app.buttons["payButton"].firstMatch
    }

    private var threeDSecureCodeInput: XCUIElement {
        let allThreeDSecureCodeInputs = app.textFields.allElementsBoundByIndex.filter { $0.identifier == "challengeDataEntry" && $0.isHittable }
        guard let singleInputIdentifier = allThreeDSecureCodeInputs.first else {
            XCTFail("Failed to get single ThreeDSecureInput element.")
            return app
        }
        return singleInputIdentifier
    }

    var threeDSubmitButton: XCUIElement {
        app.buttons["submitAuthenticationLabel"].firstMatch
    }

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
    }

    func testExample() throws {
        let nonFrictionlessVisaCardNumber = "4000000000001091"
        checkoutButton.tap()

        // wait for the form to be displayed
        _ = cardNumberField.firstMatch.waitForExistence(timeout: 5)

        cardNumberField.tap()
        cardNumberField.typeText(nonFrictionlessVisaCardNumber)
        cardNumberField.typeText("\n")

        monthInput.tap()
        monthInput.typeText("01")

        yearInput.tap()
        yearInput.typeText("23")

        cvvInput.tap()
        cvvInput.typeText("123")

        submitButton.tap()

        _ = threeDSubmitButton.waitForExistence(timeout: 10)

        threeDSecureCodeInput.tap()
        threeDSecureCodeInput.typeText("1234")
        threeDSubmitButton.tap()
    }
}
