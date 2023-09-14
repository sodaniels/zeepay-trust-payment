//
//  SelectCardTypesView.swift
//  Example
//

import UIKit

/// An example implementation of Wallet functionality
final class SelectCardTypesView: BaseView {
    /// Tapped on next button
    var nextButtonTappedClosure: (() -> Void)? {
        get { nextButton.onTap }
        set { nextButton.onTap = newValue }
    }

    public private(set) lazy var nextButton: NextButton = NextButton()

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
}

extension SelectCardTypesView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        addSubview(nextButton)
        addSubviews([tableView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        nextButton.addConstraints([
            equal(self, \.bottomAnchor, \.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            equal(self, \.leadingAnchor, \.leadingAnchor, constant: 20),
            equal(self, \.trailingAnchor, \.trailingAnchor, constant: -20)
        ])

        tableView.addConstraints([
            equal(self, \.topAnchor, \.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(nextButton, \.bottomAnchor, \.topAnchor, constant: -10),
            equal(self, \.leadingAnchor, constant: 0),
            equal(self, \.trailingAnchor, constant: 0)
        ])
    }

    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        backgroundColor = UIColor(light: .white, dark: .black)
    }
}