import XCTest

class Failed3DSecurePaymentTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var authWith3DSecureV1FormPage = AuthWith3DSecureV1FormPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    let unauthenticatedErrorMessage = "An error occurred: Unauthenticated"
    let bankSystemErrorMessage = "An error occurred: Bank System Error"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let cvvNumber = SharedTestCardData.cvvNumber

    private func typeAndSubmit3DSecureCardDetails(with cardNumber: String) {
        mainPage.tapPayByCard3DSecure()
        payByCardFormPage.typeCardData(cardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapSubmit()
    }

    // MARK: Tests

    func test3DSecureV2FrictionlessPaymentWithVisa() {
        let visaCardNumber = TestCards3DSecureV2.unauthenticatedErrorVisaCardNumber

        typeAndSubmit3DSecureCardDetails(with: visaCardNumber)

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: unauthenticatedErrorMessage),
                      "Alert with a message: '\(unauthenticatedErrorMessage)' was not displayed.")
    }

    func testDiscard3DSecureV2NonFrictionlessPaymentWithVisa() {
        let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
        let generalErrorMessage = "An error occurred"

        typeAndSubmit3DSecureCardDetails(with: visaCardNumber)
        authWith3DSecureV2FormPage.tapCancelButton()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: generalErrorMessage),
                      "Alert with a message: '\(generalErrorMessage)' was not displayed.")
    }

    func test3DSecureV2BankSystemErrorPaymentWithVisa() {
        let visaCardNumber = TestCards3DSecureV2.bankSystemErrorVisaCardNumber

        typeAndSubmit3DSecureCardDetails(with: visaCardNumber)

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: bankSystemErrorMessage),
                      "Alert with a message: '\(bankSystemErrorMessage)' was not displayed.")
    }

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func test3DSecureV1UnauthenticatedPaymentWithVisa() {
         let visaCardNumber = TestCards3DSecureV1.unauthenticatedErrorVisaCardNumber
         let threeDSecureCode = SharedTestCardData.threeDSecureCode

         typeAndSubmit3DSecureCardDetails(with: visaCardNumber)
         authWith3DSecureV1FormPage.waitUntilWebIsLoaded()
             .type(threeDSecureCode)
             .tapSubmit()

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: unauthenticatedErrorMessage),
                       "Alert with a message: '\(unauthenticatedErrorMessage)' was not displayed.")
     }

     func test3DSecureV1BankSystemErrorPaymentWithDiscover() {
         let discoverCardNumber = TestCards3DSecureV1.bankSystemErrorDiscoverCardNumber

         typeAndSubmit3DSecureCardDetails(with: discoverCardNumber)

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: bankSystemErrorMessage),
                       "Alert with a message: '\(bankSystemErrorMessage)' was not displayed.")
     }
      */
}
