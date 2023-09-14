//
//  SelectCardTypesViewModel.swift
//  Example
//

import Foundation
import UIKit

final class CardTypeItem {
    var cardType: CardType

    var isSelected = false

    var title: String {
        cardType.debugDescription
    }

    init(cardType: CardType) {
        self.cardType = cardType
    }
}

final class SelectCardTypesViewModel: NSObject {
    var cardTypes = [CardTypeItem]()

    var nextButtonShouldBeEnabled = true

    var didToggleSelection: ((_ nextButtonShouldBeEnabled: Bool) -> Void)? {
        didSet {
            didToggleSelection?(!selectedCardTypes.isEmpty || nextButtonShouldBeEnabled)
        }
    }

    var selectedCardTypes: [CardTypeItem] {
        cardTypes.filter(\.isSelected)
    }

    init(nextButtonShouldBeEnabled: Bool) {
        super.init()
        self.nextButtonShouldBeEnabled = nextButtonShouldBeEnabled
        cardTypes = CardType.allCases.filter { $0 != .unknown }.map { CardTypeItem(cardType: $0) }
    }
}

extension SelectCardTypesViewModel: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        cardTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(dequeueableCell: CardTypeCell.self)
        let cardTypeItem = cardTypes[indexPath.row]
        cell.setupCell(cardTypeItem: cardTypeItem)
        cell.accessibilityIdentifier = "\(cardTypeItem.cardType)Cell"

        // select/deselect the cell
        if cardTypeItem.isSelected {
            if !cell.isSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            if cell.isSelected {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }

        return cell
    }
}

extension SelectCardTypesViewModel: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        cardTypes[indexPath.row].isSelected = true
        didToggleSelection?(!selectedCardTypes.isEmpty || nextButtonShouldBeEnabled)
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        cardTypes[indexPath.row].isSelected = false
        didToggleSelection?(!selectedCardTypes.isEmpty || nextButtonShouldBeEnabled)
    }
}
