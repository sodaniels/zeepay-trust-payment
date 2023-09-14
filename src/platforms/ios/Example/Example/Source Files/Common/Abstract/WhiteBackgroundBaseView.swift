//
//  WhiteBackgroundBaseView.swift
//  Example
//

import UIKit

class WhiteBackgroundBaseView: BaseView {
    /// Initialize an instance and sets background image
    override init() {
        super.init()
        backgroundColor = UIColor.white
    }

    /// - SeeAlso: NSCoding.init?(coder:)
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
