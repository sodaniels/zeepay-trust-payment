//
//  Data.swift
//  TrustPaymentsCore
//

import Foundation

extension Optional where Wrapped == Data {
    func jwt() -> DecodedMerchantJWT? {
        guard let data = self, let serializedRequest = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 1)) as? [String: AnyObject], let jwt = serializedRequest["jwt"] as? String else {
            return nil
        }
        return try? DecodedMerchantJWT(jwt: jwt)
    }
}
