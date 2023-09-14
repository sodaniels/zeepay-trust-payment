//
//  TestCardType.swift
//  TrustPaymentsCardTests
//

@testable import TrustPaymentsCard
import XCTest

class TestCardType: XCTestCase {
    // MARK: - Test card types

    func test_isUnknownForSingleDigit() {
        // if card number starts with other digit that 4
        // then the card type cannot be determined
        // more digits are needed
        let expectedType = CardType.unknown
        let cardNumber = "5"
        XCTAssertEqual(expectedType, CardValidator.cardType(for: cardNumber, cardTypes: CardType.allCases))
    }

    func test_isUnknownForNonDigit() {
        // if card number starts with other digit that 4
        // then the card type cannot be determined
        // more digits are needed
        let expectedType = CardType.unknown
        let cardNumber = "5@dsa"
        XCTAssertEqual(expectedType, CardValidator.cardType(for: cardNumber, cardTypes: CardType.allCases))
    }

    func test_isUnknown() {
        let expectedType = CardType.unknown
        let cardNumbers = KnownCards.invalidCards
        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isVisa() {
        let expectedType = CardType.visa
        let cardNumbers = KnownCards.visaCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isVisaIfStartsWith4() {
        let expectedType = CardType.visa
        let cardNumber = "4"
        XCTAssertEqual(expectedType, CardValidator.cardType(for: cardNumber, cardTypes: CardType.allCases))
    }

    func test_isMasterCard() {
        let expectedType = CardType.mastercard
        let cardNumbers = KnownCards.mastercardCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isMaestro() {
        let expectedType = CardType.maestro
        let cardNumbers = KnownCards.maestroCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isAmex() {
        let expectedType = CardType.amex
        let cardNumbers = KnownCards.amexCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isJCB() {
        let expectedType = CardType.jcb
        let cardNumbers = KnownCards.jcbCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isDiners() {
        let expectedType = CardType.diners
        let cardNumbers = KnownCards.dinerCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_isDiscover() {
        let expectedType = CardType.discover
        let cardNumbers = KnownCards.discoverCards

        for card in cardNumbers {
            XCTAssertEqual(expectedType, CardValidator.cardType(for: card, cardTypes: CardType.allCases))
        }
    }

    func test_cardTypesForDescriptions() {
        let typeDescriptions = [
            "visa",
            "maestro",
            "amex",
            "discover",
            "diners",
            "jcb",
            "mastercard",
            "trustPayments"
        ]
        let cardTypes = typeDescriptions.map { CardType.cardType(for: $0) }
        XCTAssertEqual(cardTypes.count, typeDescriptions.count)
    }
}
