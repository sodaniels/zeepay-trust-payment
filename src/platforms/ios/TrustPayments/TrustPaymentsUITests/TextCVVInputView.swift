//
//  TextCVVInputView.swift
//  TrustPaymentsUITests
//

@testable import TrustPaymentsUI
import XCTest

class TextCVVInputView: XCTestCase {
    func test_inputInvalidForEmpty() {
        let sut = CVVInputView()
        XCTAssertFalse(sut.isInputValid)
    }

    func test_placeholderHas4CharsForAmex() {
        let sut = CVVInputView()
        sut.cardType = .amex
        XCTAssertEqual(sut.placeholder.count, 4)
    }

    func test_placeholderHas3CharsForVisa() {
        let sut = CVVInputView()
        sut.cardType = .visa
        XCTAssertEqual(sut.placeholder.count, 3)
    }
}
