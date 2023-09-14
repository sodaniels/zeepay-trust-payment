import XCTest

class CustomPaymentFormTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    let successfulMessage = "Successful payment transaction"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let cvvNumber = SharedTestCardData.cvvNumber

    // MARK: Tests

    func testSuccesssfulFrictionlessPaymentByMasterCard() {
        let masterCardNumber = TestCards3DSecureV2.frictionlessMasterCardNumber

        mainPage.tapPayWithCustomForm()
        payByCardFormPage.typeCardData(masterCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }
    
    // TODO: Fails on BS - investigate
//    func testSuccessfulNonFrictionlessPaymentVisa() {
//        let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
//        let threeDSecureCode = SharedTestCardData.threeDSecureCode
//
//        mainPage.tapPayWithCustomForm()
//        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//            .tapSubmit()
//        authWith3DSecureV2FormPage.type(threeDSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }
}
