//
//  TestZIPButton.swift
//  TrustPaymentsUITests
//

@testable import TrustPaymentsUI
import XCTest

class TestZIPButton: XCTestCase {

    func testInitialization() {
        let lightStyleManager = ZIPButtonStyleManager.light()
        let darkStyleManager = ZIPButtonStyleManager.dark()

        let sut = ZIPButton(styleManager: lightStyleManager, darkModeStyleManager: darkStyleManager)
        XCTAssertEqual(sut.zipButtonStyleManager, lightStyleManager)
        XCTAssertEqual(sut.zipButtonDarkStyleManager, darkStyleManager)
    }

    func testEmptyInitialization() {
        let sut = ZIPButton(styleManager: nil, darkModeStyleManager: nil)
        XCTAssertEqual(sut.zipButtonStyleManager.theme, .light)
        XCTAssertEqual(sut.zipButtonDarkStyleManager.theme, .dark)
    }
}
