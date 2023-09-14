//
//  TestTPEnvironment.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestTPEnvironment: XCTestCase {
    private var paymentTransactionManager: PaymentTransactionManager!

    // MARK: Setup

    override func tearDown() {
        paymentTransactionManager = nil
        super.tearDown()
    }
    
    func testTPInitError() throws {
        var tpInitError: TPInitError.TPInitErrorType = .missingEnvironment
        XCTAssertEqual(tpInitError.propertyName, "Environment")
        tpInitError = .missingGateway
        XCTAssertEqual(tpInitError.propertyName, "Gateway")
        tpInitError = .missingUsername
        XCTAssertEqual(tpInitError.propertyName, "Username")
        XCTAssertNotNil(TPInitError(missingValue: .missingUsername))
    }

    func testStagingEnvironment() throws {
        TrustPayments.instance.configure(username: .empty, gateway: .eu, environment: .staging, translationsForOverride: nil)
        do {
            paymentTransactionManager = try PaymentTransactionManager(jwt: .empty)
        } catch {
            XCTFail("it should not throw an error if staging")
        }

        XCTAssertNotNil(paymentTransactionManager)
        XCTAssertFalse(paymentTransactionManager.isLiveStatus)
    }

    func testProductionEnvironment() throws {
        TrustPayments.instance.configure(username: .empty, gateway: .eu, environment: .production, translationsForOverride: nil)

        do {
            paymentTransactionManager = try PaymentTransactionManager(jwt: .empty)
        } catch let error as TPInitError {
            XCTAssertEqual(error.code, 9100)
        } catch {
            XCTFail("it should not throw an error other than TPInitError")
        }

        XCTAssertNil(paymentTransactionManager)
    }
}
