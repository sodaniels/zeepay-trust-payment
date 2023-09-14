//
//  ViewController.swift
//  CocoapodsIntegration
//

// This project shows how to integrate TrustPayments SDK into your application using Cocoapods dependency manager.
// All dependencies support xcframeworks and arm64 architecture for Apple M1
//
// The Podfile contains reference to the TP SDK's Gitlab repository:
// pod 'TrustPayments'
// This example projects also uses SwiftJWT for creating and verifying JWT and cocoapods-keys for managing sensitive data.
// Those tools are also added to the Podfile, run pod install to setup all dependencies.
// The project also contains few integration tests.
//
// For more examples please refer to documentation at: https://help.trustpayments.com
// and Example project in TrustPayments.xcworkspace

import TrustPayments
import UIKit

class ViewController: UIViewController {

    private let keys = CocoapodsIntegrationKeys()
    private var payForm: DropInController?

    private lazy var showDropInViewButton: UIButton = {
        let button = UIButton()
        button.setTitle("Checkout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showPayForm), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            // Configure the TrustPayments instance before proceeding with any view or transaction. Preferably set it once in AppDelegate.
            TrustPayments.instance.configure(username: keys.mERCHANT_USERNAME, gateway: .eu, environment: .staging, translationsForOverride: nil)
            // Optional style manager in order to set edge insets as there is no Navigation Controller.
            let styleManager = DropInViewStyleManager(inputViewStyleManager: nil,
                                                      requestButtonStyleManager: nil,
                                                      backgroundColor: nil,
                                                      spacingBetweenInputViews: 20,
                                                      insets: UIEdgeInsets(top: 60, left: 20, bottom: 20, right: -20))
            payForm = try ViewControllerFactory.shared.dropInViewController(
                jwt: jwt(),
                applePayConfiguration: nil,
                dropInViewStyleManager: styleManager,
                payButtonTappedClosureBeforeTransaction: { controller in
                    // Call 'continue' when all processing activities which should happend
                    // after user tap and before network request occurred.

                    // start your activity indicator
                    controller.continue()
                }
            ) { [weak self] jwts, _, error in
                // stop your activity indicator
                guard let error = error else {
                    guard let tpResponses = try? TPHelper.getTPResponses(jwt: jwts) else { return }
                    guard let firstTPError = tpResponses.compactMap(\.tpError).first else {
                        // show request success
                        print("success")
                        self?.payForm?.viewController.dismiss(animated: true)
                        return
                    }
                    // show request error
                    print(firstTPError.humanReadableDescription)
                    return
                }
                // error
                print(error.humanReadableDescription)
            }

            view.addSubview(showDropInViewButton)
            NSLayoutConstraint.activate([
                showDropInViewButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                showDropInViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } catch {
            // Could not initialize DropInViewController
            print(error)
        }
    }

    @objc func showPayForm() {
        guard let controller = payForm?.viewController else { return }
        present(controller, animated: true)
    }

    private func jwt() -> String? {
        let typeDescriptions = [TypeDescription.threeDQuery, TypeDescription.auth].map(\.rawValue)
        let claim = TPClaims(iss: keys.mERCHANT_USERNAME,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.mERCHANT_SITEREFERENCE,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100))
        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jWTSecret) else { return nil }
        return jwt
    }
}
