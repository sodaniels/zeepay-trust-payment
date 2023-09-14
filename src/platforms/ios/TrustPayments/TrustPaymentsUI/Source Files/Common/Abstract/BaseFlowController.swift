//
//  BaseFlowController.swift
//  TrustPaymentsUI
//

import UIKit

class BaseFlowController: NSObject, FlowController {
    // MARK: Properties

    /// Flow controller root view controller.
    var rootViewController: UIViewController?

    /// An object which is responsible for navigation.
    weak var navigationDelegate: NavigationDelegate?
}
