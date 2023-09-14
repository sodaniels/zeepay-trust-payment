//
//  TestCardTypeLogo.swift
//  TrustPaymentsCardTests
//

@testable import TrustPaymentsCard
import XCTest

class TestCardTypeLogo: XCTestCase {
    // MARK: - Test logo exists for card issuers

    func test_hasLogoForVisa() {
        let logo = CardType.visa.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForAmex() {
        let logo = CardType.amex.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForMastercard() {
        let logo = CardType.mastercard.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForMaestro() {
        let logo = CardType.maestro.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForDiscover() {
        let logo = CardType.discover.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForDiners() {
        let logo = CardType.diners.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForJCB() {
        let logo = CardType.jcb.logo
        XCTAssertNotNil(logo)
    }

    func test_hasLogoForUnknown() {
        let logo = CardType.unknown.logo
        XCTAssertNotNil(logo)
    }
}
