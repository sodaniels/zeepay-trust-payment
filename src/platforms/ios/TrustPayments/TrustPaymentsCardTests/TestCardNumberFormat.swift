//
//  TestCardNumberFormat.swift
//  TrustPaymentsCardTests
//

@testable import TrustPaymentsCard
import XCTest

class TestCardNumberFormat: XCTestCase {
    let cardContainer = CardTypeContainer(cardTypes: CardType.allCases)

    func test_addSeparatorVisa() {
        let separator = "^"
        let cardNumber = "4000000000000000"
        let expected = "4000^0000^0000^0000"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.addSeparators(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }

    func test_removeSeparatorVisa() {
        let separator = "^"
        let expected = "4000000000000000"
        let cardNumber = "4000^0000^0000^0000"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.removeSeparator(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }

    func test_addSeparatorAmex() {
        let separator = "%"
        let expected = "3420%093356%15660"
        let cardNumber = "342009335615660"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.addSeparators(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }

    func test_removeSeparatorAmex() {
        let separator = "%"
        let cardNumber = "3420%093356%15660"
        let expected = "342009335615660"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.removeSeparator(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }

    func test_addSeparatorDiners() {
        let separator = " "
        let cardNumber = "30191333657196"
        let expected = "3019 133365 7196"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.addSeparators(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }

    func test_addSeparatorDiners16Digits() {
        let separator = " "
        let cardNumber = "3005000000006246"
        let expected = "3005 0000 0000 6246"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.addSeparators(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }

    func test_removeSeparatorDiners() {
        let separator = " "
        let cardNumber = "3019 133365 7196"
        let expected = "30191333657196"
        let format = CardNumberFormat(cardTypeContainer: cardContainer, separator: separator)
        let formattedNumber = format.removeSeparator(cardNumber: cardNumber)
        XCTAssertEqual(formattedNumber, expected)
    }
}
