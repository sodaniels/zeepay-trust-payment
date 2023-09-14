//
//  StyleManagerInitializationViewModel.swift
//  Example
//

import UIKit

struct StylesManagerConfiguration {
    let inputViewStyleManager: InputViewStyleManager
    let dropInViewStyleManager: DropInViewStyleManager
    let payButtonStyleManager: PayButtonStyleManager

    let toolbarStyleManager: CardinalToolbarStyleManager
    let labelStyleManager: CardinalLabelStyleManager
    let verifyButtonStyleManager: CardinalButtonStyleManager
    let continueButtonStyleManager: CardinalButtonStyleManager
    let resendButtonStyleManager: CardinalButtonStyleManager
    let textBoxStyleManager: CardinalTextBoxStyleManager
}

protocol StyleManagerInitializationViewModelDataSource: AnyObject {
    func row(at index: IndexPath) -> StyleManagerInitializationViewModel.Row?
    func numberOfSections() -> Int
    func numberOfRows(at section: Int) -> Int
    func title(for section: Int) -> String?
}

final class StyleManagerInitializationViewModel: NSObject {
    fileprivate var items: [Section]

    let isDarkModeConfiguration: Bool
    let stylesManagerConfiguration: StylesManagerConfiguration

    var selectedFontIndexPath: IndexPath!
    var isCardinalFontSelected: Bool = false

    var showColorPickerTappedClosure: ((IndexPath, UIColor) -> Void)?
    var showFontPickerTappedClosure: ((IndexPath, UIFont) -> Void)?
    var showSingleSizePopupTappedClosure: ((IndexPath, CGFloat) -> Void)?
    var showHeightMarginsPopupTappedClosure: ((IndexPath, HeightMargins) -> Void)?
    var showEdgeInsetsPopupTappedClosure: ((IndexPath, UIEdgeInsets) -> Void)?
    var showTextPopupTappedClosure: ((IndexPath, String) -> Void)?
    var showCardinalFontPickerTappedClosure: ((IndexPath, CardinalFont) -> Void)?

    init(items: [Section], isDarkModeConfiguration: Bool, stylesManagerConfiguration: StylesManagerConfiguration) {
        self.items = items
        self.isDarkModeConfiguration = isDarkModeConfiguration
        self.stylesManagerConfiguration = stylesManagerConfiguration
        super.init()
    }

    func updateColorRow(at index: IndexPath, color: UIColor) {
        guard let colorRow = row(at: index) as? UIColorRow else { return }
        colorRow.color = color
        updateStyleManager(at: index, key: colorRow.title, value: color)
    }

    func updateFontRow(at index: IndexPath, font: UIFont) {
        guard let fontRow = row(at: index) as? UIFontRow else { return }
        fontRow.font = font
        updateStyleManager(at: index, key: fontRow.title, value: font)
    }

    func updateFloatRow(at index: IndexPath, size: CGFloat) {
        guard let floatRow = row(at: index) as? CGFloatRow else { return }
        floatRow.size = size
        updateStyleManager(at: index, key: floatRow.title, value: size)
    }

    func updateHeightMarginsRow(at index: IndexPath, size: HeightMargins) {
        guard let heightMarginsRow = row(at: index) as? HeightMarginsRow else { return }
        heightMarginsRow.size = size
        updateStyleManager(at: index, key: heightMarginsRow.title, value: size)
    }

    func updateEdgeInsetsRow(at index: IndexPath, edgeInsets: UIEdgeInsets) {
        guard let edgeInsetsRow = row(at: index) as? UIEdgeInsetsRow else { return }
        edgeInsetsRow.edgeInsets = edgeInsets
        updateStyleManager(at: index, key: edgeInsetsRow.title, value: edgeInsets)
    }

    func updateStringRow(at index: IndexPath, text: String) {
        guard let stringRow = row(at: index) as? StringRow else { return }
        stringRow.text = text
        updateStyleManager(at: index, key: stringRow.title, value: text)
    }

    func updateCardinalFontRow(at index: IndexPath, font: CardinalFont) {
        guard let fontRow = row(at: index) as? CardinalFontRow else { return }
        fontRow.font = font
        updateStyleManager(at: index, key: fontRow.title, value: font)
    }

    private func updateStyleManager(at index: IndexPath, key: String, value: Any) {
        switch title(for: index.section) {
        case Localizable.StyleManagerInitializationViewModel.dropInStyleManager.text:
            stylesManagerConfiguration.dropInViewStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.inputViewStyleManager.text:
            stylesManagerConfiguration.inputViewStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.payButtonStyleManager.text:
            stylesManagerConfiguration.payButtonStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.toolbarStyleManager.text:
            stylesManagerConfiguration.toolbarStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.labelStyleManager.text:
            stylesManagerConfiguration.labelStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.verifyButtonStyleManager.text:
            stylesManagerConfiguration.verifyButtonStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.continueButtonStyleManager.text:
            stylesManagerConfiguration.continueButtonStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.resendButtonStyleManager.text:
            stylesManagerConfiguration.resendButtonStyleManager.setValue(value, forKey: key)
        case Localizable.StyleManagerInitializationViewModel.textBoxStyleManager.text:
            stylesManagerConfiguration.textBoxStyleManager.setValue(value, forKey: key)
        default: return
        }
    }
}

extension StyleManagerInitializationViewModel: StyleManagerInitializationViewModelDataSource {
    func row(at index: IndexPath) -> Row? {
        items[index.section].rows[index.row]
    }

    func numberOfSections() -> Int {
        items.count
    }

    func numberOfRows(at section: Int) -> Int {
        items[section].rows.count
    }

    func title(for section: Int) -> String? {
        items[section].title
    }
}

extension StyleManagerInitializationViewModel {
    class Row {
        let title: String
        init(title: String) {
            self.title = title
        }
    }

    class UIColorRow: Row {
        var color: UIColor
        init(title: String, color: UIColor) {
            self.color = color
            super.init(title: title)
        }
    }

    class UIFontRow: Row {
        var font: UIFont
        init(title: String, font: UIFont) {
            self.font = font
            super.init(title: title)
        }
    }

    class CGFloatRow: Row {
        var size: CGFloat
        init(title: String, size: CGFloat) {
            self.size = size
            super.init(title: title)
        }
    }

    class HeightMarginsRow: Row {
        var size: HeightMargins
        init(title: String, size: HeightMargins) {
            self.size = size
            super.init(title: title)
        }
    }

    class UIEdgeInsetsRow: Row {
        var edgeInsets: UIEdgeInsets
        init(title: String, edgeInsets: UIEdgeInsets) {
            self.edgeInsets = edgeInsets
            super.init(title: title)
        }
    }

    class StringRow: Row {
        var text: String
        init(title: String, text: String) {
            self.text = text
            super.init(title: title)
        }
    }

    class CardinalFontRow: Row {
        var font: CardinalFont
        init(title: String, font: CardinalFont) {
            self.font = font
            super.init(title: title)
        }
    }

    enum Section {
        case dropInStyleManager(rows: [Row])
        case inputViewStyleManager(rows: [Row])
        case payButtonStyleManager(rows: [Row])

        case toolbarStyleManager(rows: [Row])
        case labelStyleManager(rows: [Row])
        case verifyButtonStyleManager(rows: [Row])
        case continueButtonStyleManager(rows: [Row])
        case resendButtonStyleManager(rows: [Row])
        case textBoxStyleManager(rows: [Row])

        var rows: [Row] {
            switch self {
            case let .dropInStyleManager(rows): return rows
            case let .inputViewStyleManager(rows): return rows
            case let .payButtonStyleManager(rows): return rows
            case let .toolbarStyleManager(rows): return rows
            case let .labelStyleManager(rows): return rows
            case let .verifyButtonStyleManager(rows): return rows
            case let .continueButtonStyleManager(rows): return rows
            case let .resendButtonStyleManager(rows): return rows
            case let .textBoxStyleManager(rows): return rows
            }
        }

        var title: String? {
            switch self {
            case .dropInStyleManager: return Localizable.StyleManagerInitializationViewModel.dropInStyleManager.text
            case .payButtonStyleManager: return Localizable.StyleManagerInitializationViewModel.payButtonStyleManager.text
            case .inputViewStyleManager: return
                Localizable.StyleManagerInitializationViewModel.inputViewStyleManager.text
            case .toolbarStyleManager: return Localizable.StyleManagerInitializationViewModel.toolbarStyleManager.text
            case .labelStyleManager: return Localizable.StyleManagerInitializationViewModel.labelStyleManager.text
            case .verifyButtonStyleManager: return Localizable.StyleManagerInitializationViewModel.verifyButtonStyleManager.text
            case .continueButtonStyleManager: return Localizable.StyleManagerInitializationViewModel.continueButtonStyleManager.text
            case .resendButtonStyleManager: return Localizable.StyleManagerInitializationViewModel.resendButtonStyleManager.text
            case .textBoxStyleManager: return Localizable.StyleManagerInitializationViewModel.textBoxStyleManager.text
            }
        }
    }
}

extension StyleManagerInitializationViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let colorRow = row(at: indexPath) as? UIColorRow {
            let cell = tableView.dequeue(dequeueableCell: PickColorCell.self)
            cell.setupCell(row: colorRow)
            return cell
        }

        if let fontRow = row(at: indexPath) as? UIFontRow {
            let cell = tableView.dequeue(dequeueableCell: PickFontCell.self)
            cell.setupCell(row: fontRow)
            return cell
        }

        if let floatRow = row(at: indexPath) as? CGFloatRow {
            let cell = tableView.dequeue(dequeueableCell: SingleSizeCell.self)
            cell.setupCell(row: floatRow)
            return cell
        }

        if let heightMarginsRow = row(at: indexPath) as? HeightMarginsRow {
            let cell = tableView.dequeue(dequeueableCell: HeightMarginsCell.self)
            cell.setupCell(row: heightMarginsRow)
            return cell
        }

        if let edgeInsetsRow = row(at: indexPath) as? UIEdgeInsetsRow {
            let cell = tableView.dequeue(dequeueableCell: EdgeInsetsCell.self)
            cell.setupCell(row: edgeInsetsRow)
            return cell
        }

        if let stringRow = row(at: indexPath) as? StringRow {
            let cell = tableView.dequeue(dequeueableCell: StringCell.self)
            cell.setupCell(row: stringRow)
            return cell
        }

        if let fontRow = row(at: indexPath) as? CardinalFontRow {
            let cell = tableView.dequeue(dequeueableCell: PickCardinalFontCell.self)
            cell.setupCell(row: fontRow)
            return cell
        }

        return UITableViewCell()
    }

    func numberOfSections(in _: UITableView) -> Int {
        numberOfSections()
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows(at: section)
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = title(for: section) {
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
}

extension StyleManagerInitializationViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let colorRow = row(at: indexPath) as? UIColorRow {
            showColorPickerTappedClosure?(indexPath, colorRow.color)
        }
        if let fontRow = row(at: indexPath) as? UIFontRow {
            showFontPickerTappedClosure?(indexPath, fontRow.font)
        }
        if let floatRow = row(at: indexPath) as? CGFloatRow {
            showSingleSizePopupTappedClosure?(indexPath, floatRow.size)
        }
        if let heightMarginsRow = row(at: indexPath) as? HeightMarginsRow {
            showHeightMarginsPopupTappedClosure?(indexPath, heightMarginsRow.size)
        }
        if let edgeInsetsRow = row(at: indexPath) as? UIEdgeInsetsRow {
            showEdgeInsetsPopupTappedClosure?(indexPath, edgeInsetsRow.edgeInsets)
        }
        if let stringRow = row(at: indexPath) as? StringRow {
            showTextPopupTappedClosure?(indexPath, stringRow.text)
        }
        if let fontRow = row(at: indexPath) as? CardinalFontRow {
            showCardinalFontPickerTappedClosure?(indexPath, fontRow.font)
        }
    }
}

// MARK: Localizable

private extension Localizable {
    enum StyleManagerInitializationViewModel: String, Localized {
        case dropInStyleManager
        case payButtonStyleManager
        case inputViewStyleManager
        case toolbarStyleManager
        case labelStyleManager
        case verifyButtonStyleManager
        case continueButtonStyleManager
        case resendButtonStyleManager
        case textBoxStyleManager
    }
}
