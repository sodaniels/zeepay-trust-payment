//
//  TestLocale.swift
//  ExampleTests
//

@testable import TrustPaymentsCore
import XCTest

class TestLocale: XCTestCase {
//    supported locale is specified on the device (fr_FR)
//    no initialization is defined in SDK
//    at least one custom translation added.
//    Custom translation (FR) is applied for given locale
    func test_deviceSettingsCustomFrenchTranslation() {
        guard Locale.current.languageCode?.lowercased() == "fr" else { return }
        let expectedTranslation = "French translation"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         translationsForOverride: [
                                             Locale(identifier: "fr_FR"): [
                                                 LocalizableKeys.PayButton.title.key: expectedTranslation
                                             ]
                                         ])
        XCTAssertEqual(TrustPayments.translation(for: LocalizableKeys.PayButton.title), expectedTranslation)
    }

//    not supported locale is specified on the device (pl_PL)
//    no initialization is defined in SDK
//    at least one custom translation added.
//    chosen device locale setup (pl_PL) is ignored
//    en_GB is applied as default locale
//    custom translation (EN) is applied for given locale (if any)
    func test_deviceSettingsNotSupportedCustomEnglishTranslation() {
        guard Locale.current.languageCode?.lowercased() == "pl" else { return }
        let expectedTranslation = "English translation"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         translationsForOverride: [
                                             Locale(identifier: "en_GB"): [
                                                 LocalizableKeys.PayButton.title.key: expectedTranslation
                                             ],
                                             Locale(identifier: "pl_PL"): [
                                                 LocalizableKeys.PayButton.title.key: "Polish translation"
                                             ]
                                         ])
        XCTAssertEqual(TrustPayments.translation(for: LocalizableKeys.PayButton.title), expectedTranslation)
    }

//    supported locale is specified on the device (fr_FR)
//    initialization for other supported locale is defined in SDK (de_DE)
//    at least one custom translation added.
//    chosen device locale setup (fr_FR) is ignored
//    locale initialized in SDK (de_DE) is applied with custom translation (if any)
    func test_deviceSettingsSupportedCustomGermanTranslation() {
        guard Locale.current.languageCode?.lowercased() == "fr" else { return }
        let expectedTranslation = "German translation"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: "de_DE"),
                                         translationsForOverride: [
                                             Locale(identifier: "fr_FR"): [
                                                 LocalizableKeys.PayButton.title.key: "French translation"
                                             ],
                                             Locale(identifier: "de_DE"): [
                                                 LocalizableKeys.PayButton.title.key: expectedTranslation
                                             ]
                                         ])
        XCTAssertEqual(TrustPayments.translation(for: LocalizableKeys.PayButton.title), expectedTranslation)
    }

//    supported locale is specified on the device (fr_FR)
//    initialization for not supported locale is defined in SDK (pl_PL)
//    at least one custom translation added.
//    chosen device locale setup (fr_FR) is ignored
//    initialised locale (pl_PL) is ignored as it is not supported
//    en_GB is applied as default locale
//    custom translation (EN) is applied for given locale (if any)
    func test_deviceSettingsSupportedCustomEnglishTranslation() {
        guard Locale.current.languageCode?.lowercased() == "fr" else { return }
        let expectedTranslation = "English translation"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: "pl_PL"),
                                         translationsForOverride: [
                                             Locale(identifier: "pl_PL"): [
                                                 LocalizableKeys.PayButton.title.key: "Polish translation"
                                             ],
                                             Locale(identifier: "en_GB"): [
                                                 LocalizableKeys.PayButton.title.key: expectedTranslation
                                             ]
                                         ])
        XCTAssertEqual(TrustPayments.translation(for: LocalizableKeys.PayButton.title), expectedTranslation)
    }

//    not supported locale is specified on the device (pl_PL)
//    initialization for supported locale is defined in SDK (en_GB)
//    at least one custom translation added.
//    chosen device locale setup is (pl_PL) is ignored
//    locale initialized in SDK (en_GB) is applied with custom translation (if any)
    func test_deviceSettingsNotSupportedSDKInitedWithLocaleCustomEnglishTranslation() {
        guard Locale.current.languageCode?.lowercased() == "pl" else { return }
        let expectedTranslation = "English translation"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: "en_GB"),
                                         translationsForOverride: [
                                             Locale(identifier: "pl_PL"): [
                                                 LocalizableKeys.PayButton.title.key: "Polish translation"
                                             ],
                                             Locale(identifier: "en_GB"): [
                                                 LocalizableKeys.PayButton.title.key: expectedTranslation
                                             ]
                                         ])
        XCTAssertEqual(TrustPayments.translation(for: LocalizableKeys.PayButton.title), expectedTranslation)
    }

//    not supported locale is specified on the device (pl_PL)
//    initialization for not supported locale is defined in SDK (pl_PL)
//    at least one custom translation added
//    chosen device locale setup is populated (pl_PL) is ignored
//    initialised locale (pl_PL) is ignored as it is not supported
//    en_GB is applied as default locale
//    custom translation (EN) is applied for given locale (if any)
    func test_deviceSettingsNotSupportedSDKInitedWithUnsupportedLocaleCustomEnglishTranslation() {
        guard Locale.current.languageCode?.lowercased() == "pl" else { return }
        let expectedTranslation = "English translation"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: "pl_PL"),
                                         translationsForOverride: [
                                             Locale(identifier: "pl_PL"): [
                                                 LocalizableKeys.PayButton.title.key: "Polish translation"
                                             ],
                                             Locale(identifier: "en_GB"): [
                                                 LocalizableKeys.PayButton.title.key: expectedTranslation
                                             ]
                                         ])
        XCTAssertEqual(TrustPayments.translation(for: LocalizableKeys.PayButton.title), expectedTranslation)
    }
}
