//
//  CardTypeCell.swift
//  Example
//

final class CardTypeCell: BaseViewCell {
    func setupCell(cardTypeItem: CardTypeItem) {
        imageView?.image = cardTypeItem.cardType.logo
        textLabel?.text = cardTypeItem.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}

extension CardTypeCell: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        backgroundColor = .clear
        selectionStyle = .none
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {}

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {}
}
