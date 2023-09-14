import XCTest

final class AuthWith3DSecureV1FormPage: BaseAppPage {
    // MARK: - Elements

    private var webBody: XCUIElement {
        app.webViews.firstMatch
    }

    private var threeDSecureCodeInput: XCUIElement {
        webBody.secureTextFields.firstMatch
    }

    private var submitButton: XCUIElement {
        webBody.buttons["Submit"]
    }

    // MARK: - Actions

    func type(_ threeDSecureCode: String) -> AuthWith3DSecureV1FormPage {
        threeDSecureCodeInput.tap()
        threeDSecureCodeInput.typeText(threeDSecureCode)
        return self
    }

    // MARK: - Helpers

    func waitUntilWebIsLoaded() -> AuthWith3DSecureV1FormPage {
        if !webBody.waitForExistence(timeout: DefaultTestTimeouts.threeDSecureFormDisplayed) {
            XCTFail("3DSecureV1 form was not loaded on time.")
        }
        return self
    }

    func tapSubmit() {
        submitButton.tap()
    }

    func is3DSecureFormDisplayed() -> Bool {
        threeDSecureCodeInput.waitForExistence(timeout: DefaultTestTimeouts.threeDSecureFormDisplayed)
    }
}
