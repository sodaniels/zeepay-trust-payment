import XCTest

class TokenisationFlowTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var storedCardPage = StoredCardPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    let successfulMessage = "Payment has been successfully processed"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
    let cvvNumber = SharedTestCardData.cvvNumber
    let validSecureCode = SharedTestCardData.threeDSecureCode
    let visaReference = SharedTestCardData.visaReference

    // MARK: Tear down

    override func tearDown() {
        payByCardFormPage.dismissAlert()
        super.tearDown()
    }

    // MARK: Tests
    
    // TODO: Fails on BS - investigate
//    func testPaymentWithSavedCardVisa() {
//        mainPage.tapStoredCard()
//        storedCardPage.tapAddPaymentMethod()
//        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//            .tapAddCard()
//            .dismissAlert()
//        storedCardPage.tapOnSavedCard(visaReference)
//            .tapNextButton()
//        payByCardFormPage.type(cvvNumber: cvvNumber)
//            .tapSubmit()
//        authWith3DSecureV2FormPage.type(validSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }

    // TODO: Fails on BS - investigate
//    func testPaymentWithSavedCardAmex() {
//        let amexCardNumber = TestCards3DSecureV2.frictionlessAmexCardNumber
//        let amexCvvNumber = SharedTestCardData.amexCvvNumber
//        let amexReference = SharedTestCardData.amexReference
//
//        mainPage.tapStoredCard()
//        storedCardPage.tapAddPaymentMethod()
//        payByCardFormPage.typeCardData(amexCardNumber, expiryDateMonth, expiryDateYear, amexCvvNumber)
//            .tapAddCard()
//            .dismissAlert()
//        storedCardPage.tapOnSavedCard(amexReference)
//            .tapNextButton()
//        payByCardFormPage.type(cvvNumber: amexCvvNumber)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }
    
    // TODO: Fails on BS - investigate
//    func testSuccessfulPaymentWithSavedCardFollowedByFailure() {
//        let invalidVisaCardNumber = TestCards3DSecureV2.bankSystemErrorVisaCardNumber
//        let masterCardNumber = TestCards3DSecureV2.nonFrictionlessMasterCardNumber
//        let masterCardReference = SharedTestCardData.masterCardReference
//
//        mainPage.tapStoredCard()
//        storedCardPage.tapAddPaymentMethod()
//        payByCardFormPage.typeCardData(invalidVisaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//            .tapAddCard()
//            .dismissAlert()
//        storedCardPage.tapAddPaymentMethod()
//        payByCardFormPage.typeCardData(masterCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//            .tapAddCard()
//            .dismissAlert()
//        storedCardPage.tapOnSavedCard(visaReference)
//            .tapNextButton()
//        payByCardFormPage.type(cvvNumber: cvvNumber)
//            .tapSubmit()
//        waitUntilCanInteract(with: payByCardFormPage.closeAlertButton)
//        payByCardFormPage.dismissAlert()
//            .goBack()
//        storedCardPage.tapOnSavedCard(masterCardReference)
//            .tapNextButton()
//        payByCardFormPage.type(cvvNumber: cvvNumber)
//            .tapSubmit()
//        authWith3DSecureV2FormPage.type(validSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }
}
