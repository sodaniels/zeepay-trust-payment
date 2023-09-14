//
//  SelectTypeDescriptionsViewModel.swift
//  Example
//

import UIKit

final class TypeDescriptionsItem {
    var typeDescriptions: [TypeDescription]

    var isSelected = false

    var title: String {
        typeDescriptions.map(\.rawValue).joined(separator: ", ")
    }

    init(typeDescriptions: [TypeDescription]) {
        self.typeDescriptions = typeDescriptions
    }
}

final class SelectTypeDescriptionsViewModel: NSObject {
    var typeDescriptions = [TypeDescriptionsItem]()

    var didToggleSelection: ((_ nextButtonShouldBeEnabled: Bool) -> Void)? {
        didSet {
            didToggleSelection?(!selectedTypeDescriptions.isEmpty)
        }
    }

    var selectedTypeDescriptions: [TypeDescriptionsItem] {
        typeDescriptions.filter(\.isSelected)
    }

    init(excluding combinations: Set<[TypeDescription]>) {
        super.init()
        let availableTypeDescriptionCombinations: [[TypeDescription]] = [
            [.auth],
            [.accountCheck],
            [.accountCheck, .auth],
            [.riskDec, .auth],
            [.auth, .riskDec],
            [.riskDec, .auth, .subscription],
            [.riskDec, .accountCheck, .auth],
            [.accountCheck, .subscription],
            [.auth, .subscription],
            [.riskDec, .accountCheck, .auth, .subscription],
            [.threeDQuery],
            [.threeDQuery, .auth]
        ]
        var filteredTypeDescriptions: [[TypeDescription]] = []
        for availableTypeDescriptions in availableTypeDescriptionCombinations {
            if !combinations.contains(availableTypeDescriptions) {
                filteredTypeDescriptions.append(availableTypeDescriptions)
            }
        }
        typeDescriptions = filteredTypeDescriptions.map { TypeDescriptionsItem(typeDescriptions: $0) }
    }
}

extension SelectTypeDescriptionsViewModel: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        typeDescriptions.count
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = UIView()
            header.backgroundColor = UIColor.groupTableViewBackground
            let label = UILabel()
            label.text = Localizable.SelectTypeDescriptionsViewModel.typeDescriptionsHeaderText.text
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 13)
            header.addSubview(label)
            label.addConstraints([
                equal(header, \.topAnchor, \.topAnchor, constant: 5),
                equal(header, \.bottomAnchor, \.bottomAnchor, constant: -5),
                equal(header, \.leadingAnchor, \.leadingAnchor, constant: 20),
                equal(header, \.trailingAnchor, \.trailingAnchor, constant: -20)
            ])
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(dequeueableCell: TypeDescriptionsCell.self)
        let typeDescriptionsItem = typeDescriptions[indexPath.row]
        cell.setupCell(typeDescriptionsItem: typeDescriptionsItem)

        // select/deselect the cell
        if typeDescriptionsItem.isSelected {
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

extension SelectTypeDescriptionsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (index, typeDescription) in typeDescriptions.enumerated() where typeDescription.isSelected {
            typeDescription.isSelected = false
            tableView.reloadRows(at: [IndexPath(row: index, section: indexPath.section)], with: .none)
        }
        typeDescriptions[indexPath.row].isSelected = true
        didToggleSelection?(!selectedTypeDescriptions.isEmpty)
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        typeDescriptions[indexPath.row].isSelected = false
        didToggleSelection?(!selectedTypeDescriptions.isEmpty)
    }
}

// MARK: Localizable

private extension Localizable {
    enum SelectTypeDescriptionsViewModel: String, Localized {
        case typeDescriptionsHeaderText
    }
}
