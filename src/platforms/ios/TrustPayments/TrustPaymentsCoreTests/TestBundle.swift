//
//  TestBundle.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestBundle: XCTestCase {
    var bundle: Bundle!

    override func setUp() {
        bundle = Bundle(for: TrustPayments.self)
    }

    func test_releaseVersion() {
        let expected = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        XCTAssertEqual(expected, bundle.releaseVersionNumber)
    }

    func test_buildVersion() {
        let expected = bundle.infoDictionary?["CFBundleVersion"] as? String
        XCTAssertEqual(expected, bundle.buildVersionNumber)
    }
}
