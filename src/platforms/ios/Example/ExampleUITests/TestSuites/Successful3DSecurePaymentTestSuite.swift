import XCTest

class Successful3DSecurePaymentTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var authWith3DSecureV1FormPage = AuthWith3DSecureV1FormPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    let successfulMessage = "Payment has been successfully processed"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let cvvNumber = SharedTestCardData.cvvNumber
    let threeDSecureCode = SharedTestCardData.threeDSecureCode

    private func typeAndSubmit3DSecureCardDetails(with cardNumber: String) {
        mainPage.tapPayByCard3DSecure()
        payByCardFormPage.typeCardData(cardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapSubmit()
    }

    // MARK: Tests

    func test3DSecureV2FrictionlessPaymentByVisa() {
        let visaCardNumber = TestCards3DSecureV2.frictionlessVisaCardNumber

        typeAndSubmit3DSecureCardDetails(with: visaCardNumber)

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func test3DSecureV2FrictionlessPaymentByMasterCard() {
        let masterCardNumber = TestCards3DSecureV2.frictionlessMasterCardNumber

        typeAndSubmit3DSecureCardDetails(with: masterCardNumber)

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func test3DSecureV2FrictionlessPaymentByAmex() {
        let amexCardNumber = TestCards3DSecureV2.frictionlessAmexCardNumber
        let amexCvvNumber = SharedTestCardData.amexCvvNumber

        mainPage.tapPayByCard3DSecure()
        payByCardFormPage.typeCardData(amexCardNumber, expiryDateMonth, expiryDateYear, amexCvvNumber)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }
    
    // TODO: Fails on BS - investigate
//    func test3DSecureV2NonFrictionlessPaymentVisa() {
//        let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
//
//        typeAndSubmit3DSecureCardDetails(with: visaCardNumber)
//        authWith3DSecureV2FormPage.type(threeDSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func test3DSecureV1PaymentWithMasterCard() {
         let masterCardNumber = TestCards3DSecureV1.masterCardNumber

         typeAndSubmit3DSecureCardDetails(with: masterCardNumber)
         authWith3DSecureV1FormPage.waitUntilWebIsLoaded()
             .type(threeDSecureCode)
             .tapSubmit()

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                       "Alert with a message: '\(successfulMessage)' was not displayed.")
     }
      */

    func test3DSecureV1PassiveAuthenticationPaymentWithAmex() {
        let amexCardNumber = TestCards3DSecureV1.passiveAuthencticationAmexCardNumber
        let amexCvv = SharedTestCardData.amexCvvNumber

        mainPage.tapPayByCard3DSecure()
        payByCardFormPage.typeCardData(amexCardNumber, expiryDateMonth, expiryDateYear, amexCvv)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func test3DSecureV1PassiveAuthenticationPaymentWithJCB() {
        let jcbCardNumber = TestCards3DSecureV1.passiveAuthenticationJCBCardNumber

        typeAndSubmit3DSecureCardDetails(with: jcbCardNumber)

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }
}
