import Foundation
import XCTest

final class ZIPPage: BaseAppPage {
    // MARK: - Elements

    private var cancelButton: XCUIElement {
        app.buttons["Cancel"].firstMatch
    }
    
    private var webBody: XCUIElement {
        app.webViews.firstMatch
    }
    
    private var mobileNumberTextField: XCUIElement {
        webBody.textFields.firstMatch
    }
    
    private var nextButton: XCUIElement {
        webBody.buttons["Next"].firstMatch
    }
    
    private var verifyCodeInput: XCUIElement {
        webBody.textFields["Input code one"].firstMatch
    }
    
    private var verifyButton: XCUIElement {
        webBody.buttons["Verify"].firstMatch
    }

    private var confirmPaymentButton: XCUIElement {
        webBody.buttons["Confirm Payment"].firstMatch
    }
    
    // MARK: - Actions

    func tapCancelButton() {
        waitUntilZipFormDisplayed()
        cancelButton.tap()
    }
    
    func tapNextButton() {
        nextButton.tap()
    }

    func type(phoneNumber: String) -> ZIPPage {
        waitUntilZipFormDisplayed()
        mobileNumberTextField.tap()
        mobileNumberTextField.typeText(phoneNumber)
        mobileNumberTextField.typeText("\n")
        return self
    }
    
    func tapVerifyButton() -> ZIPPage {
        verifyButton.tap()
        return self
    }
    
    private func tapVerifyCodeInput() {
        verifyCodeInput.tap()
    }
    
    func type(verifyCode: String) {
        waitUntilVerifyFormDisplayed()
        tapVerifyCodeInput()
        for _ in 1 ... 2_000_000 {}
        Thread.sleep(forTimeInterval: 5)
        verifyCodeInput.typeText(verifyCode)
    }

    func tapConfirmPaymentButton() {
        waitUntilOrderSummaryIsDisplayed()
        scrollUntilCanInteract(with: confirmPaymentButton)
        confirmPaymentButton.tap()
    }

    // MARK: - Helpers

    func scrollUntilCanInteract(with element: XCUIElement) {
        if !element.isHittable {
            app.swipeUp()
        }
    }

    private func waitUntilZipFormDisplayed() -> ZIPPage {
        if !nextButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout) {
            XCTFail("Zip form was not loaded.")
        }
        return self
    }

    private func waitUntilVerifyFormDisplayed() -> ZIPPage {
        if !verifyButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout) {
            XCTFail("Verify form was not loaded.")
        }
        return self
    }

    private func waitUntilOrderSummaryIsDisplayed() -> ZIPPage {
        if !confirmPaymentButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout) {
            XCTFail("Order summary was not loaded.")
        }
        return self
    }
}
