//
//  TPApplePayConfiguration.swift
//  TrustPaymentsCore
//

import PassKit

/// Apple Pay configuration handler.
///
/// Conform to this protocol in `TPApplePayConfiguration` init method to respond to user's data changes
/// E.g: check if can still ship products to updated shipping address
@objc public protocol TPApplePayConfigurationHandler: AnyObject {
    /// Update summary items to reflect possible change in total price
    /// - Parameters:
    ///   - method: New shipping Method
    ///   - updatedWith: Set new summary items or empty array if no change is required
    func shippingMethodChanged(to method: PKShippingMethod, updatedWith: @escaping ([PKPaymentSummaryItem]) -> Void)

    /// Check if still can ship to updated address
    /// - Parameters:
    ///   - address: New address
    ///   - updatedWith: Set new summary items or empty array if no change is required
    func shippingAddressChanged(to address: CNPostalAddress, updatedWith: @escaping ([Error]?, [PKPaymentSummaryItem]) -> Void)

    /// Extract billing and shipping details from payment object as well as shipping method and payment token. Update JWT and allow to proceed with TP request or return an error if data is missing
    /// - Parameters:
    ///   - payment: Payment object
    ///   - updatedRequestParameters: Pass updated JWT and Apple pay token and shipping information or errors if data is missing
    func didAuthorizedPayment(payment: PKPayment, updatedRequestParameters: @escaping ((_ jwt: String?, _ walletToken: String?, [Error]?) -> Void))

    /// Authorization has been cancelled by user or Apple framework
    func didCancelPaymentAuthorization()
}

/// Configuration object.
///
/// Handles communication between PassKit and user, set configuration handler to receive data updates.
@objc public class TPApplePayConfiguration: NSObject {
    weak var configurationHandler: TPApplePayConfigurationHandler?

    /// Initial request
    let request: PKPaymentRequest
    let buttonStyle: PKPaymentButtonStyle
    let buttonDarkModeStyle: PKPaymentButtonStyle
    let buttonType: PKPaymentButtonType

    /// Configured and styled
    var payButton: ApplePayButton? {
        guard isApplePayAvailable else { return nil }
        return ApplePayButton(style: buttonStyle, darkModeStyle: buttonDarkModeStyle, type: buttonType)
    }

    /// Called after successful authorization with JWT containig Apple Pay token
    var proceedAfterApplePayAuthorization: ((String, String) -> Void)?

    /// Initialization of the configuration object
    /// - Parameters:
    ///   - handler: TPApplePayConfigurationHandler used for updating contact/shipping data
    ///   - request: Initial PKPaymentRequest, used to initialize PKPaymentAuthorizationViewController
    ///   - buttonStyle: Button style that should be applied
    ///   - buttonDarkModeStyle: Button style that should be applied for dark mode
    ///   - buttonType: Button type that should be applied
    /// # Note: #
    /// The minimum configuration of PKPaymentRequest has to be provided, otherwise the authentication will fail:
    /// ```
    /// let request = PKPaymentRequest()
    /// request.supportedNetworks = [.visa, .masterCard, .amex]
    /// request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]
    /// request.merchantIdentifier = "merchantID"
    /// request.countryCode = "GB"
    /// request.currencyCode = "GBP"
    /// ```
    @objc public init(handler: TPApplePayConfigurationHandler?, request: PKPaymentRequest, buttonStyle: PKPaymentButtonStyle, buttonDarkModeStyle: PKPaymentButtonStyle, buttonType: PKPaymentButtonType) {
        configurationHandler = handler
        self.request = request
        self.buttonStyle = buttonStyle
        self.buttonDarkModeStyle = buttonDarkModeStyle
        self.buttonType = buttonType
    }

    /// Checks if initial request can be handled by the end user configuration
    public var isApplePayAvailable: Bool {
        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: request.supportedNetworks, capabilities: request.merchantCapabilities)
    }

    /// Update shipping method
    /// Called only on actual change
    /// - Parameters:
    ///   - method: Updated shipping method
    ///   - completionHandler: Return new summary items updated with new delivery costs
    func updateShippingMethod(with method: PKShippingMethod, completionHandler: @escaping ((_ newSummaryItems: [PKPaymentSummaryItem]) -> Void)) {
        guard configurationHandler != nil else {
            completionHandler([])
            return
        }
        configurationHandler?.shippingMethodChanged(to: method, updatedWith: { updatedItems in
            completionHandler(updatedItems)
        })
    }

    /// Used to check if based on country, post code and city, merchant can still ship item to chosen location
    /// the rest of the details will be provided after authorization request
    /// Parse PKcontact and provide callback to merchant to check if still can ship
    /// - Parameters:
    ///   - contact: Updated contact details
    ///   - completionHandler:Return updated summary items or empty array if no change is required. Return error if can't ship to updated error (PKPaymentError)
    func updateShippingContact(with contact: PKContact, completionHandler: @escaping ((_ errors: [Error]?, _ newSummaryItems: [PKPaymentSummaryItem]) -> Void)) {
        guard configurationHandler != nil else {
            completionHandler(nil, [])
            return
        }
        guard let updatedAddress = contact.postalAddress else {
            completionHandler(nil, [])
            return
        }

        // check if can still post to the new address
        configurationHandler?.shippingAddressChanged(to: updatedAddress, updatedWith: { errors, updatedItems in
            completionHandler(errors, updatedItems)
        })
    }

    /// Update payment request
    /// called when user changed card or billing info
    /// billing address only provided from ios 13+ and also only when shipping address is not provided
    /// - Parameters:
    ///   - method: Updated payment method containing new postal address
    ///   - completionHandler: Return updated summary items or empty array if no change is required. Return error if can't ship to updated error (PKPaymentError)
    func updatePaymentMethod(with method: PKPaymentMethod, completionHandler: @escaping ((_ errors: [Error]?, _ newSummaryItems: [PKPaymentSummaryItem]) -> Void)) {
        guard configurationHandler != nil else {
            completionHandler(nil, [])
            return
        }
        if #available(iOS 13.0, *) {
            guard let shippingAddress = method.billingAddress?.postalAddresses.first?.value else {
                completionHandler(nil, [])
                return
            }
            configurationHandler?.shippingAddressChanged(to: shippingAddress, updatedWith: { errors, updatedItems in
                completionHandler(errors, updatedItems)
            })
        } else {
            completionHandler(nil, [])
            return
        }
    }

    /// Extract card info, billing and shipping address and shipping method
    /// Note payment data is empty on simulator, test on device
    /// - Parameters:
    ///   - payment: Authorized payment object
    ///   - proceed: Stops if error is set
    func transactionHasBeenAuthorized(payment: PKPayment, proceed: @escaping (([Error]?) -> Void)) {
        guard configurationHandler != nil else {
            // handler is missing, no reason to continue
            proceed([PKPaymentError(.unknownError)])
            return
        }
        configurationHandler?.didAuthorizedPayment(payment: payment, updatedRequestParameters: { [weak self] jwt, walletToken, errors in
            proceed(errors)
            if let jwt = jwt, let token = walletToken {
                self?.proceedAfterApplePayAuthorization?(jwt, token)
            }
        })
    }
}

// MARK: PKPaymentAuthorizationViewControllerDelegate

extension TPApplePayConfiguration: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        configurationHandler?.didCancelPaymentAuthorization()
        controller.dismiss(animated: true)
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        transactionHasBeenAuthorized(payment: payment) { errors in
            if let errors = errors {
                completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
            } else {
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                controller.dismiss(animated: true)
            }
        }
    }

    public func paymentAuthorizationViewController(_: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
        updatePaymentMethod(with: paymentMethod, completionHandler: { errors, updatedSummaryItems in
            if #available(iOS 13.0, *) {
                completion(PKPaymentRequestPaymentMethodUpdate(errors: errors, paymentSummaryItems: updatedSummaryItems))
            } else {
                completion(PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: updatedSummaryItems))
            }
        })
    }

    public func paymentAuthorizationViewController(_: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        updateShippingMethod(with: shippingMethod, completionHandler: { updatedSummaryItems in
            completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: updatedSummaryItems))
        })
    }

    public func paymentAuthorizationViewController(_: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        updateShippingContact(with: contact, completionHandler: { errors, updatedSummaryItems in
            completion(PKPaymentRequestShippingContactUpdate(errors: errors, paymentSummaryItems: updatedSummaryItems, shippingMethods: []))
        })
    }
}
