//
//  FontPickerViewModel.swift
//  Example
//

import UIKit

final class FontPickerViewModel: NSObject {
    let fontNames = ["Chalkduster", "Noteworthy-Bold", "Papyrus", "Superclarendon-Italic", "TimesNewRomanPSMT"]
    var didFontSelect: ((_ fontName: String) -> Void)?
}

extension FontPickerViewModel: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        fontNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(dequeueableCell: FontCell.self)
        let fontName = fontNames[indexPath.row]
        cell.setupCell(fontName: fontName)
        return cell
    }
}

extension FontPickerViewModel: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        didFontSelect?(fontNames[indexPath.row])
    }
}
