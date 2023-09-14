//
//  DropInViewProtocol.swift
//  TrustPaymentsUI
//

import UIKit

/// Conforming to this protocol will allow you to inject your custom view into the DropIn VC.
@objc public protocol DropInViewProtocol: ViewProtocol {
    @objc var isFormValid: Bool { get }

    @objc var additionalFieldsToValidate: [InputValidation] { get }

    // this closure should be triggered when the pay button is pressed
    @objc var payButtonTappedClosure: (() -> Void)? { get set }

    // closure triggered when the Apple Pay button is pressed
    @objc var applePayButtonTappedClosure: (() -> Void)? { get set }

    // closure triggered when the ZIP button is pressed
    @objc var zipButtonTappedClosure: (() -> Void)? { get set }
    
    // closure triggered when the ATA button is pressed
    @objc var ataButtonTappedClosure: (() -> Void)? { get set }

    @objc var cardNumberInput: CardNumberInput { get }

    @objc var expiryDateInput: ExpiryDateInput { get }

    @objc var cvvInput: CVVInput { get }

    @objc var payButton: PayButtonProtocol { get }

    @objc var zipButton: ZipButtonProtocol { get }
    
    @objc var ataButton: ATAButtonProtocol { get }

    @objc func setupView(callback: ((UIView) -> Void)?)
}
