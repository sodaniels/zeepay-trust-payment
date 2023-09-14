//
//  TestAPM.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestAPM: XCTestCase {

    func testAPMConfigurationInit() {
        let apms: [APM] = [.zip, .ata]
        let min: Double = 10.0
        let max: Double = 13.5
        let styling = APMStyling()
        let configuration = TPAPMConfiguration(supportedAPMs: apms, zipMinAmount: min, zipMaxAmount: max, styling: styling)
        XCTAssertEqual(configuration.supportedAPMs, apms)
        XCTAssertEqual(configuration.minAmount, min)
        XCTAssertEqual(configuration.maxAmount, max)
        XCTAssertEqual(configuration.styling?.headerColor, styling.headerColor)
        XCTAssertEqual(configuration.styling?.headerTitle, styling.headerTitle)
    }

    func testAPM_ZIPViewModel() {
        let returnUrl = "returnUrl"
        let redirectUrl = "redirectUrl"
        let apm: APM = .zip
        let styling = APMStyling()
        let viewModel = APMViewModel(apm: apm, returnUrl: returnUrl, redirectUrl: redirectUrl, styling: styling)
        XCTAssertEqual(viewModel.apm, apm)
        XCTAssertEqual(viewModel.returnUrl, returnUrl)
        XCTAssertEqual(viewModel.redirectUrl, redirectUrl)
        XCTAssertEqual(viewModel.headerColor, styling.headerColor)
        XCTAssertEqual(viewModel.title, styling.headerTitle)
        XCTAssertFalse(viewModel.webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically)
        XCTAssertNotNil(viewModel.webViewRequest)
    }
    
    func testAPM_ATAViewModel() {
        let returnUrl = "returnUrl"
        let redirectUrl = "redirectUrl"
        let apm: APM = .ata
        let styling = APMStyling()
        let viewModel = APMViewModel(apm: apm, returnUrl: returnUrl, redirectUrl: redirectUrl, styling: styling)
        XCTAssertEqual(viewModel.apm, apm)
        XCTAssertEqual(viewModel.returnUrl, returnUrl)
        XCTAssertEqual(viewModel.redirectUrl, redirectUrl)
        XCTAssertEqual(viewModel.headerColor, styling.headerColor)
        XCTAssertEqual(viewModel.title, styling.headerTitle)
        XCTAssertFalse(viewModel.webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically)
    }

    func testAPM_ZIPDefaultHeaderTitle() {
        let defaultTitle = "Buy now pay later"
        let viewModel = APMViewModel(apm: .zip, returnUrl: "", redirectUrl: "")
        XCTAssertEqual(viewModel.title, defaultTitle)
    }
    
    func testAPM_ATADefaultHeaderTitle() {
        let defaultTitle = "Pay By Bank"
        let viewModel = APMViewModel(apm: .ata, returnUrl: "", redirectUrl: "")
        XCTAssertEqual(viewModel.title, defaultTitle)
    }

    func testAPMDefaultHeaderColor() {
        let defaultColor = UIColor(red: 1, green: 1, blue: 250.0 / 255.0, alpha: 1.0)
        let viewModel = APMViewModel(apm: .zip, returnUrl: "", redirectUrl: "")
        XCTAssertEqual(viewModel.headerColor, defaultColor)
    }
}

extension TestAPM {
    class APMStyling: TPAPMStyling {
        var headerTitle: String? { "title" }
        var headerColor: UIColor? { UIColor.white }
    }
}
