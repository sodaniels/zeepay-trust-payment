import XCTest

class BypassCardsTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    lazy var selectCardToBypassPage = SelectCardToBypassPage(application: self.app)
    let successfulMessage = "Payment has been successfully processed"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let cvvNumber = SharedTestCardData.cvvNumber

    // MARK: Tests

    func testPaymentWithVisaAndBypassedAllCards() {
        let visaCardNumber = TestCards3DSecureV2.frictionlessVisaCardNumber

        mainPage.tapPayByCardWithBypass()
        selectCardToBypassPage.selectAllCardTypes()
            .tapNextButton()
        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    // TODO: Fails on BS - investigate
//    func testPaymentWithNonBypassedMasterCard() {
//        let masterCardNumber = TestCards3DSecureV2.nonFrictionlessMasterCardNumber
//        let threeDSecureCode = SharedTestCardData.threeDSecureCode
//
//        mainPage.tapPayByCardWithBypass()
//        selectCardToBypassPage.selectAllCardsExceptOfMasterCard()
//            .tapNextButton()
//        payByCardFormPage.typeCardData(masterCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//            .tapSubmit()
//        authWith3DSecureV2FormPage.type(threeDSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }

    func testPaymentWithVisaAndBypassedOnlyVisa() {
        let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
        let visa = SharedTestCardData.bypassVisa

        mainPage.tapPayByCardWithBypass()
        selectCardToBypassPage.selectBypassCard(visa)
            .tapNextButton()
        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapSubmit()

        XCTAssertFalse(authWith3DSecureV2FormPage.is3DSecureFormDisplayed(), "3DSecure form was displayed for payment with bypassed card.")

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func testPaymentAttemptWithMaestroAndBypassedAllCards() {
        let maestroCardNumber = TestCards3DSecureV2.nonFrictionlessMaestroCardNumber
        let bypassedMaestroErrorMessage = "An error occurred: Maestro must use SecureCode"

        mainPage.tapPayByCardWithBypass()
        selectCardToBypassPage.selectAllCardTypes()
            .tapNextButton()
        payByCardFormPage.typeCardData(maestroCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: bypassedMaestroErrorMessage),
                      "Alert with a message: '\(bypassedMaestroErrorMessage)' was not displayed.")
    }
}
