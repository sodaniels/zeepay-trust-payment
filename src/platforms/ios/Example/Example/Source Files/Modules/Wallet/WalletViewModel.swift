//
//  WalletViewModel.swift
//  Example
//

import Foundation

protocol WalletViewModelDataSource: AnyObject {
    func row(at index: IndexPath) -> WalletViewModel.Row
    func numberOfSections() -> Int
    func numberOfRows(at section: Int) -> Int
    func title(for section: Int) -> String?
    func section(at section: Int) -> WalletViewModel.Section
}

final class WalletViewModel {
    /// Keys for certain scheme
    private let keys = ApplicationKeys(keys: ExampleKeys())

    // Stores items on presented on list
    private var items: [Section] = []

    /// Stores temporary selected card reference
    private var selectedCard: TPCardReference?

    /// Returns merchant user name without exposing Keys object
    var getUsername: String {
        keys.merchantUsername
    }

    /// returns selected card type
    var getSelectedCardType: CardType? {
        guard let card = selectedCard else { return nil }
        return CardType.cardType(for: card.cardType)
    }

    init(items: [Section]) {
        self.items = items
    }

    /// Updates list items
    func addNewCard(_ card: TPCardReference?) {
        guard let newCard = card else { return }
        if let index = items.firstIndex(where: { $0.title == Section.paymentMethods(rows: []).title }) {
            var newRows = items[index].rows
            newRows.append(Row.cardReference(newCard))
            items[index] = Section.paymentMethods(rows: newRows)
            if let nextIndex = items.firstIndex(where: { $0.title == Section.addMethod(showHeader: false, rows: []).title }) {
                let nextRows = items[nextIndex].rows
                items[nextIndex] = Section.addMethod(showHeader: newRows.isEmpty ? false : true, rows: nextRows)
            }
        }
    }

    /// Updates list items
    func removeCard(_ card: TPCardReference) {
        if let index = items.firstIndex(where: { $0.title == Section.paymentMethods(rows: []).title }) {
            let newRows = items[index].rows.filter { $0.card?.transactionReference != card.transactionReference }
            items[index] = Section.paymentMethods(rows: newRows)
            if let nextIndex = items.firstIndex(where: { $0.title == Section.addMethod(showHeader: true, rows: []).title }) {
                let nextRows = items[nextIndex].rows
                items[nextIndex] = Section.addMethod(showHeader: newRows.isEmpty ? false : true, rows: nextRows)
            }
        }
    }

    /// Called to store a reference for currently selected card on Wallet list
    /// - Parameter card: TPCardReference object
    func cardSelected(_ card: TPCardReference) {
        selectedCard = card
    }

    /// Called to remove a card reference in Wallet list
    /// - Parameter card: TPCardReference object
    func cardRemoved(_ card: TPCardReference) {
        removeCard(card)
        Wallet.shared.remove(card: card)
    }

    /// Return JWT containing all data needed for request except card information
    /// - Returns: JWT as String
    /// - Parameters:
    ///   - storeCard: decides whether the card is to be saved in the TP system
    ///   - typeDescriptions: request types
    ///   - cardTypesToBypass: decides whether the 3DSecure check is to be omitted for a given card
    func getJwtTokenWithoutCardData(storeCard: Bool = false, typeDescriptions: [TypeDescription], cardTypesToBypass: [CardType]? = nil) -> String? {
        let typeDescriptions = typeDescriptions.map(\.rawValue)
        let cardTypesToBypass = cardTypesToBypass?.map(\.stringValue)
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1050,
                                              credentialsonfile: storeCard ? "1" : nil))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }

    /// Return JWT containing all data needed for THREEDQUERY, AUTH, RISKDEC request (with card reference)
    /// - Returns: JWT as String
    /// - Parameter cardTypesToBypass: decides whether the 3DSecure check is to be omitted for a given card
    func getJwtTokenWithSelectedCardReference(cardTypesToBypass: [CardType]? = nil) -> String? {
        let typeDescriptions = [TypeDescription.threeDQuery, .auth, .riskDec].map(\.rawValue)
        let cardTypesToBypass = cardTypesToBypass?.map(\.stringValue)
        guard let card = selectedCard else { return nil }
        let claim = TPClaims(iss: keys.merchantUsername,
                             iat: Date(timeIntervalSinceNow: 0),
                             payload: Payload(requesttypedescriptions: typeDescriptions,
                                              threedbypasspaymenttypes: cardTypesToBypass,
                                              accounttypedescription: "ECOM",
                                              sitereference: keys.merchantSiteReference,
                                              currencyiso3a: "GBP",
                                              baseamount: 1100,
                                              parenttransactionreference: card.transactionReference,
                                              credentialsonfile: "2"))

        guard let jwt = JWTHelper.createJWT(basedOn: claim, signWith: keys.jwtSecretKey) else { return nil }
        return jwt
    }
}

extension WalletViewModel: WalletViewModelDataSource {
    func row(at index: IndexPath) -> Row {
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

    func section(at section: Int) -> Section {
        items[section]
    }
}

extension WalletViewModel {
    enum Row {
        case cardReference(TPCardReference)
        case addCard(title: String)

        var card: TPCardReference? {
            switch self {
            case let .cardReference(cardRef): return cardRef
            case .addCard: return nil
            }
        }
    }

    enum Section {
        case paymentMethods(rows: [Row])
        case addMethod(showHeader: Bool, rows: [Row])

        var rows: [Row] {
            switch self {
            case let .paymentMethods(rows): return rows
            case let .addMethod(_, rows): return rows
            }
        }

        var title: String? {
            switch self {
            case .paymentMethods: return Localizable.WalletViewModel.paymentMethods.text
            case let .addMethod(showHeader, _): return showHeader ? Localizable.WalletViewModel.infoText.text : nil
            }
        }
    }
}

private extension Localizable {
    enum WalletViewModel: String, Localized {
        case paymentMethods
        case infoText
    }
}
