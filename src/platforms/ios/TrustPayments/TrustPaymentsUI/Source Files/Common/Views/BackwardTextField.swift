//
//  BackwardTextfield.swift
//  TrustPaymentsUI
//

import UIKit

class BackwardTextField: UITextField {
    override open var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var deleteLastCharCallback: ((UITextField) -> Void)?

    override open var text: String? {
        didSet {
            if (text ?? .empty).isEmpty {
                deleteLastCharCallback?(self)
            } else if text == UITextField.emptyCharacter {
                drawPlaceholder(in: textInputView.bounds)
            }
            setNeedsDisplay()
        }
    }

    override open func draw(_ rect: CGRect) {
        if text == .empty || text == UITextField.emptyCharacter {
            super.drawPlaceholder(in: rect)
        } else {
            super.draw(rect)
        }
    }

    override open func drawPlaceholder(in _: CGRect) {}
}
