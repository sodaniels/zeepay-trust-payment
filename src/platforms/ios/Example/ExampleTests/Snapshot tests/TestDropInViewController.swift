//
//  TestDropInViewController.swift
//  ExampleTests
//

import PassKit
import SnapshotTesting
@testable import Trust_Payments

class TestDropInViewController: XCTestCase {
    private var dropInViewController: DropInController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // swiftlint:disable line_length
        let customFont = UIFont(name: "Chalkduster", size: 17)
        let inputViewStyleManager = InputViewStyleManager(titleColor: UIColor.blue, textFieldBorderColor: UIColor.blue.withAlphaComponent(0.8), textFieldBackgroundColor: .yellow, textColor: .darkGray, placeholderColor: UIColor.blue.withAlphaComponent(0.8), errorColor: UIColor.green.withAlphaComponent(0.8), textFieldImageColor: .blue, titleFont: customFont, textFont: customFont, placeholderFont: customFont, errorFont: customFont, textFieldImage: nil, titleSpacing: 15, errorSpacing: 5, textFieldHeightMargins: HeightMargins(top: 15, bottom: 15), textFieldBorderWidth: 3, textFieldCornerRadius: 10)

        var spinnerStyle = UIActivityIndicatorView.Style.whiteLarge
        if #available(iOS 13.0, *) {
            spinnerStyle = .large
        }

        let payButtonStyleManager = PayButtonStyleManager(titleColor: .yellow, enabledBackgroundColor: .blue, disabledBackgroundColor: UIColor.blue.withAlphaComponent(0.3), borderColor: .black, titleFont: customFont, spinnerStyle: spinnerStyle, spinnerColor: .yellow, buttonContentHeightMargins: HeightMargins(top: 5, bottom: 5), borderWidth: 3, cornerRadius: 10)

        let dropInViewStyleManager = DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager, requestButtonStyleManager: payButtonStyleManager, zipButtonStyleManager: nil, ataButtonStyleManager: nil, backgroundColor: .lightGray, spacingBetweenInputViews: 15, insets: UIEdgeInsets(top: 15, left: 15, bottom: -15, right: -15))

        let inputViewDarkModeStyleManager = InputViewStyleManager(titleColor: UIColor.white, textFieldBorderColor: UIColor.white.withAlphaComponent(0.8), textFieldBackgroundColor: .darkGray, textColor: .white, placeholderColor: UIColor.white.withAlphaComponent(0.8), errorColor: UIColor.red, textFieldImageColor: .white, titleFont: customFont, textFont: customFont, placeholderFont: customFont, errorFont: customFont, textFieldImage: nil, titleSpacing: 15, errorSpacing: 5, textFieldHeightMargins: HeightMargins(top: 15, bottom: 15), textFieldBorderWidth: 3, textFieldCornerRadius: 10)

        let payButtonDarkModeStyleManager = PayButtonStyleManager(titleColor: .black, enabledBackgroundColor: .white, disabledBackgroundColor: UIColor.lightGray.withAlphaComponent(0.6), borderColor: .white, titleFont: customFont, spinnerStyle: spinnerStyle, spinnerColor: .black, buttonContentHeightMargins: HeightMargins(top: 5, bottom: 5), borderWidth: 3, cornerRadius: 10)

        let dropInViewDarkModeStyleManager = DropInViewStyleManager(inputViewStyleManager: inputViewDarkModeStyleManager, requestButtonStyleManager: payButtonDarkModeStyleManager, zipButtonStyleManager: nil, ataButtonStyleManager: nil, backgroundColor: .black, spacingBetweenInputViews: 15, insets: UIEdgeInsets(top: 15, left: 15, bottom: -15, right: -15))

        let mockedPaymentRequest = PKPaymentRequest()
        let applePayConfig = TPApplePayConfiguration(handler: nil,
                                                     request: mockedPaymentRequest,
                                                     buttonStyle: .black,
                                                     buttonDarkModeStyle: .white,
                                                     buttonType: .plain)

        dropInViewController = try ViewControllerFactory.shared.dropInViewController(jwt: .empty, applePayConfiguration: applePayConfig, dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager, payButtonTappedClosureBeforeTransaction: { _ in }, transactionResponseClosure: { _, _, _ in })
        // swiftlint:enable line_length
    }

    override func tearDown() {
        dropInViewController = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_dropInViewController() throws {
        let expectation = XCTestExpectation()
        if #available(iOS 13.0, *) {
            dropInViewController.viewController.overrideUserInterfaceStyle = .light
        }
        UIApplication.shared.topMostViewController?.navigationController?.pushViewController(dropInViewController.viewController, animated: false)
        wait(interval: 1) { [unowned self] in
            self.fillCardNumberAndShowError()
            wait(interval: 2) {
                // Let the UI settle
                let device = CITestDevices.current
                assertSnapshots(matching: self.dropInViewController.viewController, as: ["drop_in_vc_style_\(device.rawValue)": .image(on: device.viewImageConfig, precision: 0.98)])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    func test_dropInViewControllerInDarkMode() throws {
        let expectation = XCTestExpectation()
        if #available(iOS 13.0, *) {
            dropInViewController.viewController.overrideUserInterfaceStyle = .dark
        }
        UIApplication.shared.topMostViewController?.navigationController?.pushViewController(dropInViewController.viewController, animated: false)
        wait(interval: 1) { [unowned self] in
            self.fillCardNumberAndShowError()
            let device = CITestDevices.current
            assertSnapshots(matching: self.dropInViewController.viewController, as: ["drop_in_vc_style_dark_\(device.rawValue)": .image(on: device.viewImageConfig, precision: 0.98)])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func test_dropInViewWithOnlyApplePayConfiguration() throws {
        // swiftlint:disable line_length
        let expectation = XCTestExpectation()

        let inputViewStyleManager = InputViewStyleManager.defaultLight()

        let dropInViewStyleManager = DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager, requestButtonStyleManager: nil, zipButtonStyleManager: nil, ataButtonStyleManager: nil, backgroundColor: .lightGray, spacingBetweenInputViews: 15, insets: UIEdgeInsets(top: 15, left: 15, bottom: -15, right: -15))

        let mockedPaymentRequest = PKPaymentRequest()
        let applePayConfig = TPApplePayConfiguration(handler: nil,
                                                     request: mockedPaymentRequest,
                                                     buttonStyle: .black,
                                                     buttonDarkModeStyle: .white,
                                                     buttonType: .plain)

        dropInViewController = try ViewControllerFactory.shared.dropInViewController(jwt: .empty, visibleFields: [], applePayConfiguration: applePayConfig, dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: nil, payButtonTappedClosureBeforeTransaction: { _ in }, transactionResponseClosure: { _, _, _ in })

        UIApplication.shared.topMostViewController?.navigationController?.pushViewController(dropInViewController.viewController, animated: false)
        wait(interval: 1) { [unowned self] in
            let device = CITestDevices.current
            assertSnapshots(matching: self.dropInViewController.viewController, as: ["drop_in_with_only_apple_pay\(device.rawValue)": .image(on: device.viewImageConfig, precision: 0.98)])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        // swiftlint:enable line_length
    }

    private func fillCardNumberAndShowError() {
        // swiftlint:disable force_cast
        (dropInViewController.viewInstance.cardNumberInput as! SecureFormInputView).text = "4000 0000 0000 2008"
        (dropInViewController.viewInstance.cvvInput as! DefaultSecureFormInputView).showHideError(show: true)
        // swiftlint:enable force_cast
    }
}
