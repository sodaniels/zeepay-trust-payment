import Foundation

struct TestCards3DSecureV1 {
    static let masterCardNumber = "5200000000000007"
    static let discoverCardNumber = "6011000000000004"
    static let unauthenticatedErrorVisaCardNumber = "4000000000000028"
    static let passiveAuthencticationAmexCardNumber = "340000000003391"
    static let passiveAuthenticationJCBCardNumber = "3528000000000411"
    static let bankSystemErrorDiscoverCardNumber = "6011000000000079"
}

enum TestCards3DSecureV2 {
    static let frictionlessVisaCardNumber = "4000000000001026"
    static let frictionlessMasterCardNumber = "5200000000001005"
    static let frictionlessAmexCardNumber = "340000000000611"
    static let nonFrictionlessVisaCardNumber = "4000000000001091"
    static let nonFrictionlessMasterCardNumber = "5200000000001096"
    static let nonFrictionlessMaestroCardNumber = "5000000000000611"
    static let bankSystemErrorVisaCardNumber = "4000000000001067"
    static let unauthenticatedErrorVisaCardNumber = "4000000000001018"
    static let frictionlessDiscoverCardNumber = "6011000000000301"
}

enum SharedTestCardData {
    static let incorrectCardNumber = "41111111"
    static let expiryDateMonth = "12"
    static let expiryDateYear = "2024"
    static let incorrectExpiryDateMonth = "11"
    static let incorrectExpiryDateYear = "2019"
    static let amexCvvNumber = "1234"
    static let incorrectCvvNumber = "12"
    static let incorrectAmexCvvNumber = "123"
    static let cvvNumber = "123"
    static let threeDSecureCode = "1234"
    static let amexReference = "AMEX"
    static let masterCardReference = "MASTERCARD"
    static let visaReference = "VISA"
    static let bypassMasterCard = "MasterCard"
    static let bypassVisa = "Visa"
    static let bypassDiscover = "Discover"
    static let discoverReference = "DISCOVER"
}

enum TestAmounts {
    static let defaultBaseAmountValue = "1050"
    static let mainAmountExampleValue = "10.99"
    static let invalidBaseAmountValue = "0"
    static let triggerAuthErrorBaseAmountValue = "14492"
}
