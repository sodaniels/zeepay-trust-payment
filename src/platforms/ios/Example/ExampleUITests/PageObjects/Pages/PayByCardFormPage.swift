import XCTest

final class PayByCardFormPage: BaseAppPage {
    // MARK: Elements

    private var cardNumberInput: XCUIElement {
        app.textFields["st-card-number-input-textfield"].firstMatch
    }

    private var monthInput: XCUIElement {
        app.textFields["st-expiration-date-input-textfield"].firstMatch
    }

    private var datePicker: XCUIElement {
        app.pickers["st-expiration-date-picker"].firstMatch
    }

    private var cvvInput: XCUIElement {
        app.secureTextFields["st-security-code-input-textfield"].firstMatch
    }

    private var submitButton: XCUIElement {
        app.buttons["payButton"].firstMatch
    }

    private var addCardButton: XCUIElement {
        app.buttons["addCardButton"].firstMatch
    }

    private var creditCardValidationMessage: XCUIElement {
        app.staticTexts["st-card-number-message"].firstMatch
    }

    private var expiryDateValidationMessage: XCUIElement {
        app.staticTexts["st-expiration-date-message"].firstMatch
    }

    private var cvvValidationMessage: XCUIElement {
        app.staticTexts["st-security-code-input-message"].firstMatch
    }

    private var cardNumberFieldLabel: XCUIElement {
        app.staticTexts["cardNumberFieldLabel"].firstMatch
    }

    private var expiryDateFieldLabel: XCUIElement {
        app.staticTexts["expDateFieldLabel"].firstMatch
    }

    private var cvvFieldLabel: XCUIElement {
        app.staticTexts["cvvFieldLabel"].firstMatch
    }

    func transactionResultAlert(with alertText: String) -> XCUIElement {
        app.alerts.staticTexts[alertText].firstMatch
    }

    var closeAlertButton: XCUIElement {
        app.alerts.buttons["Ok"]
    }

    private var saveCardSwitch: XCUIElement {
        app.switches["saveCardSwitch"].firstMatch
    }

    private var tipSwitch: XCUIElement {
        app.switches["tipSwitch"].firstMatch
    }

    private var billingNameInput: XCUIElement {
        app.textFields["billingName"].firstMatch
    }

    private var billingStreetInput: XCUIElement {
        app.textFields["billingStreet"].firstMatch
    }

    private var billingCityInput: XCUIElement {
        app.textFields["billingCity"].firstMatch
    }

    private var billingPostcodeInput: XCUIElement {
        app.textFields["billingPostcode"].firstMatch
    }

    private var billingCountyInput: XCUIElement {
        app.textFields["billingCounty"].firstMatch
    }

    private var billingCountryIsoInput: XCUIElement {
        app.textFields["billingCountryIso"].firstMatch
    }

    private var deliveryNameInput: XCUIElement {
        app.textFields["deliveryName"].firstMatch
    }

    private var deliveryStreetInput: XCUIElement {
        app.textFields["deliveryStreet"].firstMatch
    }

    private var deliveryCityInput: XCUIElement {
        app.textFields["deliveryCity"].firstMatch
    }

    private var deliveryPostcodeInput: XCUIElement {
        app.textFields["deliveryPostcode"].firstMatch
    }

    private var deliveryCountyInput: XCUIElement {
        app.textFields["deliveryCounty"].firstMatch
    }

    private var deliveryCountryIsoInput: XCUIElement {
        app.textFields["deliveryCountryIso"].firstMatch
    }

    private var amountInput: XCUIElement {
        app.textFields["amountInput"].firstMatch
    }

    private var baseAmountButton: XCUIElement {
        app.buttons["baseamount"].firstMatch
    }

    private var mainAmountButton: XCUIElement {
        app.buttons["mainamount"].firstMatch
    }

    private var currencyGBPButton: XCUIElement {
        app.buttons["GBP"].firstMatch
    }

    private var currencyUSDButton: XCUIElement {
        app.buttons["USD"].firstMatch
    }

    private var applePayButton: XCUIElement {
        app.buttons["applePay"].firstMatch
    }

    private var backButton: XCUIElement {
        app.navigationBars.staticTexts["Back"].firstMatch
    }
    
    private var zipButton: XCUIElement {
        app.buttons["zipButton"].firstMatch
    }
    
    // MARK: Actions

    @discardableResult
    func typeCardData(_ cardNumber: String, _ expiryDateMonth: String, _ expiryDateYear: String, _ cvvNumber: String) -> PayByCardFormPage {
        waitUntilFormIsVisible()
        type(cardNumber: cardNumber)
        type(month: expiryDateMonth, year: expiryDateYear)
        type(cvvNumber: cvvNumber)
        return self
    }

    @discardableResult
    func typeBillingData(_ billingName: String, _ billingStreet: String, _ billingCity: String, _ billingPostcode: String, _ billingCounty: String, _ billingCountryIso: String) -> PayByCardFormPage {
        type(into: billingNameInput, value: billingName)
        type(into: billingStreetInput, value: billingStreet)
        type(into: billingCityInput, value: billingCity)
        type(into: billingPostcodeInput, value: billingPostcode)
        type(into: billingCountyInput, value: billingCounty)
        type(into: billingCountryIsoInput, value: billingCountryIso)
        return self
    }

    @discardableResult
    func typeDeliveryData(_ deliveryName: String, _ deliveryStreet: String, _ deliveryCity: String, _ deliveryPostcode: String, _ deliveryCounty: String, _ deliveryCountryIso: String) -> PayByCardFormPage {
        type(into: deliveryNameInput, value: deliveryName)
        type(into: deliveryStreetInput, value: deliveryStreet)
        type(into: deliveryCityInput, value: deliveryCity)
        type(into: deliveryPostcodeInput, value: deliveryPostcode)
        type(into: deliveryCountyInput, value: deliveryCounty)
        type(into: deliveryCountryIsoInput, value: deliveryCountryIso)
        return self
    }

    @discardableResult
    func type(cardNumber: String) -> PayByCardFormPage {
        cardNumberInput.tap()
        cardNumberInput.typeText(cardNumber)
        cardNumberInput.typeText("\n")
        return self
    }

    @discardableResult
    func type(month: String, year: String) -> PayByCardFormPage {
        monthInput.tap()

        let monthPredicate = NSPredicate(format: "value BEGINSWITH 'Month'")
        let monthPicker = app.pickerWheels.element(matching: monthPredicate)
        monthPicker.adjust(toPickerWheelValue: month)

        let yearPredicate = NSPredicate(format: "value BEGINSWITH 'Year'")
        let yearPicker = app.pickerWheels.element(matching: yearPredicate)
        yearPicker.adjust(toPickerWheelValue: year)

        return self
    }

    @discardableResult
    func type(cvvNumber: String) -> PayByCardFormPage {
        waitUntilFormIsVisible()
        cvvInput.tap()
        cvvInput.typeText(cvvNumber)
        cvvInput.typeText("\n")
        return self
    }

    @discardableResult
    func type(into component: XCUIElement, value: String) -> PayByCardFormPage {
        component.tap()
        component.typeText(value)
        component.typeText("\n")
        return self
    }

    @discardableResult
    func tapCreditCardInput() -> PayByCardFormPage {
        cardNumberInput.tap()
        return self
    }

    @discardableResult
    func tapExpiryDateInput() -> PayByCardFormPage {
        monthInput.tap()
        return self
    }

    @discardableResult
    func tapCvvInput() -> PayByCardFormPage {
        cvvInput.tap()
        return self
    }

    @discardableResult
    func tapSubmit() -> PayByCardFormPage {
        submitButton.tap()
        return self
    }

    @discardableResult
    func tapAddCard() -> PayByCardFormPage {
        addCardButton.tap()
        return self
    }

    @discardableResult
    func dismissAlert() -> PayByCardFormPage {
        closeAlertButton.tap()
        return self
    }

    func tapSaveCard() -> PayByCardFormPage {
        // Coordinates are used because on iPad switch button container size is way to long.
        // tap() action hits the element right in the middle, which in case of the iPad is to
        // the right side of the actual switch button.
        saveCardSwitch.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
        return self
    }

    func tapTipSwitch() -> PayByCardFormPage {
        tipSwitch.tap()
        return self
    }

    func selectBaseAmount() -> PayByCardFormPage {
        baseAmountButton.tap()
        return self
    }

    func selectMainAmount() -> PayByCardFormPage {
        mainAmountButton.tap()
        return self
    }

    func selectGBPCurrency() -> PayByCardFormPage {
        currencyGBPButton.tap()
        return self
    }

    func selectUSDCurrency() -> PayByCardFormPage {
        currencyUSDButton.tap()
        return self
    }

    @discardableResult
    func type(_ amount: String) -> PayByCardFormPage {
        amountInput.tap()
        amountInput.clearText()
        amountInput.typeText(amount)
        return self
    }

    @discardableResult
    func tapApplePay() -> PayByCardFormPage {
        applePayButton.tap()
        return self
    }

    func tapZipButton() {
        zipButton.tap()
    }
    
    // MARK: Helpers

    var getCreditCardValidationMessage: String {
        creditCardValidationMessage.label
    }

    var getExpiryDateValidationMessage: String {
        expiryDateValidationMessage.label
    }

    var getCvvValidationMessage: String {
        cvvValidationMessage.label
    }

    var getCreditCardFieldLabel: String {
        cardNumberFieldLabel.label
    }

    var getExpiryDateFieldLabel: String {
        expiryDateFieldLabel.label
    }

    var getCvvFieldLabel: String {
        cvvFieldLabel.label
    }

    var getSubmitButtonLabel: String {
        submitButton.label
    }

    var isCvvFieldEnabled: Bool {
        cvvInput.isEnabled
    }

    var isSubmitButtonEnabled: Bool {
        submitButton.isEnabled
    }

    func isAlertDiplayed(with alertText: String) -> Bool {
        transactionResultAlert(with: alertText).waitForExistence(timeout: DefaultTestTimeouts.transactionResultAlertDisplayed)
    }

    func isPayByCardFormDisplayed() -> Bool {
        cardNumberInput.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
    }

    func isApplePayButtonAvailable() -> Bool {
        applePayButton.exists
    }

    @discardableResult
    func goBack() -> PayByCardFormPage {
        backButton.tap()
        return self
    }

    @discardableResult
    private func waitUntilFormIsVisible() -> Bool {
        cardNumberInput.waitForExistence(timeout: DefaultTestTimeouts.defaultSystemUiElementTimeout)
    }
}
