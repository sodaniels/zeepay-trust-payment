import XCTest

class BypassWithTokenisationTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var authWith3DSecureV1FormPage = AuthWith3DSecureV1FormPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    lazy var selectCardToBypassPage = SelectCardToBypassPage(application: self.app)
    lazy var storedCardPage = StoredCardPage(application: self.app)
    let successfulMessage = "Payment has been successfully processed"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let cvvNumber = SharedTestCardData.cvvNumber
    let threeDSecureCode = SharedTestCardData.threeDSecureCode
    let masterCardReference = SharedTestCardData.masterCardReference
    let visaReference = SharedTestCardData.visaReference
    let masterCard = SharedTestCardData.bypassMasterCard
    let visa = SharedTestCardData.bypassVisa

    // MARK: Tear down

    override func tearDown() {
        payByCardFormPage.dismissAlert()
        super.tearDown()
    }

    // MARK: Tests

    // TODO: Fails on BS - investigate
//    func test3DSecureV2PaymentWithBypassedThreeDQueryForAccountCheck() {
//        let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
//
//        mainPage.tapStoredCardsWithBypass()
//        selectCardToBypassPage.tapNextButton()
//        storedCardPage.tapAddPaymentMethod()
//        selectCardToBypassPage.selectBypassCard(visa)
//            .tapNextButton()
//        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//            .tapAddCard()
//        waitUntilCanInteract(with: payByCardFormPage.closeAlertButton)
//        payByCardFormPage.dismissAlert()
//        storedCardPage.tapOnSavedCard(visaReference)
//            .tapNextButton()
//        payByCardFormPage.type(cvvNumber: cvvNumber)
//            .tapSubmit()
//        authWith3DSecureV2FormPage.type(threeDSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }

    func test3DSecureV2PaymentWithBypassedThreeDQueryForAccountCheckAndAuth() {
        let masterCardNumber = TestCards3DSecureV2.nonFrictionlessMasterCardNumber

        mainPage.tapStoredCardsWithBypass()
        selectCardToBypassPage.selectBypassCard(masterCard)
            .tapNextButton()
        storedCardPage.tapAddPaymentMethod()
        selectCardToBypassPage.selectBypassCard(masterCard)
            .tapNextButton()
        payByCardFormPage.typeCardData(masterCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapAddCard()
        waitUntilCanInteract(with: payByCardFormPage.closeAlertButton)
        payByCardFormPage.dismissAlert()
        storedCardPage.tapOnSavedCard(masterCardReference)
            .tapNextButton()
        payByCardFormPage.type(cvvNumber: cvvNumber)
            .tapSubmit()

        XCTAssertFalse(authWith3DSecureV2FormPage.is3DSecureFormDisplayed(), "3DSecure form was displayed for payment with bypassed card.")

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func test3DSecureV1PaymentWithBypassedThreeDQueryForAccountCheck() {
         let masterCardNumber = TestCards3DSecureV1.masterCardNumber

         mainPage.tapStoredCardsWithBypass()
         selectCardToBypassPage.tapNextButton()
         storedCardPage.tapAddPaymentMethod()
         selectCardToBypassPage.selectBypassCard(masterCard)
             .tapNextButton()
         payByCardFormPage.typeCardData(masterCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
             .tapAddCard()
         waitUntilCanInteract(with: payByCardFormPage.closeAlertButton)
         payByCardFormPage.dismissAlert()
         storedCardPage.tapOnSavedCard(masterCardReference)
             .tapNextButton()
         payByCardFormPage.type(cvvNumber: cvvNumber)
             .tapSubmit()
         authWith3DSecureV1FormPage.waitUntilWebIsLoaded()
             .type(threeDSecureCode)
             .tapSubmit()

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                       "Alert with a message: '\(successfulMessage)' was not displayed.")
     }
      */

    func test3DSecureV1PaymentWithBypassedThreeDQueryForAccountCheckAndAuth() {
        let discoverCardNumber = TestCards3DSecureV1.bankSystemErrorDiscoverCardNumber
        let discoverReference = SharedTestCardData.discoverReference
        let discoverCard = SharedTestCardData.bypassDiscover

        mainPage.tapStoredCardsWithBypass()
        selectCardToBypassPage.selectBypassCard(discoverCard)
            .tapNextButton()
        storedCardPage.tapAddPaymentMethod()
        selectCardToBypassPage.selectBypassCard(discoverCard)
            .tapNextButton()
        payByCardFormPage.typeCardData(discoverCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapAddCard()
        waitUntilCanInteract(with: payByCardFormPage.closeAlertButton)
        payByCardFormPage.dismissAlert()
        storedCardPage.tapOnSavedCard(discoverReference)
            .tapNextButton()
        payByCardFormPage.type(cvvNumber: cvvNumber)
            .tapSubmit()

        XCTAssertFalse(authWith3DSecureV1FormPage.is3DSecureFormDisplayed(), "3DSecure form was displayed for payment with bypassed card.")

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }
}
