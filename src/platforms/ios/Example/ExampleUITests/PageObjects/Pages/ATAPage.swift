//
//  ATAPage.swift
//  ExampleUITests
//

import Foundation
import XCTest

final class ATAPage: BaseAppPage {
    // MARK: - Elements

    private var cancelButton: XCUIElement {
        app.buttons["Cancel"].firstMatch
    }
    
    private var webBody: XCUIElement {
        app.webViews.firstMatch
    }
    
    private var bankSearchField: XCUIElement {
        webBody.otherElements["Bank Search by Name or BIC:"].firstMatch
    }

    // MARK: - Actions

    func tapCancelButton() {
        _ = waitUntilATAFormDisplayed()
        cancelButton.tap()
    }
    
    func tapBankSearchTextField() {
        _ = waitUntilATAFormDisplayed()
        let coo = bankSearchField.coordinate(withNormalizedOffset: .zero)
        coo.withOffset(CGVector(dx: 30, dy: 50)).tap()
    }
    
    func tapOzoneBank() {
        let bankEntry = webBody.otherElements["Ozone Modelo Test Bank"]
        _ = bankEntry.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        app.buttons["Done"].tap()
        app.swipeUp()
        bankEntry.tap()
    }
    
    func acceptOzoneTerms() {
        let toStaticText = webBody/*@START_MENU_TOKEN@*/ .staticTexts["To"]/*[[".otherElements[\"Token Web App\"].staticTexts[\"To\"]",".staticTexts[\"To\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        _ = toStaticText.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        toStaticText.tap()
        let acceptButton = webBody.buttons["Accept"]
        app.swipeUp()
        app.swipeUp()
        acceptButton.tap()
    }

    func loginWithOzoneCredentials() {
        // Login page
        let loginButton = webBody.staticTexts["Login"].firstMatch
        _ = loginButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        webBody.textFields.firstMatch.tap()
        webBody.textFields.firstMatch.typeText("mits")
        app.buttons["Done"].tap()
        webBody.secureTextFields.firstMatch.tap()
        webBody.secureTextFields.firstMatch.typeText("mits")
        app.buttons["Done"].tap()
        loginButton.tap()
        
        // Confirmation page
        _ = webBody.staticTexts["Confirm Payment Account"].firstMatch.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        webBody.otherElements["* Select debtor account"].tap()
        let dropDownOption = app.buttons["Mr. Roberto Rastapopoulos & Ivan Sakharine & mits (700001 - 70000006)"].firstMatch
        _ = dropDownOption.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        dropDownOption.tap()
        app.swipeUp()
        webBody.staticTexts["Confirm"].tap()
    }
    
    func cancelOzone() {
        let cancelButton = webBody.staticTexts["Cancel"].firstMatch
        _ = cancelButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        cancelButton.tap()
    }
    
    // MARK: - Helpers

    private func waitUntilATAFormDisplayed() -> ATAPage {
        if !bankSearchField.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout) {
            XCTFail("ATA form was not loaded.")
        }
        return self
    }
}
