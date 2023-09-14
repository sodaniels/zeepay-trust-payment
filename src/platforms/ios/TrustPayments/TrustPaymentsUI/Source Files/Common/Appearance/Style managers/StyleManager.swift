//
//  StyleManager.swift
//  TrustPaymentsUI
//

import UIKit

@objc public final class StyleManager: NSObject {
    public static let shared = StyleManager()
    public static let merchantHighlightColor = UIColor.green
    public static let sdkHighlightColor = UIColor.red

    override private init() {}

    /// Used for drawing red border around views that are provided by SDK
    /// Used for drawing green border around views that should be provided by merchants
    public var highlightViewsValueChanged: ((Bool) -> Void)?
    public var highlightViewsBasedOnResponsibility: Bool = false {
        didSet {
            highlightViewsValueChanged?(highlightViewsBasedOnResponsibility)
        }
    }
}
