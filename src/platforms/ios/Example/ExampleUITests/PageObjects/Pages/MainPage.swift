import XCTest

final class MainPage: BaseAppPage {
    // MARK: - Elements

    private var payByCard3DSecure: XCUIElement {
        app.cells["payWith3DSecureButton"].firstMatch
    }

    private var payByCardNo3DSecure: XCUIElement {
        app.cells["payWithout3DSecureButton"].firstMatch
    }

    private var storedCard: XCUIElement {
        app.cells["showStoredCardViewButton"].firstMatch
    }

    private var payByCardAndSave: XCUIElement {
        app.cells["payWithCustomForm"].firstMatch
    }

    private var payByCardAndAddTip: XCUIElement {
        app.cells["payWithAddingTipButton"].firstMatch
    }

    private var payByCardWithJWTUpdates: XCUIElement {
        app.cells["payWithJWTUpdatesButton"].firstMatch
    }

    private var payByCardWithBypass: XCUIElement {
        app.cells["payWithBypassCard"].firstMatch
    }

    private var payWithCustomForm: XCUIElement {
        app.cells["payWithCustomFormButton"].firstMatch
    }

    private var storedCardsWithBypass: XCUIElement {
        app.cells["showStoredCardWithBypassFlowButton"].firstMatch
    }

    private var payWithApplePay: XCUIElement {
        app.cells["payWithApplePayButton"].firstMatch
    }

    private var payWithForwardedThreeDResponse: XCUIElement {
        app.cells["payWithForwardedThreeDResponse"].firstMatch
    }

    private var payWithForwardedPares: XCUIElement {
        app.cells["payWithForwardedPares"].firstMatch
    }

    // swiftlint:disable:next identifier_name
    private var accountCheckAndPayWithForwardedThreeDResponse: XCUIElement {
        app.cells["performAccountCheckAndPayWithForwardedThreeDResponse"].firstMatch
    }

    private var accountCheckAndPayWithForwardedPares: XCUIElement {
        app.cells["performAccountCheckAndPayWithForwardedPares"].firstMatch
    }

    private var performAuthWithZip: XCUIElement {
        app.cells["performAuthZIP"].firstMatch
    }
    
    private var performAuthWithATA: XCUIElement {
        app.cells["performAuthATA"].firstMatch
    }
    
    private var payFormWithATA: XCUIElement {
        app.cells["payWithCardATA"].firstMatch
    }

    func transactionResultAlert(with alertText: String) -> XCUIElement {
        app.alerts.staticTexts[alertText].firstMatch
    }
    
    // MARK: - Actions

    func tapPayByCard3DSecure() {
        payByCard3DSecure.tap()
    }

    func tapPayByCardNo3DSecure() {
        payByCardNo3DSecure.tap()
    }

    func tapStoredCard() {
        storedCard.tap()
    }

    func tapPayByCardAndSave() {
        payByCardAndSave.tap()
    }

    func tapPayByCardAndAddTip() {
        payByCardAndAddTip.tap()
    }

    func tapPayByCardWithJWTUpdates() {
        payByCardWithJWTUpdates.tap()
    }

    func tapPayByCardWithBypass() {
        payByCardWithBypass.tap()
    }

    func tapPayWithCustomForm() {
        payWithCustomForm.tap()
    }

    func tapStoredCardsWithBypass() {
        storedCardsWithBypass.tap()
    }

    func tapPayWithApplePay() {
        payWithApplePay.tap()
    }

    func tapPayWithForwardedThreeDResponse() {
        payWithForwardedThreeDResponse.tap()
    }

    func tapPayWithForwardedPares() {
        payWithForwardedPares.tap()
    }

    func tapAccountCheckAndPayWithForwardedThreeDResponse() {
        accountCheckAndPayWithForwardedThreeDResponse.tap()
    }

    func tapAccountCheckAndPayWithForwardedPares() {
        accountCheckAndPayWithForwardedPares.tap()
    }
    
    func tapPerformAuthWithZip() {
        performAuthWithZip.tap()
    }
    
    func tapPerformAuthWithATA() {
        performAuthWithATA.tap()
    }
    
    func tapPayFormWithATA() {
        payFormWithATA.tap()
        app.buttons["ATAButton"].tap()
    }

    // MARK: - Helpers

    func isAlertDiplayed(with alertText: String) -> Bool {
        transactionResultAlert(with: alertText).waitForExistence(timeout: DefaultTestTimeouts.transactionResultAlertDisplayed)
    }
}
