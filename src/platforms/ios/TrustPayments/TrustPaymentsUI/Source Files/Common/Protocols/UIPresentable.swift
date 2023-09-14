//
//  UIPresentable.swift
//  TrustPaymentsUI
//

import UIKit

// Default implementation returning `self` as `UIViewController`.
extension UIPresentable where Self: UIViewController {
    var viewController: UIViewController {
        self
    }
}

/// Specifies behaviour of an object presentable within the application UI.
@objc public protocol UIPresentable: AnyObject {
    /// View controller to be added to the UI hierarchy.
    @objc var viewController: UIViewController { get }
}
