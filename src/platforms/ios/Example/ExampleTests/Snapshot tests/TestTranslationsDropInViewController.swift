//
//  TestTranslationsDropInViewController.swift
//  ExampleTests
//

import SnapshotTesting
import Trust_Payments

class TestTranslationsDropInViewController: XCTestCase {
    // Welsh
    func test_controllerInWelsh() {
        performTest(for: "cy_GB")
    }

    // Danish
    func test_controllerInDanish() {
        performTest(for: "da_DK")
    }

    // German
    func test_controllerInGerman() {
        performTest(for: "de_DE")
    }

    // American english
    func test_controllerInAmericanEnglish() {
        performTest(for: "en_US")
    }

    // British english
    func test_controllerInBritishEnglish() {
        performTest(for: "en_GB")
    }

    // Spanish
    func test_controllerInSpanish() {
        performTest(for: "es_ES")
    }

    // French
    func test_controllerInFrench() {
        performTest(for: "fr_FR")
    }

    // Dutch
    func test_controllerInDutch() {
        performTest(for: "nl_NL")
    }

    // Norwegian
    func test_controllerInNorwegian() {
        performTest(for: "no_NO")
    }

    // Swedish
    func test_controllerInSwedish() {
        performTest(for: "sv_SE")
    }
    
    // Italian
    func test_controllerInItalian() {
        performTest(for: "it_IT")
    }

    private func performTest(for locale: String) {
        TrustPayments.instance.configure(username: "", gateway: .eu, environment: .staging, locale: Locale(identifier: locale), translationsForOverride: nil)
        let inputViewStyleManager = InputViewStyleManager.defaultLight()
        let payButtonStyleManager = PayButtonStyleManager.defaultLight()
        let dropInViewStyleManager = DropInViewStyleManager(inputViewStyleManager: inputViewStyleManager,
                                                            requestButtonStyleManager: payButtonStyleManager,
                                                            zipButtonStyleManager: nil,
                                                            ataButtonStyleManager: nil,
                                                            backgroundColor: .white,
                                                            spacingBetweenInputViews: 25,
                                                            insets: UIEdgeInsets(top: 25, left: 35, bottom: -30, right: -35))

        // Force try as there is no point of continuing without the VC
        // swiftlint:disable force_try
        let viewController = try! ViewControllerFactory.shared.dropInViewController(jwt: .empty,
                                                                                    applePayConfiguration: nil,
                                                                                    dropInViewStyleManager: dropInViewStyleManager,
                                                                                    dropInViewDarkModeStyleManager: nil,
                                                                                    payButtonTappedClosureBeforeTransaction: { _ in },
                                                                                    transactionResponseClosure: { _, _, _ in })
        // swiftlint:enable force_try

        let expectation = XCTestExpectation()
        if #available(iOS 13.0, *) {
            viewController.viewController.overrideUserInterfaceStyle = .light
        }
        UIApplication.shared.topMostViewController?.navigationController?.pushViewController(viewController.viewController, animated: false)
        wait(interval: 1) { [unowned self] in
            _ = (viewController.viewInstance.cardNumberInput as InputValidation).validate(silent: false)
            _ = (viewController.viewInstance.expiryDateInput as InputValidation).validate(silent: false)
            _ = (viewController.viewInstance.cvvInput as InputValidation).validate(silent: false)
            self.wait(interval: 1) {
                // wait for the UI to update
                let device = CITestDevices.current
                assertSnapshots(matching: viewController.viewController, as: ["drop_in_vc_in_\(locale)_\(device.rawValue)": .image(on: device.viewImageConfig, precision: 0.98)])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
}
