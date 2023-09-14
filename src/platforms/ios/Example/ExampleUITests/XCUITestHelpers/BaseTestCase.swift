import XCTest

class BaseTestCase: XCTestCase {
    var app = XCUIApplication()

    // MARK: Setup

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        disableAnimations()
        clearStoredCards()
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    func clearStoredCards() {
        app.launchEnvironment = ["CLEAR_STORED_CARDS": "YES"]
    }

    func disableAnimations() {
        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS": "YES"]
    }
}
