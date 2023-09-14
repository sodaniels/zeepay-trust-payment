import XCTest

final class AuthWith3DSecureV2FormPage: BaseAppPage {
    // MARK: - Elements

    // Query is adjusted to handle different accessibility hierarchy on iOS 11 & iOS 12
    private var threeDSecureCodeInput: XCUIElement {
        let allThreeDSecureCodeInputs = app.textFields.allElementsBoundByIndex.filter { $0.identifier == "challengeDataEntry" && $0.isHittable }
        guard let singleInputIdentifier = allThreeDSecureCodeInputs.first else {
            XCTFail("Failed to get single ThreeDSecureInput element.")
            return app
        }
        return singleInputIdentifier
    }

    var submitButton: XCUIElement {
        app.buttons["submitAuthenticationLabel"].firstMatch
    }

    private var cancelButton: XCUIElement {
        app.navigationBars.buttons["Cancel"].firstMatch
    }

    private var moreInformationButton: XCUIElement {
        app.buttons["expandInfoLabel"].firstMatch
    }

    // MARK: - Actions

    func tapSubmit() {
        submitButton.tap()
    }

    func type(_ threeDSecureCode: String) -> AuthWith3DSecureV2FormPage {
        waitUntil3DSecureFormIsVisible()
        scrollUntilCanInteract(with: moreInformationButton)
        threeDSecureCodeInput.tap()
        threeDSecureCodeInput.typeText(threeDSecureCode)
        threeDSecureCodeInput.typeText("\n")
        return self
    }

    func tapCancelButton() {
        waitUntil3DSecureFormIsVisible()
        cancelButton.tap()
    }

    // MARK: - Helpers

    func is3DSecureFormDisplayed() -> Bool {
        waitUntil3DSecureFormIsVisible()
    }

    @discardableResult
    func waitUntil3DSecureFormIsVisible() -> Bool {
        submitButton.waitForExistence(timeout: DefaultTestTimeouts.threeDSecureFormDisplayed)
    }

    func scrollUntilCanInteract(with element: XCUIElement) {
        if !element.isHittable {
            app.swipeUp()
        }
    }
}
