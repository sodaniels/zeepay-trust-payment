//
//  CardType.swift
//  TrustPaymentsCard
//

import Foundation
import UIKit

/// Supported card types.
///
/// Has basic logic for BIN ranges, cvv lengths, default masks and logos.
@objc public enum CardType: Int, CaseIterable {
    case visa
    case mastercard
    case amex
    case maestro
    case discover
    case diners
    case jcb
    case unknown

    // MARK: Public properties

    /// Get number of groups used for masking card number
    /// - Parameter cardNumber: Optional card number (can contains separator), used to adjust mask for Diners Club card number longer than 14 digits
    /// - Returns: Returns number of groups used for masking card number
    public func numberGrouping(cardNumber: String = "") -> [Int] {
        let stringArray = inputMask(cardNumber: cardNumber).components(separatedBy: String.space)
        return stringArray.map(\.count)
    }

    public var logo: UIImage? {
        switch self {
        case .visa: return image(for: "visa")
        case .mastercard: return image(for: "mastercard")
        case .amex: return image(for: "amex")
        case .maestro: return image(for: "maestro")
        case .discover: return image(for: "discover")
        case .diners: return image(for: "diners")
        case .jcb: return image(for: "jcb")
        case .unknown: return image(for: "unknown")
        }
    }

    public var stringValue: String {
        switch self {
        case .visa: return "VISA"
        case .mastercard: return "MASTERCARD"
        case .amex: return "AMEX"
        case .maestro: return "MAESTRO"
        case .discover: return "DISCOVER"
        case .diners: return "DINERS"
        case .jcb: return "JCB"
        case .unknown: return "unknown"
        }
    }

    public var cvvLength: Int {
        switch self {
        case .amex: return 4
        default: return 3
        }
    }

    // MARK: Internal properties

    var iin: [ClosedRange<Int>] {
        // https://www.barclaycard.co.uk/business/files/BIN-Rules-UK.pdf
        switch self {
        case .visa: return [400_000 ... 499_999]
        case .mastercard: return [510_000 ... 559_999,
                                  222_100 ... 272_099]
        case .amex: return [340_000 ... 349_999,
                            370_000 ... 379_999]
        case .maestro: return [500_000 ... 509_999,
                               560_000 ... 699_999].except(ranges: CardType.discover.iin)
        case .discover: return [601_100 ... 601_199,
                                622_126 ... 622_925,
                                624_000 ... 626_999,
                                628_200 ... 628_899,
                                640_000 ... 659_999]
        case .diners: return [300_000 ... 305_999,
                              309_500 ... 309_599,
                              380_000 ... 399_999,
                              360_000 ... 369_999]
        case .jcb: return [352_800 ... 358_999]
        case .unknown: return [0 ... 1]
        }
    }

    var validNumberLengths: Set<Int> {
        switch self {
        case .visa: return [13, 16, 19]
        case .mastercard: return [16]
        case .amex: return [15]
        case .maestro: return [12, 13, 14, 15, 16, 17, 18, 19]
        case .discover: return [14, 15, 16, 17, 18, 19]
        case .diners: return [14, 15, 16, 17, 18, 19]
        case .jcb: return [15, 16, 19]
        case .unknown: return [16]
        }
    }

    /// Input mask for current card type and given card number
    /// - Parameter cardNumber: Optional card number (can contains separator), used to adjust mask for Diners Club card number longer than 14 digits
    /// - Returns: Mask as a string eg: #### #### #### ####
    func inputMask(cardNumber: String) -> String {
        switch self {
        // 4-6-5
        case .amex: return "#### ###### #####"
        // 4-6-4 or 4-4-4-4 if longer than 14 digits
        case .diners:
            return cardNumber.onlyDigits.count > 14 ? "#### #### #### ####" : "#### ###### ####"
        // 4-4-4-4
        default: return "#### #### #### ####"
        }
    }

    public static func cardType(for cardDescription: String) -> CardType {
        switch cardDescription.lowercased() {
        case "visa": return .visa
        case "mastercard": return .mastercard
        case "amex": return .amex
        case "maestro": return .maestro
        case "discover": return .discover
        case "diners": return .diners
        case "jcb": return .jcb
        default: return .unknown
        }
    }

    // MARK: Private properties

    private func image(for name: String) -> UIImage? {
        let imageName = name + "_logo"
        return UIImage(named: imageName, in: Bundle(for: CardValidator.self), compatibleWith: nil)
    }
}

extension CardType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "MasterCard"
        case .amex: return "American Express"
        case .maestro: return "Maestro"
        case .discover: return "Discover"
        case .diners: return "Diners Club"
        case .jcb: return "JCB"
        case .unknown: return "Unknown card"
        }
    }
}
