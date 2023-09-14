import XCTest

final class ApplePayActivityViewPage: BaseAppPage {
    // MARK: - Elements

    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    private var payWithPasscodeButton: XCUIElement {
        springboard.buttons["Pay with Passcode"]
    }

    private var passcodeOverlay: XCUIElement {
        springboard
    }

    private var cancelButton: XCUIElement {
        springboard.buttons["Cancel"]
    }

    // MARK: - Actions

    func tapPayWithPasscode() -> ApplePayActivityViewPage {
        waitUntilPasscodeButtonIsVisible()
        payWithPasscodeButton.tap()
        return self
    }

    func typePasscode() {
        // Passcode is comma separated eg: 1234 -> 1.2.3.4
        let passcode = ApplicationKeys(keys: ExampleKeys()).passcode.split(separator: ".").map { String($0) }
        for digit in passcode {
            passcodeOverlay.buttons[digit].tap()
        }
    }

    func tapCancel() {
        cancelButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
        cancelButton.tap()
    }

    // MARK: - Helpers

    func waitUntilPasscodeButtonIsVisible() -> Bool {
        payWithPasscodeButton.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
    }
}
