//
//  TestLocalizable.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestLocalizable: XCTestCase {
    // MARK: Configuration

    func test_defaultLanguageIs_en_GB() {
        XCTAssertEqual(Localizable.Language.default, Localizable.Language.en_GB)
    }

    func test_plDefaultsTo_en_GB() {
        let localizable = Localizable(locale: Locale(identifier: "pl_PL"))
        XCTAssertEqual(localizable.currentLocale.identifier, Localizable.Language.en_GB.rawValue)
    }

    func test_supportedLocaleIsNotResolved() {
        let localizable = Localizable(locale: Locale(identifier: "fr_FR"))
        XCTAssertEqual(localizable.currentLocale.identifier, Localizable.Language.fr_FR.rawValue)
    }

    func test_customTranslationForPaybuttonTitle() {
        let locale = Locale(identifier: "en_GB")
        let expected = "Pay now!"
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: locale,
                                         translationsForOverride: [
                                             locale:
                                                 [
                                                     LocalizableKeys.PayButton.title.key: expected
                                                 ]
                                         ])
        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedStringOrEmpty, expected)
    }

    func test_overrideTranslationsViaObjcMethod() {
        let locale = NSLocale(localeIdentifier: "fr_FR")
        let expected = "french_AddCard"
        // swiftlint:disable compiler_protocol_init
        let addCardObjcKey = NSNumber(integerLiteral: LocalizableKeysObjc._addCardButton_title.rawValue)
        // swiftlint:enable compiler_protocol_init
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: locale,
                                         customTranslations: [
                                             locale: [
                                                 addCardObjcKey: "french_AddCard"
                                             ]
                                         ])
        let sut = LocalizableKeys.AddCardButton.title.localizedString
        XCTAssertEqual(sut, expected)
    }

    // MARK: Sample translations

    func test_sampleTranslationsFor_en_GB() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.en_GB.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Pay")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Card number")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/YY")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Add card")
    }

    func test_sampleTranslationsFor_en_US() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.en_US.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Pay")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Card number")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/YY")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Add card")
    }

    func test_sampleTranslationsFor_cy_GB() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.cy_GB.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Talu")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Rhif y cerdyn")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/BB")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Ychwanegu cerdyn")
    }

    func test_sampleTranslationsFor_da_DK() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.da_DK.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Betal")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Kortnummer")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/ÅÅ")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Tilføj kort")
    }

    func test_sampleTranslationsFor_de_DE() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.de_DE.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Zahlen")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Kartennummer")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/JJ")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Karte hinzufügen")
    }

    func test_sampleTranslationsFor_es_ES() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.es_ES.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Pagar")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Número de tarjeta")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/AA")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Agregar tarjeta")
    }

    func test_sampleTranslationsFor_fr_FR() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.fr_FR.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Payer")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Numéro de carte")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/AA")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Ajouter une carte")
    }

    func test_sampleTranslationsFor_nl_NL() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.nl_NL.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Betalen")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Kaartnummer")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/JJ")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Voeg een kaart toe")
    }

    func test_sampleTranslationsFor_nb_NO() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.nb_NO.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Betal")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Kortnummer")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/ÅÅ")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Legg til kort")
    }

    func test_sampleTranslationsFor_nn_NO() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.nn_NO.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Betal")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Kortnummer")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/ÅÅ")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Legg til kort")
    }

    func test_sampleTranslationsFor_sv_SE() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.sv_SE.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Betala")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Kortnummer")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/ÅÅ")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Lägg till kort")
    }
    
    func test_sampleTranslationsFor_it_IT() {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: Locale(identifier: Localizable.Language.it_IT.rawValue),
                                         translationsForOverride: nil)

        XCTAssertEqual(LocalizableKeys.PayButton.title.localizedString, "Pagare")
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.localizedString, "Numero di carta")
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.localizedString, "MM/AA")
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.localizedString, "Aggiungi carta")
    }

    func test_ObjcKeysMatchesSwiftKeys() {
        // Pay button
        XCTAssertEqual(LocalizableKeys.PayButton.title.key, LocalizableKeysObjc._payButton_title.code)

        // DropInViewController
        XCTAssertEqual(LocalizableKeys.DropInViewController.successfulPayment.key, LocalizableKeysObjc._dropInViewController_successfulPayment.code)

        // Errors
        XCTAssertEqual(LocalizableKeys.Errors.general.key, LocalizableKeysObjc._errors_general.code)

        // CardNumberInputView
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.title.key, LocalizableKeysObjc._cardNumberInputView_title.code)
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.placeholder.key, LocalizableKeysObjc._cardNumberInputView_placeholder.code)
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.error.key, LocalizableKeysObjc._cardNumberInputView_error.code)
        XCTAssertEqual(LocalizableKeys.CardNumberInputView.emptyError.key, LocalizableKeysObjc._cardNumberInputView_emptyError.code)

        // CVVInputView
        XCTAssertEqual(LocalizableKeys.CVVInputView.title.key, LocalizableKeysObjc._cvvInputView_title.code)
        XCTAssertEqual(LocalizableKeys.CVVInputView.placeholder3.key, LocalizableKeysObjc._cvvInputView_placeholder3.code)
        XCTAssertEqual(LocalizableKeys.CVVInputView.placeholder4.key, LocalizableKeysObjc._cvvInputView_placeholder4.code)
        XCTAssertEqual(LocalizableKeys.CVVInputView.error.key, LocalizableKeysObjc._cvvInputView_error.code)
        XCTAssertEqual(LocalizableKeys.CVVInputView.emptyError.key, LocalizableKeysObjc._cvvInputView_emptyError.code)

        // ExpiryDateInputView
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.title.key, LocalizableKeysObjc._expiryDateInputView_title.code)
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.placeholder.key, LocalizableKeysObjc._expiryDateInputView_placeholder.code)
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.error.key, LocalizableKeysObjc._expiryDateInputView_error.code)
        XCTAssertEqual(LocalizableKeys.ExpiryDateInputView.emptyError.key, LocalizableKeysObjc._expiryDateInputView_emptyError.code)

        // AddCardButton
        XCTAssertEqual(LocalizableKeys.AddCardButton.title.key, LocalizableKeysObjc._addCardButton_title.code)

        // Alerts
        XCTAssertEqual(LocalizableKeys.Alerts.processing.key, LocalizableKeysObjc._alerts_processing.code)

        // Challenge view
        XCTAssertEqual(LocalizableKeys.ChallengeView.headerTitle.key, LocalizableKeysObjc._challengeView_headerTitle.code)
        XCTAssertEqual(LocalizableKeys.ChallengeView.headerCancelTitle.key, LocalizableKeysObjc._challengeView_headerCancelTitle.code)
    }
    
    // MARK: - ATA button title
    
    func testAtaOverridenTranslation_it_IT() {
        let locale = Locale(identifier: Localizable.Language.it_IT.rawValue)
        let overridenTranslation = "Italian translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }

    func testAtaOverridenTranslation_cy_GB() {
        let locale = Locale(identifier: Localizable.Language.cy_GB.rawValue)
        let overridenTranslation = "Welsh translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_da_DK() {
        let locale = Locale(identifier: Localizable.Language.da_DK.rawValue)
        let overridenTranslation = "Danish translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_de_DE() {
        let locale = Locale(identifier: Localizable.Language.de_DE.rawValue)
        let overridenTranslation = "German translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_en_GB() {
        let locale = Locale(identifier: Localizable.Language.en_GB.rawValue)
        let overridenTranslation = "British translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_en_US() {
        let locale = Locale(identifier: Localizable.Language.en_US.rawValue)
        let overridenTranslation = "American translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_es_ES() {
        let locale = Locale(identifier: Localizable.Language.es_ES.rawValue)
        let overridenTranslation = "Spanish translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_fr_FR() {
        let locale = Locale(identifier: Localizable.Language.fr_FR.rawValue)
        let overridenTranslation = "French translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_nl_NL() {
        let locale = Locale(identifier: Localizable.Language.nl_NL.rawValue)
        let overridenTranslation = "Dutch translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_sv_SE() {
        let locale = Locale(identifier: Localizable.Language.sv_SE.rawValue)
        let overridenTranslation = "Swedish translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_nb_NO() {
        let locale = Locale(identifier: Localizable.Language.nb_NO.rawValue)
        let overridenTranslation = "Norwegian (Bokml) translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
    
    func testAtaOverridenTranslation_nn_NO() {
        let locale = Locale(identifier: Localizable.Language.nn_NO.rawValue)
        let overridenTranslation = "Norwegian (Nynorks) translation"
        configureLocale(locale: locale,
                        overrideTranslation: nil)
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, "Pay By Bank")
        
        configureLocale(locale: locale, overrideTranslation: [
            locale: [LocalizableKeys.PayButton.ataPayByBank.key: overridenTranslation]
        ])
        XCTAssertEqual(LocalizableKeys.PayButton.ataPayByBank.localizedString, overridenTranslation)
    }
}

extension TestLocalizable {
    func configureLocale(locale: Locale, overrideTranslation translations: [Locale: [String: String]]? = nil) {
        TrustPayments.instance.configure(username: "",
                                         gateway: .eu,
                                         environment: .staging,
                                         locale: locale,
                                         translationsForOverride: translations)
    }
}
