//
//  FontCell.swift
//  Example
//

final class FontCell: BaseViewCell {
    func setupCell(fontName: String) {
        textLabel?.text = fontName
    }
}

extension FontCell: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        backgroundColor = .clear
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {}

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {}
}
