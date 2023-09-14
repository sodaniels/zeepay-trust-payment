//
//  TipOptionView.swift
//  Example
//

import UIKit

/// A View made of UISwitch and UILabel for selecting whether a card used for transaction should be stored or whether a tip should be added
final class ToggleOptionView: BaseView {
    // MARK: Properties

    lazy var toggleButton: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.addTarget(self, action: #selector(ToggleOptionView.toggleValueChanged(sender:)), for: .valueChanged)
        return toggle
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [toggleButton, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()

    // MARK: Public properties

    // Callback triggered by switching the toggle button
    var valueChanged: ((Bool) -> Void)?

    var isToggleEnabled: Bool {
        toggleButton.isOn
    }

    // MARK: - texts

    var title: String = "default" {
        didSet {
            titleLabel.text = title
        }
    }

    // MARK: - colors

    var color: UIColor = .black {
        didSet {
            titleLabel.textColor = color
        }
    }

    // MARK: - fonts

    var titleFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            titleLabel.font = titleFont
        }
    }

    // MARK: - functions

    @objc func toggleValueChanged(sender: UISwitch) {
        valueChanged?(sender.isOn)
    }
}

extension ToggleOptionView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        backgroundColor = .clear
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        addSubviews([stackView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        stackView.addConstraints(equalToSuperview())
    }
}
