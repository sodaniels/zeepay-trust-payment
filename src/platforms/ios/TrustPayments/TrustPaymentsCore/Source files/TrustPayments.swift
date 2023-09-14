//
//  TrustPayments.swift
//  TrustPaymentsCore
//

import Foundation
import SeonSDK
import TrustKit

@objc public enum GatewayType: Int {
    case eu
    case euBackup
    case us
    case devbox
    
    var host: String {
        switch self {
        case .eu:
            return "webservices.securetrading.net"
        case .euBackup:
            return "webservices2.securetrading.net"
        case .us:
            return "webservices.securetrading.us"
        case .devbox:
            return "webservices.securetrading.net"
        }
    }
    
    var description: String {
        switch self {
        case .eu: return "eu"
        case .euBackup: return "euBackup"
        case .us: return "us"
        case .devbox: return "devbox"
        }
    }
}

@objc public enum TPEnvironment: Int {
    case production
    case staging
    
    var description: String {
        switch self {
        case .production: return "production"
        case .staging: return "staging"
        }
    }
}

/// SDK Initialization singleton class, used for global settings like:
/// - locale
/// - custom translation
/// - gateway type - provided by Trust Payments
/// - username - provided by Trust Payments
/// - environment - use staging when testing and switch to production when releasing
///
/// Basic configuration:
/// ```
/// TrustPayments.instance.configure(username: merchantUsername,
///                                 gateway: .eu,
///                                 environment: .staging,
///                                 translationsForOverride: nil)
/// ```
///
/// If you need to override default translations, set an array of keys and values as `translationsForOverride`:
/// ```
/// TrustPayments.instance.configure(username: merchantUsername,
///                                 gateway: .eu,
///                                 environment: .staging,
///                                 translationsForOverride:
/// [
///    Locale(identifier: "fr_FR"):
///        [
///            LocalizableKeys.PayButton.title.key: "Payez maintenant!"
///    ],
///    Locale(identifier: "en_GB"):
///        [
///            LocalizableKeys.PayButton.title.key: "Pay Now!"
///    ]
/// ])
/// ```
/// - warning: Unsupported locale will be ommited.
@objc public final class TrustPayments: NSObject {
    /// Use to set global values
    var gateway: GatewayType?
    var username: String?
    var environment: TPEnvironment?
    lazy var monitoringManager: TPMonitoringManager = TPMonitoringManager(dataSource: self)
    var seonManager: SeonFingerprint?

    @objc public static let instance = TrustPayments()
    override private init() {}
    
    private func setupTrustKit() {
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                GatewayType.eu.host: [
                    kTSKEnforcePinning: true,
                    kTSKIncludeSubdomains: true,
                    kTSKPublicKeyHashes: [
                        "kCv4KV+TUcfQ7XFk1Hk4oF2JlFRk9fObpVuZCKCZ/mk=",
                        "yMZhDu5hIsQaSd5wdC0kIxImZ2BpJPz5YGXasZe0IGQ="
                    ]
                ],
                GatewayType.euBackup.host: [
                    kTSKEnforcePinning: true,
                    kTSKIncludeSubdomains: true,
                    kTSKPublicKeyHashes: [
                        "ZUx6EfJmVvDvoioQBPfjlWssKuu4S4Wkn8KOXQEeQSo=",
                        "wjB7efUO9ZRnXsL673AxMVCsN5jdBp238hNJPPHgwZo="
                    ]
                ],
                GatewayType.us.host: [
                    kTSKEnforcePinning: true,
                    kTSKIncludeSubdomains: true,
                    kTSKPublicKeyHashes: [
                        "3yBX4bueFPIjR7Ek9Wkf1WQsUA91ITX3okf2IMkyBGc=",
                        "fyUrn+zMzGnqPkwp5GQbxEhWtwoxzivyd3g+TucBgdc="
                    ]
                ]
            ]
        ] as [String: Any]
        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
    }
    
    /// Reference to Localizable object
    private var localizable: Localizable?
    
    /// Configures global settings
    /// Accepts Locale instead of supported language Enum
    /// that way we can support unsupported language :)
    /// - Parameters:
    ///   - username: Trust Payments user name
    ///   - gateway: Assigned gateway type to the current user (us or eu)
    ///   - environment: Production or staging
    ///   - locale: Locale used to determine correct translations, if not set, a Locale.current value is used instead
    ///   - translationsForOverride: A dictionary of custom translations, overrides default values, refer to LocalizableKeys for possible keys
    public func configure(username: String, gateway: GatewayType, environment: TPEnvironment, locale: Locale = Locale.current, translationsForOverride: [Locale: [String: String]]?) {
        self.username = username
        self.gateway = gateway
        self.environment = environment
        localizable = Localizable(locale: locale)
        if let customTranslations = translationsForOverride {
            localizable?.overrideLocalizedKeys(with: customTranslations)
        }
        if gateway != .devbox {
            setupTrustKit()
        }
        seonManager = SeonFingerprint.sharedManager() as? SeonFingerprint
        seonManager?.setLoggingEnabled(true)
        seonManager?.sessionId = UUID().uuidString
    }
    
    /// Configures global settings
    /// - Parameters:
    ///   - username: Trust Payments user name
    ///   - gateway: Assigned gateway type to the current user (us or eu)
    ///   - environment: Production or staging
    ///   - locale: Locale used to determine correct translations, if not set, a Locale.current value is used instead
    ///   - customTranslations: A dictionary of custom translations, overrides default values, refer to LocalizableKeysObjc for possible keys
    @objc public func configure(username: String, gateway: GatewayType, environment: TPEnvironment, locale: NSLocale, customTranslations: [NSLocale: [NSNumber: String]]) {
        // check for supported keys
        var customTranslationKeys: [Locale: [String: String]] = [:]
        for locale in customTranslations {
            var translationForLocale: [String: String] = [:]
            for translation in locale.value {
                guard let transKey = LocalizableKeysObjc(rawValue: translation.key.intValue)?.code else { continue }
                translationForLocale[transKey] = translation.value
            }
            customTranslationKeys[locale.key as Locale] = translationForLocale
        }
        configure(username: username, gateway: gateway, environment: environment, locale: locale as Locale, translationsForOverride: customTranslationKeys)
    }
    
    /// Returns translation string for given locale
    /// - Parameter key: Localizable key for which correct translated string should be returned
    /// - Returns: Found translated string or nil otherwise
    static func translation<Key: LocalizableKey>(for key: Key) -> String? {
        if TrustPayments.instance.localizable == nil {
            TrustPayments.instance.localizable = Localizable()
        }
        return TrustPayments.instance.localizable!.localizedString(for: key)
    }
    
    func updateEnvironment(to env: TPEnvironment) {
        environment = env
    }
}

extension TrustPayments: TPMonitoringManagerDataSource {
    var environmentType: String? { environment?.description }
    var gatewayType: String? { gateway?.description }
    var gatewayUrl: String? { gateway?.host }
}
