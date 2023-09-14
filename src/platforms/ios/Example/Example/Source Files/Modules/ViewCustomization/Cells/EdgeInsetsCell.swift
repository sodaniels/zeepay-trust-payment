//
//  EdgeInsetsCell.swift
//  Example
//

import UIKit

final class EdgeInsetsCell: BaseViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, sizeLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    func setupCell(row: StyleManagerInitializationViewModel.UIEdgeInsetsRow) {
        titleLabel.text = row.title
        // swiftlint:disable line_length
        sizeLabel.text = "\(Localizable.StyleManagerInitializationViewController.top.text): \(row.edgeInsets.top) | \(Localizable.StyleManagerInitializationViewController.left.text): \(row.edgeInsets.left) | \(Localizable.StyleManagerInitializationViewController.bottom.text): \(row.edgeInsets.bottom) | \(Localizable.StyleManagerInitializationViewController.right.text): \(row.edgeInsets.right)"
        // swiftlint:enable line_length
    }
}

extension EdgeInsetsCell: ViewSetupable {
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

private extension Localizable {
    enum StyleManagerInitializationViewController: String, Localized {
        case top
        case left
        case bottom
        case right
    }
}
