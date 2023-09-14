//
//  StyleManagerInitializationViewController.swift
//  Example
//

import UIKit

final class StyleManagerInitializationViewController: BaseViewController<StyleManagerInitializationView, StyleManagerInitializationViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case didTapNextButton(StylesManagerConfiguration)
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = viewModel.isDarkModeConfiguration ? Localizable.StyleManagerInitializationViewController.darkModeTitle.text : Localizable.StyleManagerInitializationViewController.title.text
        customView.tableView.register(dequeueableCell: PickColorCell.self)
        customView.tableView.register(dequeueableCell: PickFontCell.self)
        customView.tableView.register(dequeueableCell: SingleSizeCell.self)
        customView.tableView.register(dequeueableCell: HeightMarginsCell.self)
        customView.tableView.register(dequeueableCell: EdgeInsetsCell.self)
        customView.tableView.register(dequeueableCell: StringCell.self)
        customView.tableView.register(dequeueableCell: PickCardinalFontCell.self)
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        viewModel.showColorPickerTappedClosure = { [weak self] indexPath, selectedColor in
            guard let self = self else { return }
            let viewController = ColorPickerViewController(view: ColorPickerView(), viewModel: ColorPickerViewModel(selectedColor: selectedColor))

            viewController.eventTriggered = { [weak self] event in
                switch event {
                case let .selectedColor(color):
                    self?.viewModel.updateColorRow(at: indexPath, color: color)
                    self?.customView.tableView.beginUpdates()
                    self?.customView.tableView.reloadRows(at: [indexPath], with: .fade)
                    self?.customView.tableView.endUpdates()
                }
            }

            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true) {}
        }

        viewModel.showFontPickerTappedClosure = { [weak self] indexPath, _ in
            self?.showFontPicker(indexPath, false)
        }

        viewModel.showCardinalFontPickerTappedClosure = { [weak self] indexPath, _ in
            self?.showFontPicker(indexPath, true)
        }

        viewModel.showSingleSizePopupTappedClosure = { [weak self] indexPath, size in
            guard let self = self else { return }
            self.showAlertWithTextField(message: Localizable.StyleManagerInitializationViewController.enterNewSize.text, value: "\(size)") { newSize in
                guard let floatSize = (newSize as NSString?)?.floatValue else { return }
                let cgFloat = CGFloat(floatSize)
                self.viewModel.updateFloatRow(at: indexPath, size: cgFloat)
                self.customView.tableView.beginUpdates()
                self.customView.tableView.reloadRows(at: [indexPath], with: .fade)
                self.customView.tableView.endUpdates()
            }
        }

        viewModel.showHeightMarginsPopupTappedClosure = { [weak self] indexPath, size in
            guard let self = self else { return }
            // swiftlint:disable line_length
            self.showAlertWithDoubleTextField(message: Localizable.StyleManagerInitializationViewController.enterNewSizeTopBottom.text, firstPlaceholder: Localizable.StyleManagerInitializationViewController.top.text, secondPlaceholder: Localizable.StyleManagerInitializationViewController.bottom.text, firstValue: size.top, secondValue: size.bottom) { top, bottom in
                guard let topFloatSize = (top as NSString?)?.floatValue, let bottomFloatSize = (bottom as NSString?)?.floatValue else { return }
                let cgTopFloat = CGFloat(topFloatSize)
                let cgBottomFloat = CGFloat(bottomFloatSize)
                let newHeightMargins = HeightMargins(top: cgTopFloat, bottom: cgBottomFloat)
                self.viewModel.updateHeightMarginsRow(at: indexPath, size: newHeightMargins)
                self.customView.tableView.beginUpdates()
                self.customView.tableView.reloadRows(at: [indexPath], with: .fade)
                self.customView.tableView.endUpdates()
            }
            // swiftlint:enable line_length
        }

        viewModel.showEdgeInsetsPopupTappedClosure = { [weak self] indexPath, edgeInsets in
            guard let self = self else { return }
            // swiftlint:disable line_length
            self.showAlertWithFourFoldTextField(message: Localizable.StyleManagerInitializationViewController.enterNewEdgeInsets.text, placeholders: [Localizable.StyleManagerInitializationViewController.top.text, Localizable.StyleManagerInitializationViewController.left.text, Localizable.StyleManagerInitializationViewController.bottom.text, Localizable.StyleManagerInitializationViewController.right.text], values: [edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right]) { top, left, bottom, right in
                guard let topFloatSize = (top as NSString?)?.floatValue, let leftFloatSize = (left as NSString?)?.floatValue, let bottomFloatSize = (bottom as NSString?)?.floatValue, let rightFloatSize = (right as NSString?)?.floatValue else { return }
                let cgTopFloat = CGFloat(topFloatSize)
                let cgLeftFloat = CGFloat(leftFloatSize)
                let cgBottomFloat = CGFloat(bottomFloatSize)
                let cgRightFloat = CGFloat(rightFloatSize)
                let newEdgeInsets = UIEdgeInsets(top: cgTopFloat, left: cgLeftFloat, bottom: cgBottomFloat, right: cgRightFloat)
                self.viewModel.updateEdgeInsetsRow(at: indexPath, edgeInsets: newEdgeInsets)
                self.customView.tableView.beginUpdates()
                self.customView.tableView.reloadRows(at: [indexPath], with: .fade)
                self.customView.tableView.endUpdates()
            }
            // swiftlint:enable line_length
        }

        viewModel.showTextPopupTappedClosure = { [weak self] indexPath, text in
            guard let self = self else { return }
            self.showAlertWithTextField(message: Localizable.StyleManagerInitializationViewController.enterNewText.text, value: text) { newText in
                guard let newText = newText else { return }
                self.viewModel.updateStringRow(at: indexPath, text: newText)
                self.customView.tableView.beginUpdates()
                self.customView.tableView.reloadRows(at: [indexPath], with: .fade)
                self.customView.tableView.endUpdates()
            }
        }

        customView.nextButtonTappedClosure = { [weak self] in
            guard let self = self else { return }
            self.eventTriggered?(.didTapNextButton(self.viewModel.stylesManagerConfiguration))
        }
    }

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {
        customView.tableView.rowHeight = UITableView.automaticDimension
        customView.tableView.estimatedRowHeight = 44
        customView.tableView.allowsMultipleSelection = true
        customView.tableView.dataSource = viewModel
        customView.tableView.delegate = viewModel
        customView.tableView.accessibilityIdentifier = "styleManagerInitializationTableView"
    }

    // MARK: Helpers

    private func showAlertWithTextField(message: String, value: String, completionHandler: ((String?) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = value
            textField.keyboardType = .numbersAndPunctuation
        }

        alert.addAction(
            UIAlertAction(
                title: Localizable.Alerts.okButton.text,
                style: .default,
                handler: { [weak alert] _ in
                    let textField = alert?.textFields?[0]
                    completionHandler?(textField?.text)
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }

    private func showAlertWithDoubleTextField(message: String, firstPlaceholder: String?, secondPlaceholder: String?, firstValue: CGFloat, secondValue: CGFloat, completionHandler: ((String?, String?) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = "\(firstValue)"
            textField.keyboardType = .numbersAndPunctuation
            textField.placeholder = firstPlaceholder
        }

        alert.addTextField { textField in
            textField.text = "\(secondValue)"
            textField.keyboardType = .numbersAndPunctuation
            textField.placeholder = secondPlaceholder
        }

        alert.addAction(
            UIAlertAction(
                title: Localizable.Alerts.okButton.text,
                style: .default,
                handler: { [weak alert] _ in
                    let textField = alert?.textFields?[0]
                    let secondTextField = alert?.textFields?[1]
                    completionHandler?(textField?.text, secondTextField?.text)
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }

    private func showAlertWithFourFoldTextField(message: String, placeholders: [String]?, values: [CGFloat]?, completionHandler: ((String?, String?, String?, String?) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.keyboardType = .numbersAndPunctuation
            textField.text = "\(values?[safe: 0] ?? 0)"
            textField.placeholder = placeholders?[safe: 0] ?? .empty
        }

        alert.addTextField { textField in
            textField.keyboardType = .numbersAndPunctuation
            textField.text = "\(values?[safe: 1] ?? 0)"
            textField.placeholder = placeholders?[safe: 1] ?? .empty
        }

        alert.addTextField { textField in
            textField.keyboardType = .numbersAndPunctuation
            textField.text = "\(values?[safe: 2] ?? 0)"
            textField.placeholder = placeholders?[safe: 2] ?? .empty
        }

        alert.addTextField { textField in
            textField.keyboardType = .numbersAndPunctuation
            textField.text = "\(values?[safe: 3] ?? 0)"
            textField.placeholder = placeholders?[safe: 3] ?? .empty
        }

        for textField in alert.textFields! {
            let effectView = textField.superview?.superview?.subviews[safe: 0]
            effectView?.backgroundColor = .lightGray
            effectView?.layer.borderWidth = 1
            effectView?.layer.borderColor = UIColor.lightGray.cgColor
        }

        alert.addAction(
            UIAlertAction(
                title: Localizable.Alerts.okButton.text,
                style: .default,
                handler: { [weak alert] _ in
                    let textField = alert?.textFields?[0]
                    let secondTextField = alert?.textFields?[1]
                    let thirdTextField = alert?.textFields?[2]
                    let fourthTextField = alert?.textFields?[3]
                    completionHandler?(textField?.text, secondTextField?.text, thirdTextField?.text, fourthTextField?.text)
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }

    private func showFontPicker(_ indexPath: IndexPath, _ isCardinalFont: Bool) {
        viewModel.selectedFontIndexPath = indexPath
        viewModel.isCardinalFontSelected = isCardinalFont
        if #available(iOS 13.0, *) {
            let vc = UIFontPickerViewController()
            vc.delegate = self
            self.present(vc, animated: true)
        } else {
            let viewController = FontPickerViewController(view: FontPickerView(), viewModel: FontPickerViewModel())
            viewController.eventTriggered = { [weak self] event in
                switch event {
                case let .didFontSelect(fontName):
                    if isCardinalFont {
                        let cardinalFont = CardinalFont(name: fontName, size: 17)
                        self?.viewModel.updateCardinalFontRow(at: indexPath, font: cardinalFont)
                    } else {
                        guard let newFont = UIFont(name: fontName, size: 17) else { return }
                        self?.viewModel.updateFontRow(at: indexPath, font: newFont)
                    }
                    self?.customView.tableView.beginUpdates()
                    self?.customView.tableView.reloadRows(at: [indexPath], with: .fade)
                    self?.customView.tableView.endUpdates()
                }
            }

            let navigationController = UINavigationController(rootViewController: viewController)
            present(navigationController, animated: true) {}
        }
    }
}

extension StyleManagerInitializationViewController: UIFontPickerViewControllerDelegate {
    @available(iOS 13.0, *)
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let descriptor = viewController.selectedFontDescriptor else { return }

        if viewModel.isCardinalFontSelected {
            // swiftlint:disable force_cast
            let name = descriptor.object(forKey: .name) as! String
            // swiftlint:enable force_cast
            descriptor.object(forKey: .name)
            let font = CardinalFont(name: name, size: 17)
            viewModel.updateCardinalFontRow(at: viewModel.selectedFontIndexPath, font: font)
        } else {
            let font = UIFont(descriptor: descriptor, size: 17)
            viewModel.updateFontRow(at: viewModel.selectedFontIndexPath, font: font)
        }
        customView.tableView.beginUpdates()
        customView.tableView.reloadRows(at: [viewModel.selectedFontIndexPath], with: .fade)
        customView.tableView.endUpdates()
    }
}

private extension Localizable {
    enum StyleManagerInitializationViewController: String, Localized {
        case darkModeTitle
        case title
        case enterNewSize
        case enterNewSizeTopBottom
        case enterNewEdgeInsets
        case enterNewText
        case top
        case left
        case bottom
        case right
    }
}
