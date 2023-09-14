//
//  DropInCustomViewWithTipOption.swift
//  Example
//

import UIKit

public final class DropInCustomViewWithTipOption: DropInView {
    var tipComponentValueChanged: ((Int) -> Void)?
    var baseAmount: Int
    private let tipAmount: Int

    private let container: UIView = UIView()

    private lazy var tipOptionView: ToggleOptionView = {
        let toggle = ToggleOptionView()
        toggle.toggleButton.accessibilityIdentifier = "tipSwitch"
        return toggle
    }()

    private lazy var baseAmountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var amountsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tipOptionView, baseAmountLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()

    init(dropInViewStyleManager: DropInViewStyleManager?, dropInViewDarkModeStyleManager: DropInViewStyleManager?, tipAmount: Int, baseAmount: Int) {
        self.tipAmount = tipAmount
        self.baseAmount = baseAmount
        super.init(dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func setupViewHierarchy() {
        super.setupViewHierarchy()
        container.addSubview(amountsStackView)
        stackView.insertArrangedSubview(container, at: max(stackView.arrangedSubviews.count - 1, 0))
    }

    override public func setupProperties() {
        super.setupProperties()
        let selectedTipColor = UIColor(light: .black, dark: .white)
        tipOptionView.color = .lightGray
        tipOptionView.title = String(format: "£%.2f \(Localizable.DropInCustomViewWithTipOption.tip.text)", Double(tipAmount) / 100.0)
        baseAmountLabel.text = String(format: "\(Localizable.DropInCustomViewWithTipOption.total.text) £%.2f", Double(baseAmount) / 100.0)

        tipOptionView.valueChanged = { [unowned self] isSelected in
            self.baseAmount += isSelected ? self.tipAmount : -self.tipAmount
            self.baseAmountLabel.text = String(format: "\(Localizable.DropInCustomViewWithTipOption.total.text) £%.2f", Double(self.baseAmount) / 100.0)
            self.tipOptionView.color = isSelected ? selectedTipColor : .lightGray
            self.tipComponentValueChanged?(self.baseAmount)
        }
    }

    override public func setupConstraints() {
        super.setupConstraints()
        amountsStackView.addConstraints([
            equal(container, \.topAnchor, constant: 0),
            equal(container, \.bottomAnchor, constant: 0),
            equal(container, \.centerXAnchor, constant: 0)
        ])
    }
}

private extension Localizable {
    enum DropInCustomViewWithTipOption: String, Localized {
        case tip
        case total
    }
}
