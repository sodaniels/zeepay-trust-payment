//
//  AppDelegate.swift
//  Example
//

import SwiftJWT
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    /// - SeeAlso: UIApplicationDelegate.window
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    /// Application's foundation.
    /// Keeps dependencies in the same place and allow to reuse them across entire application
    /// without necessity to have multiple instances of one class which should be unique.
    private let appFoundation = DefaultAppFoundation()

    // Application main flow controller
    private lazy var appFlowController = AppFlowController(appFoundation: appFoundation, window: window!)

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.environment["UITEST_DISABLE_ANIMATIONS"] == "YES" {
            UIView.setAnimationsEnabled(false)
        }
        if ProcessInfo.processInfo.environment["CLEAR_STORED_CARDS"] == "YES" {
            Wallet.shared.removeAll()
        }

        TrustPayments.instance.configure(username: appFoundation.keys.merchantUsername, gateway: .eu, environment: .staging, translationsForOverride:
            [
                Locale(identifier: "fr_FR"):
                    [
                        LocalizableKeys.PayButton.title.key: "Payez maintenant!"
                    ],
                Locale(identifier: "en_GB"):
                    [
                        LocalizableKeys.PayButton.title.key: "Pay Now!"
                    ]
            ])
        appFlowController.start()
        return true
    }

    func applicationWillResignActive(_: UIApplication) {}

    func applicationDidEnterBackground(_: UIApplication) {}

    func applicationWillEnterForeground(_: UIApplication) {}

    func applicationDidBecomeActive(_: UIApplication) {}
}
