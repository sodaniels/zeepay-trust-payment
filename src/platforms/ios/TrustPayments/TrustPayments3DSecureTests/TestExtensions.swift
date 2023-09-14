//
//  TestExtensions.swift
//  TrustPayments3DSecureTests
//

@testable import TrustPayments3DSecure
import XCTest

class TestExtension: XCTestCase {
    func test_colorBlack() {
        let expected = "#000000"
        XCTAssertEqual(UIColor.black.hexString, expected)
    }

    func test_colorWhite() {
        let expected = "#FFFFFF"
        XCTAssertEqual(UIColor.white.hexString, expected)
    }

    func test_colorGreen() {
        let expected = "#006400"
        let color = UIColor(red: 0, green: 100.0 / 255.0, blue: 0, alpha: 1.0)
        XCTAssertEqual(color.hexString, expected)
    }
}
