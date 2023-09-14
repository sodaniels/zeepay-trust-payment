//
//  DropInViewCustomView.swift
//  Example
//

import UIKit

public final class DropInCustomViewWithSaveCardOption: DropInView {
    var saveCardComponentValueChanged: ((Bool) -> Void)?
    var isSaveCardSelected: Bool = false

    private lazy var saveCardOptionView: ToggleOptionView = {
        let toggle = ToggleOptionView()
        toggle.toggleButton.accessibilityIdentifier = "saveCardSwitch"
        return toggle
    }()

    override public func setupViewHierarchy() {
        super.setupViewHierarchy()
        stackView.insertArrangedSubview(saveCardOptionView, at: max(stackView.arrangedSubviews.count - 1, 0))
    }

    override public func setupProperties() {
        super.setupProperties()
        saveCardOptionView.title = Localizable.SaveCardOptionView.title.text
        saveCardOptionView.valueChanged = { [weak self] isSelected in
            self?.isSaveCardSelected = isSelected
            self?.saveCardComponentValueChanged?(isSelected)
        }
    }
}

private extension Localizable {
    enum SaveCardOptionView: String, Localized {
        case title
    }
}
