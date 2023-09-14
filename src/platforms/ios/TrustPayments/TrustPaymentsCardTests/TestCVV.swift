//
//  TestCVV.swift
//  TrustPaymentsCardTests
//

@testable import TrustPaymentsCard
import XCTest

class TestCVV: XCTestCase {
    // MARK: - Test security code length

    func test_amexCVVis4() {
        let card = CardType.amex
        XCTAssertEqual(card.cvvLength, 4)
    }

    func test_visaCVVis3() {
        let card = CardType.visa
        XCTAssertEqual(card.cvvLength, 3)
    }

    func test_mastercardCVVis3() {
        let card = CardType.visa
        XCTAssertEqual(card.cvvLength, 3)
    }

    func test_maestroCVVis3() {
        let card = CardType.visa
        XCTAssertEqual(card.cvvLength, 3)
    }

    func test_discoverCVVis3() {
        let card = CardType.visa
        XCTAssertEqual(card.cvvLength, 3)
    }

    func test_dinersCVVis3() {
        let card = CardType.visa
        XCTAssertEqual(card.cvvLength, 3)
    }

    func test_jcbCVVis3() {
        let card = CardType.visa
        XCTAssertEqual(card.cvvLength, 3)
    }

    // MARK: - Test CVV

    func test_validThreeDigitCVV() {
        let code = "123"
        let isValid = CardValidator.isCVVValid(cvv: code, cardType: .visa)
        XCTAssertTrue(isValid)
    }

    func test_invalidThreeDigitCVVAmex() {
        let code = "123"
        let isValid = CardValidator.isCVVValid(cvv: code, cardType: .amex)
        XCTAssertFalse(isValid)
    }

    func test_fourDigitCVVAmex() {
        let code = "1234"
        let isValid = CardValidator.isCVVValid(cvv: code, cardType: .amex)
        XCTAssertTrue(isValid)
    }

    func test_invalidFourDigitCVVVisa() {
        let code = "1234"
        let isValid = CardValidator.isCVVValid(cvv: code, cardType: .visa)
        XCTAssertFalse(isValid)
    }

    func test_invalidMixedDigitCVVVisa() {
        let code = "1a2b3c"
        let isValid = CardValidator.isCVVValid(cvv: code, cardType: .visa)
        XCTAssertFalse(isValid)
    }

    func test_invalidNoneDigitCVVVisa() {
        let code = "abc"
        let isValid = CardValidator.isCVVValid(cvv: code, cardType: .visa)
        XCTAssertFalse(isValid)
    }

    func test_isCVVRequiredForAll() {
        let allCards = CardType.allCases
        for card in allCards {
            let isRequired = CardValidator.isCVVRequired(for: card)
            XCTAssertTrue(isRequired)
        }
    }
}
