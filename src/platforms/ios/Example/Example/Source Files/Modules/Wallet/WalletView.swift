//
//  WalletView.swift
//  Example
//

import UIKit

/// An example implementation of Wallet functionality
final class WalletView: BaseView {
    public private(set) lazy var nextButton: NextButton = NextButton()

    // MARK: Callbacks

    /// Tapped on next button
    var nextButtonTappedClosure: (() -> Void)? {
        get { nextButton.onTap }
        set { nextButton.onTap = newValue }
    }

    /// Selected a card reference from a list
    var cardFromWalletSelected: ((TPCardReference) -> Void)?

    /// Remove a card reference from a list
    var cardFromWalletRemoved: ((TPCardReference) -> Void)?

    /// Data source for table view
    weak var dataSource: WalletViewModelDataSource?

    /// Called by selecting Add new Payment method cell
    var addNewPaymentMethod: (() -> Void)?

    // MARK: View hierarchy

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(dequeueableCell: WalletCardTableViewCell.self)
        tableView.register(dequeueableCell: WalletAddCardTableViewCell.self)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.accessibilityIdentifier = "savedCardsTableView"
        return tableView
    }()

    /// Reloads table after adding a new payment method
    /// - Parameter cards: New card that has been added
    @objc public func reloadCards() {
        tableView.reloadData()
    }
}

extension WalletView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        addSubview(nextButton)
        addSubviews([tableView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        nextButton.addConstraints([
            equal(self, \.bottomAnchor, \.bottomAnchor, constant: -40),
            equal(self, \.leadingAnchor, \.leadingAnchor, constant: 20),
            equal(self, \.trailingAnchor, \.trailingAnchor, constant: -20)
        ])

        tableView.addConstraints([
            equal(self, \.topAnchor, \.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(nextButton, \.bottomAnchor, \.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            equal(self, \.leadingAnchor, constant: 0),
            equal(self, \.trailingAnchor, constant: 0)
        ])
    }

    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        backgroundColor = UIColor(light: .white, dark: .black)
    }
}

// MARK: Wallet view table data source and delegate

extension WalletView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = dataSource?.row(at: indexPath) else {
            fatalError("Where is the row")
        }
        switch row {
        case let .cardReference(cardReference):
            let cell = tableView.dequeue(dequeueableCell: WalletCardTableViewCell.self)
            cell.configure(cardReference: cardReference)
            cell.accessibilityIdentifier = "add\(cardReference.cardType)Reference"
            return cell
        case let .addCard(title):
            let cell = tableView.dequeue(dequeueableCell: WalletAddCardTableViewCell.self)
            cell.configure(title: title)
            cell.accessibilityIdentifier = "addPaymentMethodButton"
            return cell
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        dataSource?.numberOfSections() ?? 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.numberOfRows(at: section) ?? 0
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource?.row(at: indexPath) {
        case .addCard: return 44
        case .cardReference: return 70
        case .none: return 0
        }
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = dataSource?.title(for: section) {
            let header = UIView()
            header.backgroundColor = UIColor.groupTableViewBackground
            let label = UILabel()
            label.text = title
            label.textColor = UIColor.gray
            label.numberOfLines = 0
            header.addSubview(label)
            label.addConstraints([
                equal(header, \.topAnchor, \.topAnchor, constant: 2),
                equal(header, \.bottomAnchor, \.bottomAnchor, constant: 2),
                equal(header, \.leadingAnchor, \.leadingAnchor, constant: 20),
                equal(header, \.trailingAnchor, \.trailingAnchor, constant: -20)
            ])
            header.highlightIfNeeded()
            return header
        }
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch dataSource?.section(at: section) {
        case .paymentMethods: return 40
        case let .addMethod(showHeader, _): return showHeader ? 70 : 0
        case .none: return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = dataSource?.row(at: indexPath) else { return }
        switch row {
        case let .cardReference(card):
            cardFromWalletSelected?(card)
            nextButton.isEnabled = true
            nextButton.accessibilityIdentifier = "nextButton"
        case .addCard:
            nextButton.isEnabled = false
            tableView.deselectRow(at: indexPath, animated: false)
            addNewPaymentMethod?()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let row = dataSource?.row(at: indexPath) else { return }
            switch row {
            case let .cardReference(card):
                cardFromWalletRemoved?(card)
            case .addCard:
                return
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 { return false }
        return true
    }
}
