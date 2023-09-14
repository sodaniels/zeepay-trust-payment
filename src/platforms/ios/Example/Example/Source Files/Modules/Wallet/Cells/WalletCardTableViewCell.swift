//
//  WalletCardTableViewCell.swift
//  Example
//

import UIKit

/// Table cell used for representing a card on Wallet list with type of Subtitle
final class WalletCardTableViewCell: UITableViewCell {
    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the cell with parameters of TPCardReference
    /// - Parameter cardReference: card reference object
    func configure(cardReference: TPCardReference) {
        imageView?.image = CardType.cardType(for: cardReference.cardType).logo
        textLabel?.text = cardReference.cardType
        detailTextLabel?.text = cardReference.maskedPan
        highlightIfNeeded()
    }
}
