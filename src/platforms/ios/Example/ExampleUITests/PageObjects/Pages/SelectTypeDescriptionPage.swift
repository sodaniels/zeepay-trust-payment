import XCTest

final class SelectTypeDescriptionPage: BaseAppPage {
    // MARK: - Elements

    private var nextButton: XCUIElement {
        app.buttons["nextButton"].firstMatch
    }

    enum TypeDescriptions: String {
        case auth = "AUTH"
        case accountCheck = "ACCOUNTCHECK"
        case riskDec = "RISKDEC"
        case subscription = "SUBSCRIPTION"
        case threeDQuery = "THREEDQUERY"
    }

    // MARK: - Actions

    func select(typeDescriptions: [TypeDescriptions]) -> SelectTypeDescriptionPage {
        app.cells.staticTexts[typeDescriptions.map(\.rawValue).joined(separator: ", ")].tap()
        return self
    }

    func tapNextButton() {
        nextButton.tap()
    }
}
