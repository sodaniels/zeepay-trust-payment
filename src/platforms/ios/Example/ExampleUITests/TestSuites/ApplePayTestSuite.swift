import XCTest

class ApplePayTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var mainPage = MainPage(application: self.app)
    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var applePayActivityViewPage = ApplePayActivityViewPage(application: self.app)
    lazy var selectTypeDescriptionPage = SelectTypeDescriptionPage(application: self.app)
    let successfulMessage = "Payment has been successfully processed"

    private func performApplePayTransaction(with combination: [SelectTypeDescriptionPage.TypeDescriptions]) {
        mainPage.tapPayWithApplePay()
        selectTypeDescriptionPage.select(typeDescriptions: combination)
            .tapNextButton()
        payByCardFormPage.tapApplePay()
        applePayActivityViewPage.tapPayWithPasscode()
            .typePasscode()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    // MARK: Tests

    // Tests marked as disabled should be activated in task MSDK-353
    func disable_testAuthTypeDescription() {
        performApplePayTransaction(with: [.auth])
    }

    func disable_testAccountCheckAndAuthTypeDescriptions() {
        performApplePayTransaction(with: [.accountCheck, .auth])
    }

    func disable_testRiskDecAndAuthTypeDescriptions() {
        performApplePayTransaction(with: [.riskDec, .auth])
    }

    func disable_testAuthAndRiskDecTypeDescriptions() {
        performApplePayTransaction(with: [.auth, .riskDec])
    }

    func disable_testRiskDecAndAuthAndSubscriptionTypeDescriptions() {
        performApplePayTransaction(with: [.riskDec, .auth, .subscription])
    }

    func disable_testRiskDecAndAccountCheckAndAuthTypeDescriptions() {
        performApplePayTransaction(with: [.riskDec, .accountCheck, .auth])
    }

    func disable_testAccountCheckAndSubscriptionTypeDescriptions() {
        performApplePayTransaction(with: [.accountCheck, .subscription])
    }

    func disable_testAuthAndSubcriptionTypeDescriptions() {
        performApplePayTransaction(with: [.auth, .subscription])
    }

    func disable_testRiskDecAndAccountCheckAndAuthAndSubscriptionTypeDescriptions() {
        performApplePayTransaction(with: [.riskDec, .accountCheck, .auth, .subscription])
    }

    func disable_testThreeDQueryAndAuthTypeDescriptions() {
        performApplePayTransaction(with: [.threeDQuery, .auth])
    }

    func testThreeDQueryTypeDescriptions() {
        mainPage.tapPayWithApplePay()
        selectTypeDescriptionPage.select(typeDescriptions: [.threeDQuery])
            .tapNextButton()

        XCTAssertFalse(payByCardFormPage.isApplePayButtonAvailable(),
                       "Apple Pay button is available for type description: THREEDQUERY.")
    }

    // This test runs on real device on BrowserStack, Apple Pay configuration is not available there, nor Apple Pay functionality.
//    func testDiscardingApplePayActivityView() {
//        mainPage.tapPayWithApplePay()
//        selectTypeDescriptionPage.select(typeDescriptions: [.auth])
//            .tapNextButton()
//        payByCardFormPage.tapApplePay()
//        applePayActivityViewPage.tapCancel()
//
//        XCTAssertTrue(payByCardFormPage.isPayByCardFormDisplayed(),
//                      "'Pay by card' form was not displayed when discarded Apple Pay.")
//    }
}
