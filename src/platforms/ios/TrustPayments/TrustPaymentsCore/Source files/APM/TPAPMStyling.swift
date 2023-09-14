//
//  TPAPMStyling.swift
//  TrustPaymentsCore
//

import Foundation
import UIKit

/// Used for optional styling properties of web view, on which final apm's redirection takes place
public protocol TPAPMStyling {
    /// Optional title for navigation header of web view, if not set a default value will be set
    var headerTitle: String? { get }
    /// Optional color for navigation header of web view, if not set a default value will be set
    var headerColor: UIColor? { get }
}
