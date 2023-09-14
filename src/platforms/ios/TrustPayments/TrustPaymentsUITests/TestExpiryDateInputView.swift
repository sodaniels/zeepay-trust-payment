//
//  TestExpiryDateInputView.swift
//  TrustPaymentsUITests
//

@testable import TrustPaymentsCard
@testable import TrustPaymentsUI
import XCTest

class TestExpiryDateInputView: XCTestCase {
    var sut: ExpiryDateInputView!
    override func setUp() {
        super.setUp()
        sut = ExpiryDateInputView()
    }

    func test_setSecureTextEntry() {
        sut.isSecuredTextEntry = true
        XCTAssertTrue(sut.expiryDateTextField.isSecureTextEntry)
    }

    func test_isEmptyForNil() {
        sut.expiryDateTextField.text = nil
        XCTAssertTrue(sut.isEmpty)
    }

    func test_isEmptyForEmptyString() {
        sut.expiryDateTextField.text = ""
        XCTAssertTrue(sut.isEmpty)
    }

    func test_settingsTextChangesTextFields() {
        sut.text = "04/10"
        XCTAssertEqual("04/10", sut.expiryDateTextField.text)
    }

    func test_settingsErrorMessageChangesLabel() {
        let given = "-Error-"
        sut.error = given
        XCTAssertEqual(sut.errorLabel.text, given)
    }

    func test_setTitleColor() {
        sut.titleColor = UIColor.red
        XCTAssertEqual(sut.titleLabel.textColor, UIColor.red)
    }
}
