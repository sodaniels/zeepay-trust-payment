//
//  PKPayment.swift
//  Example
//

import PassKit

extension PKPayment {
    var stringRepresentation: String? {
        let paymentData = token.paymentData
        guard let paymentDataJson = try? JSONSerialization.jsonObject(with: paymentData,
                                                                      options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] else { return nil }
        let expectedJson: [String: Any] = [
            "token":
                [
                    "transactionIdentifier": token.transactionIdentifier,
                    "paymentData": paymentDataJson,
                    "paymentMethod":
                        [
                            "network": token.paymentMethod.network?.rawValue,
                            "type": token.paymentMethod.type.description,
                            "displayName": token.paymentMethod.displayName
                        ]
                ]
        ]
        guard let expectedJsonData = try? JSONSerialization.data(withJSONObject: expectedJson,
                                                                 options: JSONSerialization.WritingOptions(rawValue: 0)) else { return nil }
        return String(data: expectedJsonData, encoding: .utf8)
    }
}
