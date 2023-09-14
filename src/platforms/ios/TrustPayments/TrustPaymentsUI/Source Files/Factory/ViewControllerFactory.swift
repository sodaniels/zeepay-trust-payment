//
//  ViewControllerFactory.swift
//  TrustPaymentsUI
//

#if !COCOAPODS
    import TrustPayments3DSecure
    import TrustPaymentsCard
    import TrustPaymentsCore
#endif
import Foundation
import UIKit

/// A view controller factory singleton providing a new instance of DropInViewController.
/// ```
/// do {
///    let dropInVC = try ViewControllerFactory.shared.dropInViewController(/* Set parameters */)
///    push(dropInVC.viewController, animated: true)
/// } catch {
///    // show alert - message: error.localizedDescription
/// }
/// ```
@objc public final class ViewControllerFactory: NSObject {
    @objc public static let shared = ViewControllerFactory()

    override private init() {}

    /// creates instances of the DropInViewController
    /// - Parameters:
    ///   - jwt: JWT token - set if possible, otherwise update JWT in payButtonTappedClosureBeforeTransaction closure
    ///   - customDropInView: DropInViewProtocol compliant view (for example, to add some additional fields such as address, tip)
    ///   - visibleFields: Specify which card details input fields should be visible
    ///   - applePayConfiguration: configured PKPaymentRequest with merchant ID and product information as well as button styles
    ///   - apmsConfiguration: Instance on TPAPMConfiguration with desired settings for supported APMs
    ///   - dropInViewStyleManager: instance of manager to customize view
    ///   - dropInViewDarkModeStyleManager: instance of dark mode manager to customize view
    ///   - cardinalStyleManager: manager to set the interface style (view customization)
    ///   - cardinalDarkModeStyleManager: manager to set the interface style in dark mode
    ///   - payButtonTappedClosureBeforeTransaction: Closure triggered by pressing the pay button (just before the transaction - you can use this closure to update the JWT token)
    ///   - transactionResponseClosure: closure triggered after the transaction is completed, with the following parameters: JWT key array with responses from all requests (before decoding, the signature of each key should be verified) | an object that contains 3ds authentication data sent with AUTH request | an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    /// - Returns: instance of DropInViewController
    public func dropInViewController(jwt: String?,
                                     customDropInView: DropInViewProtocol? = nil,
                                     visibleFields: [DropInViewVisibleFields] = DropInViewVisibleFields.default,
                                     applePayConfiguration: TPApplePayConfiguration? = nil,
                                     apmsConfiguration: TPAPMConfiguration? = nil,
                                     dropInViewStyleManager: DropInViewStyleManager? = nil,
                                     dropInViewDarkModeStyleManager: DropInViewStyleManager? = nil,
                                     cardinalStyleManager: CardinalStyleManager? = nil,
                                     cardinalDarkModeStyleManager: CardinalStyleManager? = nil,
                                     payButtonTappedClosureBeforeTransaction: ((DropInController) -> Void)?,
                                     transactionResponseClosure: @escaping ([String], TPAdditionalTransactionResult?, APIClientError?) -> Void) throws -> DropInController {
        let dropInView = customDropInView ?? DropInView(dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager)

        let viewController = try DropInViewController(view: dropInView,
                                                      viewModel: DropInViewModel(jwt: jwt,
                                                                                 applePayConfiguration: applePayConfiguration,
                                                                                 apmsConfiguration: apmsConfiguration,
                                                                                 cardinalStyleManager: cardinalStyleManager,
                                                                                 cardinalDarkModeStyleManager: cardinalDarkModeStyleManager,
                                                                                 visibleFields: visibleFields))

        viewController.eventTriggered = { event in
            switch event {
            case let .transactionResponseClosure(jwt, transactionResult, error):
                transactionResponseClosure(jwt, transactionResult, error)
            case let .payButtonTappedClosureBeforeTransaction(controller):
                guard let payButtonTappedClosureBeforeTransaction = payButtonTappedClosureBeforeTransaction else {
                    controller.continue()
                    return
                }
                payButtonTappedClosureBeforeTransaction(controller)
            }
        }

        return viewController
    }

    // MARK: Objective C accessible methods

    // objc workaround
    /// creates instances of the DropInViewController
    /// - Parameters:
    ///   - jwt: JWT token - set if possible, otherwise update JWT in payButtonTappedClosureBeforeTransaction closure
    ///   - visibleFields: Specify which card details input fields should be visible
    ///   - applePayConfiguration: configured PKPaymentRequest with merchant ID and product information as well as with button styles
    ///   - apmsConfiguration: Instance on TPAPMConfiguration with desired settings for supported APMs
    ///   - dropInViewStyleManager: instance of manager to customize view
    ///   - dropInViewDarkModeStyleManager: instance of dark mode manager to customize view
    ///   - cardinalStyleManager: manager to set the interface style (view customization)
    ///   - cardinalDarkModeStyleManager: manager to set the interface style in dark mode
    ///   - customDropInView: DropInViewProtocol compliant view (for example, to add some additional fields such as address, tip)
    ///   - payButtonTappedClosureBeforeTransaction: Closure triggered by pressing the pay button (just before the transaction - you can use this closure to update the JWT token)

    ///   - transactionResponseClosure: closure triggered after the transaction is completed, with the following parameters: JWT key array with responses from all requests (before decoding, the signature of each key should be verified) | an object that contains 3ds authentication data sent with AUTH request | an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    /// - Returns: instance of DropInViewController
    @available(swift, obsoleted: 1.0)
    @objc public func dropInViewController(jwt: String?,
                                           customDropInView: DropInViewProtocol? = nil,
                                           visibleFields: [Int] = DropInViewVisibleFields.default.map(\.rawValue),
                                           applePayConfiguration: TPApplePayConfiguration? = nil,
                                           apmsConfiguration: TPAPMConfiguration? = nil,
                                           dropInViewStyleManager: DropInViewStyleManager? = nil,
                                           dropInViewDarkModeStyleManager: DropInViewStyleManager? = nil,
                                           cardinalStyleManager: CardinalStyleManager? = nil,
                                           cardinalDarkModeStyleManager: CardinalStyleManager? = nil,
                                           payButtonTappedClosureBeforeTransaction: ((DropInController) -> Void)?,
                                           transactionResponseClosure: @escaping ([String], TPAdditionalTransactionResult?, NSError?) -> Void) throws -> DropInController {
        let convertedVisibleFields = visibleFields.compactMap { DropInViewVisibleFields(rawValue: $0) }

        return try dropInViewController(jwt: jwt,
                                        customDropInView: customDropInView,
                                        visibleFields: convertedVisibleFields,
                                        applePayConfiguration: applePayConfiguration,
                                        apmsConfiguration: apmsConfiguration,
                                        dropInViewStyleManager: dropInViewStyleManager,
                                        dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager,
                                        cardinalStyleManager: cardinalStyleManager,
                                        cardinalDarkModeStyleManager: cardinalDarkModeStyleManager,
                                        payButtonTappedClosureBeforeTransaction: payButtonTappedClosureBeforeTransaction,
                                        transactionResponseClosure: { jwt, transactionResult, error in
                                            transactionResponseClosure(jwt, transactionResult, error?.foundationError)
                                        })
    }
}
