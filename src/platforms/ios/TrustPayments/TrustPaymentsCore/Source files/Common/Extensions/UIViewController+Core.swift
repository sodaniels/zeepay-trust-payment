//
//  UIViewController+Core.swift
//  TrustPaymentsCore
//

import UIKit

extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }

        return self
    }
}

extension UIApplication {
    public var topMostViewController: UIViewController? {
        rootViewController?.topMostViewController
    }

    var rootViewController: UIViewController? {
        if #available(iOS 13.0, *) {
            return newKeyWindow?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
}

@available(iOS 13.0, *)
extension UIApplication {
    var newKeyWindow: UIWindow? {
        let keyWindow = activeScene?.windows
            .filter(\.isKeyWindow).first
        return keyWindow
    }

    var activeScene: UIWindowScene? {
        let scene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first
        return scene
    }
}
