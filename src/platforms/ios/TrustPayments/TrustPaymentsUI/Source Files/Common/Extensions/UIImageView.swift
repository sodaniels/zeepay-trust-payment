//
//  UIImageVIew.swift
//  TrustPaymentsUI
//

import UIKit.UIImageView

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = image?.withRenderingMode(.alwaysTemplate)
        image = templateImage
        tintColor = color
    }
}
