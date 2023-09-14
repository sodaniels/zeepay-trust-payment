//
//  TestRawRepresentable.swift
//  TrustPaymentsCardTests
//

@testable import TrustPaymentsCard
import XCTest

class TestRawRepresentable: XCTestCase {
    func test_cardNumber() {
        let cardNumber = String(4_000_000_000_000_000)
        let cardNumberRepresentable = CardNumber(rawValue: cardNumber)
        XCTAssertEqual(cardNumber.count, cardNumberRepresentable.length)
        XCTAssertEqual(cardNumber, cardNumberRepresentable.description)
    }

    func test_cvv() {
        let cvv = "312"
        let cvvRepresentable = CVV(rawValue: cvv)
        XCTAssertEqual(cvv.count, cvvRepresentable.length)
        XCTAssertEqual(cvv, cvvRepresentable.description)
        XCTAssertEqual(Int(cvv), cvvRepresentable.intValue)
    }

    func test_exppiry() {
        let expipry = "11/23"
        let expiryRepresentable = ExpiryDate(rawValue: expipry)
        XCTAssertEqual(expipry.count, expiryRepresentable.length)
        XCTAssertEqual(expipry, expiryRepresentable.description)
    }

    func testCard() {
        let cardNumber = CardNumber(rawValue: String(4_000_000_000_001_234))
        let cvv = CVV(rawValue: "629")
        let expiry = ExpiryDate(rawValue: "10/21")

        let card = Card(cardNumber: cardNumber, cvv: cvv, expiryDate: expiry)
        XCTAssertEqual(card.cardNumber, cardNumber)
        XCTAssertEqual(card.cvv, cvv)
        XCTAssertEqual(card.expiryDate, expiry)
        XCTAssertEqual(card.cardType, CardType.visa)
    }

    func testCardEmptyCardNumber() {
        let card = Card(cardNumber: nil, cvv: nil, expiryDate: nil)
        XCTAssertEqual(card.cardType, CardType.unknown)
    }
}
