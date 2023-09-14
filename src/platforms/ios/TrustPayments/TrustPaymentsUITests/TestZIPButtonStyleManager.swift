//
//  TestZIPButtonStyleManager.swift
//  TrustPaymentsUITests
//

@testable import TrustPaymentsUI
import XCTest

class TestZIPButtonStyleManager: XCTestCase {

    func testLogoTheme() {
        let allThemes = ZIPButtonLogoTheme.allCases
        XCTAssertEqual(allThemes.count, 2)
        XCTAssertTrue(allThemes.contains(.light))
        XCTAssertTrue(allThemes.contains(.dark))
    }

    func testDefaultLight() {
        let sut = ZIPButtonStyleManager.light()
        XCTAssertEqual(sut.theme, .light)
        XCTAssertEqual(sut.enabledBackgroundColor, .white)
        XCTAssertEqual(sut.disabledBackgroundColor, nil)
        XCTAssertEqual(sut.borderColor, .gray)
        XCTAssertEqual(sut.borderWidth, 1)
        XCTAssertEqual(sut.titleFont, nil)
        XCTAssertEqual(sut.titleColor, nil)
        XCTAssertEqual(sut.spinnerStyle, .white)
        XCTAssertEqual(sut.spinnerColor, .gray)
        XCTAssertEqual(sut.buttonContentHeightMargins?.top, 0)
        XCTAssertEqual(sut.buttonContentHeightMargins?.bottom, 0)
        XCTAssertEqual(sut.cornerRadius, 6)
    }

    func testDefaultDark() {
        let sut = ZIPButtonStyleManager.dark()
        XCTAssertEqual(sut.theme, .dark)
        XCTAssertEqual(sut.enabledBackgroundColor, .gray)
        XCTAssertEqual(sut.disabledBackgroundColor, nil)
        XCTAssertEqual(sut.borderColor, .clear)
        XCTAssertEqual(sut.borderWidth, 1)
        XCTAssertEqual(sut.titleFont, nil)
        XCTAssertEqual(sut.titleColor, nil)
        XCTAssertEqual(sut.spinnerStyle, .white)
        XCTAssertEqual(sut.spinnerColor, .white)
        XCTAssertEqual(sut.buttonContentHeightMargins?.top, 0)
        XCTAssertEqual(sut.buttonContentHeightMargins?.bottom, 0)
        XCTAssertEqual(sut.cornerRadius, 6)
    }
}
