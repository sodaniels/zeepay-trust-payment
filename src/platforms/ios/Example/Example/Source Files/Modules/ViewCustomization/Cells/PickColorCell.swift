//
//  PickColorCell.swift
//  Example
//

import UIKit

final class PickColorCell: BaseViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, colorView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    func setupCell(row: StyleManagerInitializationViewModel.UIColorRow) {
        titleLabel.text = row.title
        colorView.backgroundColor = row.color
    }
}

extension PickColorCell: ViewSetupable {
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
        stackView.addConstraints(equalToSuperview(with: .init(top: 0, left: 0, bottom: 0, right: 0), usingSafeArea: false))
    }
}
