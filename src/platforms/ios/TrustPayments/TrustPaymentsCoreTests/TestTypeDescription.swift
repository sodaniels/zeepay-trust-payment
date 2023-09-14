//
//  TestTypeDescription.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestTypeDescription: XCTestCase {
    func test_codeForAuth() {
        XCTAssertEqual(TypeDescription.auth.code, TypeDescriptionObjc.auth.rawValue)
    }

    func test_codeForAccountcheck() {
        XCTAssertEqual(TypeDescription.accountCheck.code, TypeDescriptionObjc.accountCheck.rawValue)
    }

    func test_codeForThreedQuery() {
        XCTAssertEqual(TypeDescription.threeDQuery.code, TypeDescriptionObjc.threeDQuery.rawValue)
    }

    func test_codeForJSInit() {
        XCTAssertEqual(TypeDescription.jsInit.code, TypeDescriptionObjc.jsInit.rawValue)
    }

    func test_codeForSubscription() {
        XCTAssertEqual(TypeDescription.subscription.code, TypeDescriptionObjc.subscription.rawValue)
    }

    func test_codeForCacheTokenise() {
        XCTAssertEqual(TypeDescription.cacheTokenise.code, TypeDescriptionObjc.cacheTokenise.rawValue)
    }

    func test_valueForAuth() {
        XCTAssertEqual(TypeDescription.auth.rawValue, TypeDescriptionObjc.auth.value)
    }

    func test_valueForAccountcheck() {
        XCTAssertEqual(TypeDescription.accountCheck.rawValue, TypeDescriptionObjc.accountCheck.value)
    }

    func test_valueForThreedQuery() {
        XCTAssertEqual(TypeDescription.threeDQuery.rawValue, TypeDescriptionObjc.threeDQuery.value)
    }

    func test_valueForJSInit() {
        XCTAssertEqual(TypeDescription.jsInit.rawValue, TypeDescriptionObjc.jsInit.value)
    }

    func test_valueForSubscription() {
        XCTAssertEqual(TypeDescription.subscription.rawValue, TypeDescriptionObjc.subscription.value)
    }

    func test_valueForCacheTokenise() {
        XCTAssertEqual(TypeDescription.cacheTokenise.rawValue, TypeDescriptionObjc.cacheTokenise.value)
    }
}
