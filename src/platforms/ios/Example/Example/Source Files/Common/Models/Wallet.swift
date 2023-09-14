//
//  Wallet.swift
//  Example
//

import Foundation

/// An example implementation of Wallet functionality as a Singleton
/// Only for demo purposes
/// Real application should store those data in a local database or on its own backend and request when needed
class Wallet {
    private var cards: [TPCardReference] = []
    static let shared = Wallet()
    private let defaultsKey = "savedCards"

    /// Returns all added card references
    var allCards: [TPCardReference] {
        guard let items = UserDefaults.standard.value(forKey: defaultsKey) as? Data else { return cards }
        let decoder = JSONDecoder()
        guard let cardItems = try? decoder.decode(Array.self, from: items) as [TPCardReference] else { return cards }
        cards = cardItems
        return cards
    }

    /// Removes all card references
    func removeAll() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        UserDefaults.standard.synchronize()
        cards.removeAll()
    }

    /// Adds a card reference to wallet
    /// takes optional value and if has wrapped part, adds it to the collection
    func add(card: TPCardReference?) {
        guard let card = card, !cards.contains(where: { $0.transactionReference == card.transactionReference }) else { return }
        cards.append(card)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(cards) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    /// Removes a card reference from wallet
    func remove(card: TPCardReference) {
        guard cards.contains(where: { $0.transactionReference == card.transactionReference }) else { return }
        cards = cards.filter { $0.transactionReference != card.transactionReference }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(cards) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }
}
