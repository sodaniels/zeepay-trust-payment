//
//  NavigationFlowController.swift
//  TrustPaymentsUI
//

import UIKit

protocol NavigationFlowController: FlowController {
    var navigationController: UINavigationController { get }
    var childFlowController: FlowController? { get }
}

extension NavigationFlowController {
    var rootViewController: UIViewController? {
        navigationController
    }
}
