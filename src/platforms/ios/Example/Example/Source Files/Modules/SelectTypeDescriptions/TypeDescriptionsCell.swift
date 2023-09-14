//
//  TypeDescriptionsCell.swift
//  Example
//

final class TypeDescriptionsCell: BaseViewCell {
    func setupCell(typeDescriptionsItem: TypeDescriptionsItem) {
        textLabel?.text = typeDescriptionsItem.title
        textLabel?.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}

extension TypeDescriptionsCell: ViewSetupable {
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
