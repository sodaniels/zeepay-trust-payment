//
//  ATATestSuite.swift
//  ExampleUITests
//

import XCTest

class ATATestSuite: BaseTestCase {
    
    // MARK: Properties
    
    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var ataPage = ATAPage(application: self.app)
    let generalErrorMessage = "An error occurred"
    let successfulMessage = "Payment has been successfully processed"
    
    // MARK: Tests
    
    func testDiscardATAPaymentFormFromNavigation() {
        mainPage.tapPerformAuthWithATA()
        ataPage.tapCancelButton()
        
        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: generalErrorMessage),
                      "Alert with a message: '\(generalErrorMessage)' was not displayed.")
    }
    
    func testCancelATAPaymentFormFromATAPage() {
        mainPage.tapPayFormWithATA()
        ataPage.tapBankSearchTextField()
        ataPage.tapOzoneBank()
        ataPage.acceptOzoneTerms()
        ataPage.cancelOzone()
        
        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: generalErrorMessage),
                      "Alert with a message: '\(generalErrorMessage)' was not displayed.")
    }
    
    func testSuccessfulAuthWithATARequest() {
        mainPage.tapPayFormWithATA()
        ataPage.tapBankSearchTextField()
        ataPage.tapOzoneBank()
        ataPage.acceptOzoneTerms()
        ataPage.loginWithOzoneCredentials()
        
        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }
}
