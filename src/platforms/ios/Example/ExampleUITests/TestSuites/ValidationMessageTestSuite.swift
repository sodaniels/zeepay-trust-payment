import XCTest

class ValidationMessageTestSuite: BaseTestCase {
    // MARK: Properties

    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    let validationMessage = "Invalid field"
    let expiryDateMonth = SharedTestCardData.expiryDateMonth
    let expiryDateYear = SharedTestCardData.expiryDateYear

    // MARK: Tests

    func testEmptyFieldsValidation() {
        mainPage.tapPayByCardNo3DSecure()
        payByCardFormPage.tapCreditCardInput()
            .tapExpiryDateInput()
            .tapCvvInput()

        XCTAssertEqual(payByCardFormPage.getCreditCardValidationMessage, validationMessage,
                       "Credit card validation message is not correct")

        XCTAssertEqual(payByCardFormPage.getExpiryDateValidationMessage, validationMessage,
                       "Expiration date validation message is not correct")
        payByCardFormPage.tapCreditCardInput() // triggers validation message in CVV input

        XCTAssertEqual(payByCardFormPage.getCvvValidationMessage, validationMessage,
                       "Cvv validation message is not correct")

        XCTAssertFalse(payByCardFormPage.isSubmitButtonEnabled,
                       "Submit button is not disabled")
    }

    func testIncorrectFieldValidation() {
        let incorrectCardNumber = SharedTestCardData.incorrectCardNumber
        let expiryDateMonth = SharedTestCardData.expiryDateMonth
        let expiryDateYear = SharedTestCardData.expiryDateYear
        let incorrectCvvNumber = SharedTestCardData.incorrectCvvNumber

        mainPage.tapPayByCardNo3DSecure()
        payByCardFormPage.typeCardData(incorrectCardNumber, expiryDateMonth, expiryDateYear, incorrectCvvNumber)
            .tapCreditCardInput()

        XCTAssertEqual(payByCardFormPage.getCreditCardValidationMessage, validationMessage,
                       "Credit card validation message is not correct")

        XCTAssertEqual(payByCardFormPage.getCvvValidationMessage, validationMessage,
                       
                       "Cvv validation message is not correct")
        XCTAssertFalse(payByCardFormPage.isSubmitButtonEnabled,
                       "Submit button is not disabled")
    }

    func testInvalidThreeDigitCvvForAmexCard() {
        let amexCardNumber = TestCards3DSecureV2.frictionlessAmexCardNumber
        let incorrectAmexCvvNumber = SharedTestCardData.incorrectAmexCvvNumber

        mainPage.tapPayByCardNo3DSecure()
        payByCardFormPage.typeCardData(amexCardNumber, expiryDateMonth, expiryDateYear, incorrectAmexCvvNumber)
            .tapCreditCardInput()

        XCTAssertEqual(payByCardFormPage.getCvvValidationMessage, validationMessage,
                       "Cvv validation message is not correct")
    }
}
