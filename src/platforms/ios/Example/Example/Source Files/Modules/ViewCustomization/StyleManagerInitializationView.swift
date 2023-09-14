//
//  StyleManagerInitializationView.swift
//  Example
//

import UIKit

final class StyleManagerInitializationView: BaseView {
    /// Tapped on next button
    var nextButtonTappedClosure: (() -> Void)? {
        get { nextButton.onTap }
        set { nextButton.onTap = newValue }
    }

    private let nextButton: NextButton = {
        let button = NextButton()
        button.isEnabled = true
        return button
    }()

    private(set) var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
}

extension StyleManagerInitializationView: ViewSetupable {
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
