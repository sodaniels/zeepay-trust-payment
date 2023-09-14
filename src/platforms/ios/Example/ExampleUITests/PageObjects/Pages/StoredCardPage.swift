import XCTest

final class StoredCardPage: BaseAppPage {
    // MARK: - Elements

    private var addPaymentMethod: XCUIElement {
        app.cells["addPaymentMethodButton"].firstMatch
    }

    private var addedAmexReference: XCUIElement {
        app.cells["addAMEXReference"]
    }

    private var nextButton: XCUIElement {
        app.buttons["nextButton"].firstMatch
    }

    private var deleteCard: XCUIElement {
        app.buttons["trailing0"].firstMatch
    }

    private var cardsTable: XCUIElement {
        app.tables["savedCardsTableView"]
    }

    // MARK: - Actions

    func tapAddPaymentMethod() {
        waitUntilAddCardButtonIsVisible()
        addPaymentMethod.tap()
    }

    func tapOnSavedCard(_ cardName: String) -> StoredCardPage {
        app.staticTexts[cardName].tap()
        return self
    }

    func tapNextButton() {
        nextButton.tap()
    }

    // MARK: - Helpers

    var isAmexCardSaved: Bool {
        addedAmexReference.exists
    }

    func getCountOfSavedCards() -> Int {
        cardsTable.cells.count
    }

    @discardableResult
    private func waitUntilAddCardButtonIsVisible() -> Bool {
        addPaymentMethod.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
    }
}
