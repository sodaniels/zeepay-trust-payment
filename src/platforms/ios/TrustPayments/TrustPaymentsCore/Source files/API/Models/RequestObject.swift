//
//  RequestObject.swift
//  TrustPaymentsCore
//

import Foundation

/// Use to specify wallet source when performing wallet transaction.
///
/// Currently supports only Apple Pay.
@objc public enum WalletSource: Int {
    case applePay
    // case visaCheckout
    
    // Code for internal use, needed for RequestObject
    var code: String {
        switch self {
        case .applePay: return "APPLEPAY"
        }
    }
}

/// Use to specify APM type when performing APM transaction.
///
/// Currently supports only ZIP and ATA
@objc public enum APM: Int {
    case zip, ata

    // Code for internal use, needed for RequestObject
    var code: String {
        switch self {
        case .zip: return "ZIP"
        case .ata: return "ATA"
        }
    }
}

// objc workaround - when you add a new value to TypeDescription, you have to add it here too
/// Request type description.
///
/// Refer to Trust Payments official documentation for explanation of each type and when you can use it.
@objc public enum TypeDescriptionObjc: Int {
    case auth = 0
    case threeDQuery
    case accountCheck
    case jsInit
    case subscription
    case riskDec
    case cacheTokenise
    
    public var value: String {
        switch self {
        case .auth: return TypeDescription.auth.rawValue
        case .threeDQuery: return TypeDescription.threeDQuery.rawValue
        case .accountCheck: return TypeDescription.accountCheck.rawValue
        case .jsInit: return TypeDescription.jsInit.rawValue
        case .subscription: return TypeDescription.subscription.rawValue
        case .riskDec: return TypeDescription.riskDec.rawValue
        case .cacheTokenise: return TypeDescription.cacheTokenise.rawValue
        }
    }
}

/// Request type description.
///
/// Refer to Trust Payments official documentation for explanation of each type and when you can use it.
public enum TypeDescription: String, Codable {
    case auth = "AUTH"
    case threeDQuery = "THREEDQUERY"
    case accountCheck = "ACCOUNTCHECK"
    case jsInit = "JSINIT"
    case subscription = "SUBSCRIPTION"
    case riskDec = "RISKDEC"
    case cacheTokenise = "CACHETOKENISE"
    
    var code: Int {
        switch self {
        case .auth: return TypeDescriptionObjc.auth.rawValue
        case .threeDQuery: return TypeDescriptionObjc.threeDQuery.rawValue
        case .accountCheck: return TypeDescriptionObjc.accountCheck.rawValue
        case .jsInit: return TypeDescriptionObjc.jsInit.rawValue
        case .subscription: return TypeDescriptionObjc.subscription.rawValue
        case .riskDec: return TypeDescriptionObjc.riskDec.rawValue
        case .cacheTokenise: return TypeDescriptionObjc.cacheTokenise.rawValue
        }
    }
}

class RequestObject: NSObject, Codable {
    // MARK: Properties
    
    let isJSInitRequest: Bool = false
    private let typeDescriptions: [TypeDescription]?
    let requestId: String?
    let cardNumber: String?
    let cvv: String?
    let expiryDate: String?
    let threeDResponse: String?
    let cacheToken: String?
    let pares: String?
    
    // Fraud control
    let fraudControlTransactionId: String?
    
    // Wallet
    let walletSource: String?
    let walletToken: String?
    
    // APM
    let returnUrl: String?
    let apmCode: String?
    
    // MARK: Initialization
    
    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - isJSInitRequest: determines whether the JSINIT request should be executed
    ///   - requestId: request id (to tie up the requests)
    ///   - cardNumber: The long number printed on the front of the customer’s card.
    ///   - cvv: The three digit security code printed on the back of the card. (For AMEX cards, this is a 4 digit code found on the front of the card), This field is not strictly required.
    ///   - expiryDate: The expiry date printed on the card.
    ///   - threeDResponse: JWT token for validation
    ///   - cacheToken: cache token (to tie up the requests)
    ///   - walletSource: WalletSource (ApplePay)
    ///   - walletToken: ApplePay - string representation of PKPayment
    ///   - pares: PaRes value for 3D secure v1
    ///   - returnUrl: Return url that will be triggered by APM's webview
    ///   - apmCode: APM code, See APM enum
    ///   - fraudControlTransactionId: Fraud control transaction ID
    
    init(isJSInitRequest: Bool = false, requestId: String? = nil, cardNumber: String? = nil, cvv: String? = nil, expiryDate: String? = nil, threeDResponse: String? = nil, cacheToken: String? = nil, walletSource: String? = nil, walletToken: String? = nil, pares: String? = nil, returnUrl: String? = nil, apmCode: String? = nil, fraudControlTransactionId: String? = nil) {
        typeDescriptions = isJSInitRequest ? [.jsInit] : nil
        self.requestId = requestId
        self.cardNumber = cardNumber
        self.cvv = cvv
        self.expiryDate = expiryDate
        self.threeDResponse = threeDResponse
        self.cacheToken = cacheToken
        self.walletSource = walletSource
        self.walletToken = walletToken
        self.pares = pares
        self.returnUrl = returnUrl
        self.apmCode = apmCode
        self.fraudControlTransactionId = fraudControlTransactionId
    }
}

private extension RequestObject {
    enum CodingKeys: String, CodingKey {
        case typeDescriptions = "requesttypedescriptions"
        case requestId = "requestid"
        case cardNumber = "pan"
        case cvv = "securitycode"
        case expiryDate = "expirydate"
        case threeDResponse = "threedresponse"
        case cacheToken = "cachetoken"
        case walletSource = "walletsource"
        case walletToken = "wallettoken"
        case pares
        case returnUrl = "returnurl"
        case apmCode = "paymenttypedescription"
        case fraudControlTransactionId = "fraudcontroltransactionid"
    }
}
