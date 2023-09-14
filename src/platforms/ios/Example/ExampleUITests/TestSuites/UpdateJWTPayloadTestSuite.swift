import XCTest

class UpdateJWTPayloadTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var mainPage = MainPage(application: self.app)
    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var storedCardPage = StoredCardPage(application: self.app)
    lazy var authWith3DSecureV1FormPage = AuthWith3DSecureV1FormPage(application: self.app)
    lazy var authWith3DSecureV2FormPage = AuthWith3DSecureV2FormPage(application: self.app)
    let successfulMessage = "Payment has been successfully processed"
    let successfulRequestMessage = "The request has been successfully completed"
    let customAuthErrorMessage = "An error occurred: Invalid process: RULE - if an ECOM AUTH and parent is a THREEDQUERY - AUTH INVALID PROCESS"
    let cvvNumber = SharedTestCardData.cvvNumber
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear
    let visaCardNumber = TestCards3DSecureV2.frictionlessVisaCardNumber
    let threeDSecureCode = SharedTestCardData.threeDSecureCode

    private func typeBaseAmountAndSubmit3DSecureForm(with baseAmount: String) {
        payByCardFormPage.type(baseAmount)
            .tapSubmit()
        authWith3DSecureV2FormPage.type(threeDSecureCode)
            .tapSubmit()
    }

    // MARK: Helpers

    var uniqueSuffix: Int { Int(Date.timeIntervalSinceReferenceDate) }

    let billingName = "Steven Testing"
    let billingStreet = "91 Western Road"
    let billingCity = "Brighton"
    let billingPostcode = "BN1 2NW"
    let billingCounty = "East Sussex"
    let billingCountryIso = "GB"
    let deliveryName = "Steven Testing"
    let deliveryStreet = "66 St Andrews Lane"
    let deliveryCity = "Birmingham"
    let deliveryPostcode = "BN2 2NW"
    var deliveryCounty: String {
        "iOS E2E Auto Tests \(uniqueSuffix)"
    }

    let deliveryCountryIso = "GB"

    // MARK: Tests

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func testPaymentAndSaveCardForFutureUseWithAmex() {
         let amexCardNumber = TestCards3DSecureV2.frictionlessAmexCardNumber
         let cvvNumber = SharedTestCardData.amexCvvNumber

         mainPage.tapPayByCardAndSave()
         payByCardFormPage.typeCardData(amexCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
             .tapSaveCard()
             .tapSubmit()

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                       "Alert with a message: '\(successfulMessage)' was not displayed.")
         payByCardFormPage.dismissAlert()
         mainPage.tapStoredCard()

         XCTAssertTrue(storedCardPage.isAmexCardSaved,
                       "Card reference was not saved.")
     }
      */

    func testPaymentAndAddTipWithDiscover() {
        let discoverCardNumber = TestCards3DSecureV2.frictionlessDiscoverCardNumber

        mainPage.tapPayByCardAndAddTip()
        payByCardFormPage.typeCardData(discoverCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .tapTipSwitch()
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func testPaymentWithMandatoryAndOptionalFieldsWithVisa() {
        mainPage.tapPayByCardWithJWTUpdates()
        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .typeBillingData(billingName, billingStreet, billingCity, billingPostcode, billingCounty, billingCountryIso)
            .typeDeliveryData(deliveryName, deliveryStreet, deliveryCity, deliveryPostcode, deliveryCounty, deliveryCountryIso)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func testPaymentWithMandatoryAndCustomOptionalFieldsWithMasterCard() {
        let masterCardNumber = TestCards3DSecureV2.frictionlessMasterCardNumber
        let mainAmount = TestAmounts.mainAmountExampleValue

        mainPage.tapPayByCardWithJWTUpdates()
        payByCardFormPage.typeCardData(masterCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .typeBillingData(billingName, billingStreet, billingCity, billingPostcode, billingCounty, billingCountryIso)
            .typeDeliveryData(deliveryName, deliveryStreet, deliveryCity, deliveryPostcode, deliveryCounty, deliveryCountryIso)
            .selectMainAmount()
            .type(mainAmount)
            .selectUSDCurrency()
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }

    func testPaymentWithMandatoryFieldsAndInvalidAmountWithVisa() {
        let invalidBaseAmount = TestAmounts.invalidBaseAmountValue
        let invalidBaseAmountErrorMessage = "Invalid field: baseamount"

        mainPage.tapPayByCardWithJWTUpdates()
        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
            .type(invalidBaseAmount)
            .tapSubmit()

        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: invalidBaseAmountErrorMessage),
                      "Alert with a message: '\(invalidBaseAmountErrorMessage)' was not displayed.")
    }
    
    // TODO: Fails on BS - investigate
//    func testPaymentWithForwardedThreeDResponse() {
//        mainPage.tapPayWithForwardedThreeDResponse()
//        authWith3DSecureV2FormPage.type(threeDSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulRequestMessage),
//                      "Alert with a message: '\(successfulRequestMessage)' was not displayed.")
//    }

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func testPaymentWithForwardedPares() {
         mainPage.tapPayWithForwardedPares()
         authWith3DSecureV1FormPage.waitUntilWebIsLoaded()
             .type(threeDSecureCode)
             .tapSubmit()

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulRequestMessage),
                       "Alert with a message: '\(successfulRequestMessage)' was not displayed.")
     }
      */
    
    // TODO: Fails on BS - investigate
//    func testPaymentWithAccountCheckAndForwardedThreeDResponse() {
//        mainPage.tapAccountCheckAndPayWithForwardedThreeDResponse()
//        authWith3DSecureV2FormPage.type(threeDSecureCode)
//            .tapSubmit()
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulRequestMessage),
//                      "Alert with a message: '\(successfulRequestMessage)' was not displayed.")
//    }

    /* TODO: Commented out due to the issue with cardinal v1 test card numbers
     func testPaymentWithAccountCheckAndForwardedPares() {
         mainPage.tapAccountCheckAndPayWithForwardedPares()
         authWith3DSecureV1FormPage.waitUntilWebIsLoaded()
             .type(threeDSecureCode)
             .tapSubmit()

         XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulRequestMessage),
                       "Alert with a message: '\(successfulRequestMessage)' was not displayed.")
     }
     */
    
    // TODO: Fails on BS - investigate
//    func test3DSecureV2WithCustomAuthErrorAndRetry() {
//        let visaCardNumber = TestCards3DSecureV2.nonFrictionlessVisaCardNumber
//        let invalidBaseAmount = TestAmounts.triggerAuthErrorBaseAmountValue
//        let baseAmount = TestAmounts.defaultBaseAmountValue
//
//        mainPage.tapPayByCardWithJWTUpdates()
//        payByCardFormPage.typeCardData(visaCardNumber, expiryDateMonth, expiryDateYear, cvvNumber)
//        typeBaseAmountAndSubmit3DSecureForm(with: invalidBaseAmount)
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: customAuthErrorMessage),
//                      "Alert with a message: '\(customAuthErrorMessage)' was not displayed.")
//
//        // In case of the "retry" JWT is being overwritten. The entire transaction including TDQ & AUTH starts again.
//        payByCardFormPage.dismissAlert()
//        typeBaseAmountAndSubmit3DSecureForm(with: baseAmount)
//
//        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
//                      "Alert with a message: '\(successfulMessage)' was not displayed.")
//    }
}
