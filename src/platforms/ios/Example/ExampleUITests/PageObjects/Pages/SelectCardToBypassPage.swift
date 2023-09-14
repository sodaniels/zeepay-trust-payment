import XCTest

final class SelectCardToBypassPage: BaseAppPage {
    // MARK: - Elements

    private var visaCard: XCUIElement {
        app.cells["VisaCell"].firstMatch
    }

    private var masterCard: XCUIElement {
        app.cells["MasterCardCell"].firstMatch
    }

    private var amexCard: XCUIElement {
        app.cells["American ExpressCell"].firstMatch
    }

    private var maestroCard: XCUIElement {
        app.cells["MaestroCell"].firstMatch
    }

    private var discoverCard: XCUIElement {
        app.cells["DiscoverCell"].firstMatch
    }

    private var dinersClubCard: XCUIElement {
        app.cells["Diners ClubCell"].firstMatch
    }

    private var jcbCard: XCUIElement {
        app.cells["JCBCell"].firstMatch
    }

    private var nextButton: XCUIElement {
        app.buttons["nextButton"].firstMatch
    }

    private var supportedCards: XCUIElement {
        app.tables["supportedCardTypes"].firstMatch
    }

    private var cardTypesCells: [XCUIElement] {
        supportedCards.cells.allElementsBoundByIndex
    }

    // MARK: - Actions

    func selectAllCardTypes() -> SelectCardToBypassPage {
        cardTypesCells.forEach { cardTypeCell in
            cardTypeCell.tap()
        }
        return self
    }

    func selectCustomCardTypes(bypassCards: [XCUIElement]) {
        bypassCards.forEach { cardTypeCell in
            cardTypeCell.tap()
        }
    }

    func selectAllCardsExceptOfMasterCard() -> SelectCardToBypassPage {
        selectCustomCardTypes(bypassCards: [visaCard, amexCard, maestroCard, discoverCard, dinersClubCard, jcbCard])
        return self
    }

    func selectBypassCard(_ cardName: String) -> SelectCardToBypassPage {
        app.staticTexts[cardName].tap()
        return self
    }

    func tapNextButton() {
        nextButton.tap()
    }
}
