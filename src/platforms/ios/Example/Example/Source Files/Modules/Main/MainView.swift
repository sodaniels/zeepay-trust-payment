//
//  MainView.swift
//  Example
//

import UIKit

final class MainView: BaseView {
    /// data source for table view
    weak var dataSource: MainViewModelDataSource?

    /// Activity indicator showing that something is processing
    fileprivate lazy var loaderView: LoaderView = LoaderView()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(dequeueableCell: MainViewTableViewCell.self)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    fileprivate lazy var highlightViewsControl: UIView = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleAction(_:)), for: .valueChanged)
        let label = UILabel()
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.text = "Highlight views based on responsibility"

        let legendLabel = UILabel()
        let legendAttrString = NSMutableAttributedString(string: "---", attributes: [.foregroundColor: UIColor.green,
                                                                                     .font: UIFont.boldSystemFont(ofSize: 20)])
        let merchSecond = NSAttributedString(string: " Merchant", attributes: [.foregroundColor: UIColor.black])
        legendAttrString.append(merchSecond)
        let sdkFirst = NSMutableAttributedString(string: "  ---", attributes: [.foregroundColor: UIColor.red,
                                                                               .font: UIFont.boldSystemFont(ofSize: 20)])
        legendAttrString.append(sdkFirst)
        let sdkSecond = NSAttributedString(string: " SDK", attributes: [.foregroundColor: UIColor.black])
        legendAttrString.append(sdkSecond)
        legendLabel.attributedText = legendAttrString

        let rightStack = UIStackView(arrangedSubviews: [label, legendLabel])
        rightStack.axis = .vertical
        rightStack.distribution = .equalSpacing
        rightStack.alignment = .fill
        let stack = UIStackView(arrangedSubviews: [toggle, rightStack])
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    // callbacks for selected rows
    // swiftlint:disable identifier_name
    var makeAuthRequestButtonTappedClosure: (() -> Void)?
    var showSingleInputViewsButtonTappedClosure: (() -> Void)?
    var showDropInControllerButtonTappedClosure: (() -> Void)?
    var accountCheckRequest: (() -> Void)?
    var accountCheckWithAuthRequest: (() -> Void)?
    var addCardReferenceRequest: (() -> Void)?
    var payWithWalletRequest: (() -> Void)?
    var presentWalletWithCardTypesToBypass: (() -> Void)?
    var subscriptionOnTPEngineRequest: (() -> Void)?
    var subscriptionOnMerchantEngineRequest: (() -> Void)?
    var showMoreInformation: ((String) -> Void)?
    var showDropInControllerNoThreeDQuery: (() -> Void)?
    var showDropInControllerWithCustomView: (() -> Void)?
    var payByCardFromParentReference: (() -> Void)?
    var payFillCVV: (() -> Void)?
    var payByCustomForm: (() -> Void)?
    var showDropInControllerWithApplePay: (() -> Void)?
    var showDropInControllerWithCustomViewAndTip: (() -> Void)?
    var showDropInControllerWithRiskDec: (() -> Void)?
    var showDropInControllerWithJWTUpdates: (() -> Void)?
    var showMerchantApplePay: (() -> Void)?
    var showDropInControllerWithCardTypesToBypass: (() -> Void)?
    var showDropInControllerWithZIP: (() -> Void)?
    var showDropInControllerWithATA: (() -> Void)?
    var showStyleManagerInitializationView: (() -> Void)?
    var showDarkModeStyleManagerInitializationView: (() -> Void)?
    var applePayWithTypeDescriptionSelection: (() -> Void)?
    var performThreeDQueryV2AndLaterAuth: (() -> Void)?
    var performThreeDQueryV1AndLaterAuth: (() -> Void)?
    var performAccountCheckThreeDQueryV2AndLaterAuth: (() -> Void)?
    var performAccountCheckThreeDQueryV1AndLaterAuth: (() -> Void)?
    var performAuthZIP: (() -> Void)?
    var performAuthATA: (() -> Void)?
    // swiftlint:enable identifier_name

    @objc func toggleAction(_ sender: UISwitch) {
        StyleManager.shared.highlightViewsBasedOnResponsibility = sender.isOn
    }

    func showLoader(show: Bool) {
        if show {
            addSubview(loaderView)
            loaderView.addConstraints([
                equal(self, \.topAnchor, constant: 0),
                equal(self, \.bottomAnchor, constant: 0),
                equal(self, \.leadingAnchor, constant: 0),
                equal(self, \.trailingAnchor, constant: 0)
            ])
            loaderView.start()
        } else {
            loaderView.stop()
            loaderView.removeFromSuperview()
        }
    }
}

extension MainView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupProperties() {
        backgroundColor = UIColor(light: .white, dark: .black)
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        addSubviews([tableView, highlightViewsControl])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        tableView.addConstraints([
            equal(self, \.topAnchor, \.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(highlightViewsControl, \.bottomAnchor, \.topAnchor, constant: -10),
            equal(self, \.leadingAnchor, constant: 0),
            equal(self, \.trailingAnchor, constant: 0)
        ])
        highlightViewsControl.addConstraints([
            equal(self, \.bottomAnchor, \.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            equal(self, \.leadingAnchor, constant: 20),
            equal(self, \.trailingAnchor, constant: -20)
        ])
    }
}

// MARK: Wallet view table data source and delegate

extension MainView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource?.row(at: indexPath)
        let cell = tableView.dequeue(dequeueableCell: MainViewTableViewCell.self)
        cell.configure(title: row?.title, hasDetailedInfo: row?.hasDetailedInfo ?? false)
        cell.accessibilityIdentifier = row?.identifier
        return cell
    }

    func numberOfSections(in _: UITableView) -> Int {
        dataSource?.numberOfSections() ?? 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.numberOfRows(at: section) ?? 0
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = dataSource?.title(for: section) {
            let header = UIView()
            header.backgroundColor = UIColor.groupTableViewBackground
            let label = UILabel()
            label.text = title
            label.numberOfLines = 0
            header.addSubview(label)
            label.addConstraints([
                equal(header, \.topAnchor, \.topAnchor, constant: 2),
                equal(header, \.bottomAnchor, \.bottomAnchor, constant: 2),
                equal(header, \.leadingAnchor, \.leadingAnchor, constant: 20),
                equal(header, \.trailingAnchor, \.trailingAnchor, constant: -20)
            ])
            return header
        }
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        40
    }

    // swiftlint:disable cyclomatic_complexity
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let row = dataSource?.row(at: indexPath) else { return }
        switch row {
        case .performAuthRequestInBackground:
            makeAuthRequestButtonTappedClosure?()
        case .presentSingleInputComponents:
            showSingleInputViewsButtonTappedClosure?()
        case .presentPayByCardForm:
            showDropInControllerButtonTappedClosure?()
        case .performAccountCheck:
            accountCheckRequest?()
        case .performAccountCheckWithAuth:
            accountCheckWithAuthRequest?()
        case .presentAddCardForm:
            addCardReferenceRequest?()
        case .presentWalletForm:
            payWithWalletRequest?()
        case .presentWalletWithCardTypesToBypass:
            presentWalletWithCardTypesToBypass?()
        case .subscriptionOnTPEngine:
            subscriptionOnTPEngineRequest?()
        case .subscriptionOnMerchantEngine:
            subscriptionOnMerchantEngineRequest?()
        case .showDropInControllerNo3DSecure:
            showDropInControllerNoThreeDQuery?()
        case .showDropInControllerWithCustomView:
            showDropInControllerWithCustomView?()
        case .payByCardFromParentReference:
            payByCardFromParentReference?()
        case .payFillCVV:
            payFillCVV?()
        case .payByCustomForm:
            payByCustomForm?()
        case .applePay:
            showDropInControllerWithApplePay?()
        case .showDropInControllerWithCustomViewAndTip:
            showDropInControllerWithCustomViewAndTip?()
        case .showDropInControllerWithRiskDec:
            showDropInControllerWithRiskDec?()
        case .showDropInControllerWithJWTUpdates:
            showDropInControllerWithJWTUpdates?()
        case .merchantApplePay:
            showMerchantApplePay?()
        case .dropInControllerWithCardTypesToBypass:
            showDropInControllerWithCardTypesToBypass?()
        case .showDropInControllerWithZIP:
            showDropInControllerWithZIP?()
        case .showDropInControllerWithATA:
            showDropInControllerWithATA?()
        case .showStyleManagerInitView:
            showStyleManagerInitializationView?()
        case .showDarkModeStyleManagerInitView:
            showDarkModeStyleManagerInitializationView?()
        case .applePayWithTypeDescriptionSelection:
            applePayWithTypeDescriptionSelection?()
        case .performThreeDQueryV2AndLaterAuth:
            performThreeDQueryV2AndLaterAuth?()
        case .performThreeDQueryV1AndLaterAuth:
            performThreeDQueryV1AndLaterAuth?()
        case .performAccountCheckThreeDQueryV2AndLaterAuth:
            performAccountCheckThreeDQueryV2AndLaterAuth?()
        case .performAccountCheckThreeDQueryV1AndLaterAuth:
            performAccountCheckThreeDQueryV1AndLaterAuth?()
        case .performAuthZIP:
            performAuthZIP?()
        case .performAuthATA:
            performAuthATA?()
        }
    }

    // swiftlint:enable cyclomatic_complexity

    func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let info = dataSource?.detailInformationForRow(at: indexPath) {
            showMoreInformation?(info)
        }
    }
}
