//
//  PaymentTransactionManager.swift
//  TrustPaymentsCore
//

#if !COCOAPODS
    import TrustPayments3DSecure
    import TrustPaymentsCard
#endif
import Foundation
import SeonSDK
import UIKit

// swiftlint:disable type_body_length

/// Transaction manager used to comunicate with Trust Payments gateway. Also handles 3DS transaction flow.
/// Used in the drop-in view controller to perform card transactions as well as wallet transactions.
///
/// Works as a stand alone object and can be utilised with conjunction with your own UI layer.
/// The transaction is triggered after calling `performTransaction` or `performWalletTransaction` method.
/// - warning:The `PaymentTransactionManager` will throw an error on initialisation if username, gateway type and environment were not set.
/// Call `configure()` method to set all properties:
/// ```
/// TrustPayments.instance.configure()
/// ```
///
/// Refer to the public init methods for further explanation of configuration parameters
@objc public final class PaymentTransactionManager: NSObject {
    // MARK: Properties
    
    public private(set) var jwt: String?
    
    private(set) var originalJwt: String?
    
    /// - SeeAlso: TrustPaymentsCore.APIManager
    private let apiManager: APIManager
    
    /// - SeeAlso: TrustPayments3DSecure.TP3DSecureManager
    private let threeDSecureManager: TP3DSecureManager
    
    /// - SeeAlso: TrustPayments3DSecure.ThreeDSecureWebViewController
    private var threeDSecureWebViewController: ThreeDSecureWebViewController!
    
    let isLiveStatus: Bool
    
    private var jsInitCacheToken: String?
    
    private(set) var card: Card?
    
    var requestId: String!
    
    private var transactionResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?
    
    private let cardinalStyleManager: CardinalStyleManager?
    private let cardinalDarkModeStyleManager: CardinalStyleManager?
    
    private var randomString: String {
        let randomString = String.randomString(length: 36)
        let start = randomString.index(randomString.startIndex, offsetBy: 2)
        let end = randomString.index(randomString.startIndex, offsetBy: 10)
        return String(randomString[start ..< end])
    }
    
    private var decodedJwt: DecodedMerchantJWT? {
        guard let jwt = jwt else { return nil }
        return try? DecodedMerchantJWT(jwt: jwt)
    }
    
    private var fraudControlTransactionId: String? {
        if decodedJwt?.fraudControlTransactionId != nil {
            return nil
        }
        return TrustPayments.instance.seonManager?.fingerprintBase64()
    }
    
    // MARK: Initialization
    
    /// Initializes an instance of the receiver.
    ///
    /// - Parameter jwt: JWT token - set if possible, otherwise update JWT in perform/Wallet/Transaction()
    /// - Parameter cardinalStyleManager: manager to set the interface style (view customization)
    /// - Parameter cardinalDarkModeStyleManager: manager to set the interface style in dark mode
    @objc public convenience init(jwt: String?, cardinalStyleManager: CardinalStyleManager? = nil, cardinalDarkModeStyleManager: CardinalStyleManager? = nil) throws {
        try self.init(apiManager: nil, threeDSecureManager: nil, jwt: jwt, cardinalStyleManager: cardinalStyleManager, cardinalDarkModeStyleManager: cardinalDarkModeStyleManager)
    }
    
    /// Initializes an internal instance of the receiver for tests.
    /// - Parameters:
    /// - Parameter - apiManager: API Manager used for perming requests
    /// - Parameter threeDSecureManager - ThreeDSecureManager used for handling Cardinal configurations
    /// - Parameter jwt: JWT token - set if possible, otherwise update JWT in perform/Wallet/Transaction()
    /// - Parameter cardinalStyleManager: manager to set the interface style (view customization)
    /// - Parameter cardinalDarkModeStyleManager: manager to set the interface style in dark mode
    init(apiManager: APIManager? = nil, threeDSecureManager: TP3DSecureManager? = nil, jwt: String?, cardinalStyleManager: CardinalStyleManager? = nil, cardinalDarkModeStyleManager: CardinalStyleManager? = nil) throws {
        guard let username = TrustPayments.instance.username else {
            // Sentry 1 - missing username
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Missing username")
            throw TPInitError(missingValue: .missingUsername)
        }
        
        guard let gatewayType = TrustPayments.instance.gateway else {
            // Sentry 2 - missing gateway type
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Missing gateway")
            throw TPInitError(missingValue: .missingGateway)
        }
        
        guard let env = TrustPayments.instance.environment else {
            // Sentry 3 - missing environment
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Missing environment")
            throw TPInitError(missingValue: .missingEnvironment)
        }
        let isLiveStatus = env == .production ? true : false
        
        // Default transaltions
        let styleManager = PaymentTransactionManager.setDefaultChallengeTranslations(styleManager: cardinalStyleManager)
        let darkModeStyleManager = PaymentTransactionManager.setDefaultChallengeTranslations(styleManager: cardinalDarkModeStyleManager)
        
        if let manager = apiManager {
            self.apiManager = manager
        } else {
            let configuration = DefaultAPIClientConfiguration(scheme: .https, host: gatewayType.host)
            let apiClient = DefaultAPIClient(configuration: configuration)
            self.apiManager = DefaultAPIManager(username: username, apiClient: apiClient)
        }
        
        self.threeDSecureManager = threeDSecureManager ?? TP3DSecureManager(isLiveStatus: isLiveStatus,
                                                                            cardinalStyleManager: styleManager,
                                                                            cardinalDarkModeStyleManager: darkModeStyleManager)
        // checks if can proceed with given cardinal warnings
        let cardinalWarnings = self.threeDSecureManager.warnings
        guard PaymentTransactionManager.canProceed(with: cardinalWarnings, isLiveStatus: isLiveStatus) else {
            // Sentry 4 - security warnings
            let logMessage = "3DS Security warnings detected: \(cardinalWarnings.map(\.localizedDescription).joined(separator: ", "))"
            TrustPayments.instance.monitoringManager.log(severity: .info, message: logMessage)
            throw TPInitError(cardinalWarnings: cardinalWarnings)
        }
        
        self.jwt = jwt
        originalJwt = jwt
        self.isLiveStatus = isLiveStatus
        self.cardinalStyleManager = styleManager
        self.cardinalDarkModeStyleManager = darkModeStyleManager
        super.init()
    }
    
    // MARK: Api requests
    
    /// executes payment transaction request
    /// - Parameters:
    ///   - request: RequestObject instance
    ///   - responseClosure: response closure with following parameters: JWT token | array with responses decoded from JWT | an error object indicating if there were any general errors in connecting to the server
    private func makePaymentRequest(request: RequestObject, responseClosure: @escaping (_ jwt: String?, _ responses: [JWTResponseObject]?, _ error: APIClientError?, _ requestReference: String?) -> Void) {
        
        guard let jwt = jwt else {
            // Sentry 6 - missing jwt
            TrustPayments.instance.monitoringManager.log(severity: .error, message: "Missing JWT in request body")
            responseClosure(nil, nil, APIClientError.jwtMissing, nil)
            return
        }
        
        apiManager.makeGeneralRequest(jwt: jwt, request: request, success: { [weak self] response in
            guard let self = self else { return }
            self.jwt = response.newJWT
            responseClosure(response.jwt, response.jwtResponses, nil, response.requestReference)
        }, failure: { error in
            responseClosure(nil, nil, error, nil)
        })
    }
    
    /// executes payment transaction or threedquery request
    private func makePaymentRequest() {
        let cardNumber = card?.cardNumber?.rawValue.isEmpty ?? true ? nil : card?.cardNumber?.rawValue
        let cvv = card?.cvv?.rawValue.isEmpty ?? true ? nil : card?.cvv?.rawValue
        let expiryDate = card?.expiryDate?.rawValue.isEmpty ?? true ? nil : card?.expiryDate?.rawValue
        
        let request = RequestObject(requestId: requestId, cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate, cacheToken: jsInitCacheToken, fraudControlTransactionId: fraudControlTransactionId)
        
        makePaymentRequest(request: request, responseClosure: { [weak self] jwt, responseObjects, error, requestReference in
            guard let self = self else { return }
            
            // bypass 3dsecure - checking if it is possible to perform a 3dsecure challenge (Cardinal Authentication)
            guard let unwrappedJwt = jwt, let responseObjects = responseObjects, let threeDQueryResponseObject = responseObjects.first(where: { $0.requestTypeDescription(contains: TypeDescription.threeDQuery) }), threeDQueryResponseObject.responseCustomerOutput == .threeDRedirect else {
                let jwtArray = jwt != nil ? [jwt!] : []
                self.completeTransaction(jwtArray, nil, error)
                return
            }
            
            if let threeDVersion = threeDQueryResponseObject.threeDVersion?.split(separator: ".").first {
                self.createAuthenticationSessionWithCardinalOrWebView(jwt: unwrappedJwt,
                                                                      responseObjects: responseObjects,
                                                                      isThreeDSecureV1: threeDVersion == "1",
                                                                      requestReference: requestReference)
            } else {
                // Sentry 5 - Incorrect 3D version's format in response
                TrustPayments.instance.monitoringManager.log(severity: .info,
                                                             message: "Incorrect 3DS version returned",
                                                             additionals: ["reference": requestReference,
                                                                           "siteReference": self.decodedJwt?.siteReference])
            }
        })
    }
    
    /// executes js init request (to get threeDInit - JWT token to setup the Cardinal) and Cardinal setup
    /// - Parameter completion: success closure with following parameters: consumer session id
    /// - Parameter failure: closure with an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    private func makeJSInitRequest(completion: @escaping ((String) -> Void), failure: @escaping ((String?, APIClientError?) -> Void)) {
        let jsInitRequest = RequestObject(isJSInitRequest: true, requestId: requestId)
        
        guard let jwt = jwt else {
            // Sentry 6 - missing jwt
            TrustPayments.instance.monitoringManager.log(severity: .error, message: "Missing JWT in request body")
            failure(nil, APIClientError.jwtMissing)
            return
        }
        apiManager.makeGeneralRequest(jwt: jwt, request: jsInitRequest, success: { [weak self] response in
            guard let self = self else { return }
            guard let jwtResponseObject = response.jwtResponses.first else {
                // Sentry 7 - missing response object for JSINIT
                TrustPayments.instance.monitoringManager.log(severity: .info,
                                                             message: "Missing response for JSINIT",
                                                             additionals: ["reference": response.requestReference,
                                                                           "siteReference": self.decodedJwt?.siteReference])
                failure(response.jwt, APIClientError.responseValidationError(.missingData))
                return
            }
            self.jwt = response.newJWT
            switch jwtResponseObject.responseErrorCode {
            case .successful:
                guard let cacheToken = jwtResponseObject.cacheToken else {
                    // Sentry 8 - missing cacheToken for JSINIT
                    TrustPayments.instance.monitoringManager.log(severity: .error,
                                                                 message: "Missing cacheToken in JSINIT response",
                                                                 additionals: ["reference": response.requestReference,
                                                                               "siteReference": self.decodedJwt?.siteReference])
                    failure(response.jwt, APIClientError.responseValidationError(.missingData))
                    return
                }
                self.jsInitCacheToken = cacheToken
                
                guard let threeDInit = jwtResponseObject.threeDInit else {
                    // Sentry 9 - missing threeDInit for JSINIT
                    TrustPayments.instance.monitoringManager.log(severity: .error,
                                                                 message: "Missing threeDInit in response",
                                                                 additionals: ["reference": response.requestReference,
                                                                               "siteReference": self.decodedJwt?.siteReference])
                    failure(response.jwt, APIClientError.responseValidationError(.missingData))
                    return
                }
                
                // cardinal setup
                self.threeDSecureManager.setup(with: threeDInit, completion: { consumerSessionId in
                    completion(consumerSessionId)
                }, failure: { _ in
                    failure(response.jwt, APIClientError.cardinalSetupInternalError)
                })
            default:
                failure(response.jwt, nil)
            }
        }, failure: { error in
            failure(nil, error)
        })
    }
    
    // MARK: Transaction flow
    
    /// executes payment transaction flow
    /// - Parameter jwt: jwt token (provide if you want to update the token)
    /// - Parameter card: bank card object (if there is a nil, the assumption is that a transaction with a parent transaction reference is made)
    /// - Parameter transactionResponseClosure: closure triggered after the transaction is completed, with the following parameters: JWT key array with responses from all requests (before decoding, the signature of each key should be verified) | an object that contains 3ds authentication data sent with AUTH request | an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    public func performTransaction(jwt: String? = nil, card: Card?, transactionResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?) {
        if let jwt = jwt {
            self.jwt = jwt
            originalJwt = jwt
        }
        requestId = "J-" + randomString
        self.card = card
        
        guard self.jwt != nil else {
            // Sentry 6 - missing jwt
            TrustPayments.instance.monitoringManager.log(severity: .error, message: "Missing JWT in request body")
            let invalidJWTError = APIClientError.jwtMissing
            transactionResponseClosure?([], nil, invalidJWTError)
            return
        }
        
        // Return a validation error when the requesttypedescriptions array is not set correctly in the JWT payload
        guard let typeDescriptions = decodedJwt?.typeDescriptions, !typeDescriptions.isEmpty else {
            // Sentry 10 - Incorrect request types combination
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Incorrect request types: empty")
            let invalidTypeDescriptions = APIClientError.responseValidationError(.missingTypeDescriptions)
            transactionResponseClosure?([], nil, invalidTypeDescriptions)
            return
        }
        
        self.transactionResponseClosure = transactionResponseClosure
        
        if decodedJwt?.typeDescriptions.contains(.threeDQuery) ?? false {
            makeJSInitRequest(completion: { [weak self] _ in
                guard let self = self else { return }
                self.makePaymentRequest()
            }, failure: { [weak self] jwt, error in
                guard let self = self else { return }
                let jwtArray = jwt != nil ? [jwt!] : []
                self.completeTransaction(jwtArray, nil, error)
            })
        } else {
            makePaymentRequest()
        }
    }
    
    // objc workaround
    /// executes payment transaction flow
    /// - Parameter jwt: jwt token (provide if you want to update the token)
    /// - Parameter card: bank card object (if there is a nil, the assumption is that a transaction with a parent transaction reference is made)
    /// - Parameter transactionResponseClosure: closure triggered after the transaction is completed, with the following parameters: JWT key array with responses from all requests (before decoding, the signature of each key should be verified) | an object that contains 3ds authentication data sent with AUTH request | an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    @available(swift, obsoleted: 1.0)
    @objc public func performTransaction(jwt: String? = nil, card: Card?, transactionResponseClosure: (([String], TPAdditionalTransactionResult?, NSError?) -> Void)?) {
        performTransaction(jwt: jwt, card: card, transactionResponseClosure: { jwt, transactionResult, error in
            transactionResponseClosure?(jwt, transactionResult, error?.foundationError)
        })
    }
    
    // MARK: Wallet
    
    /// Executes wallet payment transaction flow
    /// - Parameters:
    ///   - walletSource: WalletSource (ApplePay)
    ///   - walletToken: String representation of PKPayment
    ///   - jwt: jwt token containing wallet token
    ///   - transactionResponseClosure: closure triggered after the transaction is completed, with the following parameters: JWT key array with responses from all requests (before decoding, the signature of each key should be verified) | an object that contains 3ds authentication data sent with AUTH request | an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    
    /// ```
    /// // Wallet token
    /// extension PKPayment {
    ///     var stringRepresentation: String? {
    ///         let paymentData = token.paymentData
    ///         guard let paymentDataJson = try? JSONSerialization.jsonObject(with: paymentData,
    ///                                                                    options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] else { return nil }
    ///         let expectedJson: [String: Any] = [
    ///            "token":
    ///                [
    ///                    "transactionIdentifier": token.transactionIdentifier,
    ///                    "paymentData": paymentDataJson,
    ///                    "paymentMethod":
    ///                        [
    ///                            "network": token.paymentMethod.network?.rawValue,
    ///                            "type": token.paymentMethod.type.description,
    ///                            "displayName": token.paymentMethod.displayName
    ///                        ]
    ///                ]
    ///         ]
    ///         guard let expectedJsonData = try? JSONSerialization.data(withJSONObject: expectedJson,
    ///                                                                         options: JSONSerialization.WritingOptions(rawValue: 0)) else { return nil }
    ///         return String(data: expectedJsonData, encoding: .utf8)
    ///     }
    /// }
    /// ```
    public func performWalletTransaction(walletSource: WalletSource, walletToken: String, jwt: String, transactionResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?) {
        // For wallet transactions there is no JSINIT & Cardinal
        self.jwt = jwt
        originalJwt = jwt
        requestId = "J-" + randomString
        
        // Return validation error when the request types array is empty
        guard let typeDescriptions = decodedJwt?.typeDescriptions, !typeDescriptions.isEmpty else {
            // Sentry 11 - Incorrect request types for Wallet transaction
            let invalidTypeDescriptions = APIClientError.responseValidationError(.missingTypeDescriptions)
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Incorrect request types: empty")
            transactionResponseClosure?([], nil, invalidTypeDescriptions)
            return
        }
        
        self.transactionResponseClosure = transactionResponseClosure
        
        makeWalletRequest(with: walletSource, token: walletToken)
    }
    
    /// Executes wallet payment transaction flow
    /// - Parameters:
    ///   - walletSource: WalletSource (ApplePay)
    ///   - walletToken: String representation of PKPayment
    ///   - jwt: jwt token containing wallet token
    ///   - transactionResponseClosure: closure triggered after the transaction is completed, with the following parameters: JWT key array with responses from all requests (before decoding, the signature of each key should be verified) | an object that contains 3ds authentication data sent with AUTH request | an error object indicating if there were any general errors in connecting to the server or in 3ds authentication
    @available(swift, obsoleted: 1.0)
    @objc public func performWalletTransaction(walletSource: WalletSource, walletToken: String, jwt: String, transactionResponseClosure: (([String], TPAdditionalTransactionResult?, NSError?) -> Void)?) {
        performWalletTransaction(walletSource: walletSource, walletToken: walletToken, jwt: jwt, transactionResponseClosure: { jwt, transactionResult, error in
            transactionResponseClosure?(jwt, transactionResult, error?.foundationError)
        })
    }
    
    private func makeWalletRequest(with source: WalletSource, token: String) {
        let request = RequestObject(requestId: requestId, walletSource: source.code, walletToken: token, fraudControlTransactionId: fraudControlTransactionId)
        
        makePaymentRequest(request: request, responseClosure: { [weak self] jwt, _, error, _ in
            guard let self = self else { return }
            let jwtArray = jwt != nil ? [jwt!] : []
            self.completeTransaction(jwtArray, nil, error)
        })
    }
    
    // MARK: - APM
    
    public func performAPMTransaction(jwt: String?, apm: APM, styling: TPAPMStyling? = nil, transactionResponseClosure: (([String], TPAdditionalTransactionResult?, APIClientError?) -> Void)?) {
        // Note that APM transactions support only AUTH request type
        if let jwt = jwt {
            self.jwt = jwt
            originalJwt = jwt
        }
        requestId = "J-" + randomString
        
        // Return validation error when the request types array is empty
        guard let typeDescriptions = decodedJwt?.typeDescriptions, !typeDescriptions.isEmpty else {
            // Sentry 12 - incorrect request types for APM
            let invalidTypeDescriptions = APIClientError.responseValidationError(.missingTypeDescriptions)
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Incorrect request types: empty")
            transactionResponseClosure?([], nil, invalidTypeDescriptions)
            return
        }
        
        // Return validation error when the returnUrl is empty or invalid
        guard
            let returnUrl = decodedJwt?.returnUrl,
            returnUrl.isValidURL
        else {
            // Sentry 18 - incorrect return url for APM
            let invalidReturnUrl = APIClientError.responseValidationError(.missingReturnUrl)
            TrustPayments.instance.monitoringManager.log(severity: .info, message: "Empty or incorrect return url")
            transactionResponseClosure?([], nil, invalidReturnUrl)
            return
        }
        
        self.transactionResponseClosure = transactionResponseClosure
        
        let request = RequestObject(requestId: requestId, apmCode: apm.code)
        
        makePaymentRequest(request: request, responseClosure: { [weak self] jwt, responseObjects, error, _ in
            guard let self = self else { return }
            guard let firstAuthResponse = responseObjects?.first(where: { $0.requestTypeDescription == .auth }),
                  let redirectUrl = firstAuthResponse.redirectUrl, !redirectUrl.isEmpty else {
                let jwtArray = jwt != nil ? [jwt!] : []
                self.completeTransaction(jwtArray, nil, error)
                return
            }
            // Show the web view
            let model = APMViewModel(apm: apm, returnUrl: returnUrl, redirectUrl: redirectUrl, styling: styling)
            let controller = APMWebViewController(viewModel: model)
            controller.setCompletion { [weak self] settleStatus, transactionReference in
                let result = TPAdditionalTransactionResult(settleStatus: settleStatus, transactionReference: transactionReference)
                let error: APIClientError? = settleStatus == "3" ? APIClientError.apmSettleStatusError : nil
                self?.completeTransaction([jwt ?? .empty], result, error)
            } sessionAuthenticationFailure: { [weak self] in
                self?.completeTransaction([jwt ?? .empty], nil, APIClientError.unknownError)
            }
            
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .fullScreen
            // Sentry 13 - missing top most VC - UIKit changed - form won't be displayed
            guard let topViewController = UIApplication.shared.topMostViewController else {
                TrustPayments.instance.monitoringManager.log(severity: .info, message: "Missing top most View controller")
                self.completeTransaction([], nil, APIClientError.unknownError)
                return
            }
            topViewController.present(navigationController, animated: true, completion: nil)
        })
    }
    
    // completion of the transaction flow, overwriting the JWT to its original state - in case of payment retry
    private func completeTransaction(_ jwtArray: [String], _ transactionResult: TPAdditionalTransactionResult?, _ error: APIClientError?) {
        jwt = originalJwt
        transactionResponseClosure?(jwtArray, transactionResult, error)
    }
    
    // MARK: 3DSecure flow
    
    /// Create the authentication session - call this method to hand control to SDK for performing the challenge between the user and the issuing bank.
    /// - Parameters:
    ///   - jwt: JWT response token (returned for validation purposes on the application side)
    ///   - responseObjects: Response object from previous ThreeDQuery requests
    ///   - isThreeDSecureV1: indicates which version of 3dsecure it is
    private func createAuthenticationSessionWithCardinalOrWebView(jwt: String, responseObjects: [JWTResponseObject], isThreeDSecureV1: Bool, requestReference: String?) {
        let threeDQueryResponseObject = responseObjects.first(where: { $0.requestTypeDescription(contains: TypeDescription.threeDQuery) })!
        
        // VERSION 2
        // acquirerTransactionReference property from threedquery response
        guard let v2TransactionId: String = threeDQueryResponseObject.acquirerTransactionReference else {
            // Sentry 14 - acquirerTransactionReference missing
            TrustPayments.instance.monitoringManager.log(severity: .error,
                                                         message: "Missing acquirerTransactionReference",
                                                         additionals: ["reference": requestReference,
                                                                       "siteReference": decodedJwt?.siteReference])
            completeTransaction([], nil, APIClientError.responseValidationError(.missingData))
            return
        }
        // threeDPayload property from threedquery response
        let v2TransactionPayload: String = threeDQueryResponseObject.threeDPayload ?? .empty
        
        // VERSION 1
        // payload: threeDPayload property from threedquery response
        let v1TransactionPayload = threeDQueryResponseObject.threeDPayload ?? .empty
        // acsUrl: acs url
        let v1TransactionAcsUrl = threeDQueryResponseObject.acsUrl ?? .empty
        // mdValue: acquirerTransactionReference property from threedquery response
        let v1MdValue = threeDQueryResponseObject.acquirerTransactionReference ?? .empty
        
        if isThreeDSecureV1, decodedJwt?.termUrl == nil {
            // Sentry 15 - missing termUrl for 3Ds v1
            let invalidJWTError = APIClientError.responseValidationError(.missingTermUrl)
            TrustPayments.instance.monitoringManager.log(severity: .error,
                                                         message: "Missing termUrl",
                                                         additionals: ["reference": requestReference,
                                                                       "siteReference": decodedJwt?.siteReference])
            completeTransaction([jwt], nil, invalidJWTError)
            return
        }
        
        let viewModel = ThreeDSecureWebViewModel(payload: v1TransactionPayload, termUrl: decodedJwt?.termUrl ?? .empty, acsUrl: v1TransactionAcsUrl, mdValue: v1MdValue, cardinalStyleManager: cardinalStyleManager, cardinalDarkModeStyleManager: cardinalDarkModeStyleManager)
        threeDSecureWebViewController = ThreeDSecureWebViewController(viewModel: viewModel)
        
        viewModel.webViewStatusCodeError = { status in
            // Sentry 17 - Catch network errors
            TrustPayments.instance.monitoringManager.log(severity: .error, message: "Network error: \(status)")
        }
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "3dsecure-flow")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var payloadForValidation: String?
        var jwtArray: [String] = [jwt]
        var transactionResult: TPAdditionalTransactionResult?
        
        var transactionFoundationError: APIClientError?
        var authenticationError: Bool = false
        let fingerprint = fraudControlTransactionId
        
        dispatchQueue.async { [unowned self] in
            dispatchGroup.enter()
            if isThreeDSecureV1 {
                self.threeDSecureWebViewController.setCompletion(sessionAuthenticationValidatePayload: { payload in
                    transactionResult = TPAdditionalTransactionResult(pares: payload)
                    payloadForValidation = payload
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }, sessionAuthenticationFailure: {
                    authenticationError = true
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                })
            } else {
                self.threeDSecureManager.continueSession(with: v2TransactionId, payload: v2TransactionPayload, sessionAuthenticationValidateJWT: { jwt in
                    transactionResult = TPAdditionalTransactionResult(threeDResponse: jwt)
                    payloadForValidation = jwt
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }, sessionAuthenticationFailure: {
                    authenticationError = true
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                })
            }
            
            dispatchSemaphore.wait()
            guard let payloadForValidation = payloadForValidation else { return }
            dispatchGroup.enter()
            
            let otherTypeDescriptions = self.decodedJwt?.typeDescriptions
            if otherTypeDescriptions?.isEmpty ?? true {
                // Empty if there are no more request types after threeDQuery
                dispatchSemaphore.signal()
                dispatchGroup.leave()
            } else {
                let cardNumber = self.card?.cardNumber?.rawValue.isEmpty ?? true ? nil : self.card?.cardNumber?.rawValue
                let cvv = self.card?.cvv?.rawValue.isEmpty ?? true ? nil : self.card?.cvv?.rawValue
                let expiryDate = self.card?.expiryDate?.rawValue.isEmpty ?? true ? nil : self.card?.expiryDate?.rawValue
                
                // swiftlint:disable line_length
                let request = RequestObject(requestId: self.requestId, cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate, threeDResponse: isThreeDSecureV1 ? nil : payloadForValidation, cacheToken: self.jsInitCacheToken, pares: isThreeDSecureV1 ? payloadForValidation : nil, fraudControlTransactionId: fingerprint)
                // swiftlint:enable line_length
                
                self.makePaymentRequest(request: request, responseClosure: { jwt, _, error, _ in
                    if let jwt = jwt {
                        jwtArray.append(jwt)
                    }
                    transactionFoundationError = error
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                })
            }
            
            dispatchSemaphore.wait()
        }
        
        dispatchGroup.notify(queue: dispatchQueue) { [unowned self] in
            DispatchQueue.main.async {
                self.completeTransaction(jwtArray, transactionResult, authenticationError ? APIClientError.cardinalAuthenticationError : transactionFoundationError)
            }
        }
        
        if isThreeDSecureV1 {
            let navigationController = UINavigationController(rootViewController: threeDSecureWebViewController)
            navigationController.modalPresentationStyle = .fullScreen
            // Sentry 13 - missing top most VC - UIKit changed - form won't be displayed
            guard let topViewController = UIApplication.shared.topMostViewController else {
                TrustPayments.instance.monitoringManager.log(severity: .info, message: "Missing top most View controller")
                completeTransaction([], nil, APIClientError.unknownError)
                return
            }
            topViewController.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: Validation
    
    /// Checks whether can proceed with Cardinal warnigns, in dev environment emulator, debugger and untrusted source is acceptable
    /// - Parameters:
    ///   - cardinalWarnings: Cardinal warnings
    ///   - isLiveStatus: determines whether should point to live or demo endpoints
    /// - Returns: true if can proceed
    private static func canProceed(with cardinalWarnings: [CardinalInitWarnings], isLiveStatus: Bool) -> Bool {
        let isTesting = Thread.current.isRunningXCTest && (ProcessInfo.processInfo.environment["APP_IS_RUNNING_INTEGRATION_TESTS"] == "YES")
        guard !isTesting else { return true }
        let acceptableWarnings: Set<CardinalInitWarnings> = isLiveStatus ? [] : [.emulatorBeingUsed, .debuggerAttached, .appFromNotTrustedSource]
        return Set(cardinalWarnings).subtracting(acceptableWarnings).isEmpty
    }
}

private extension PaymentTransactionManager {
    // PaymentTransactionManager is the only common place for supported flows (DropIn challenge v2, DropIn challenge v1, custom view challenge v2, custom view challenge v1)
    // That is why the default translations for the challenge view is implemented here to avoid repetition.
    static func setDefaultChallengeTranslations(styleManager: CardinalStyleManager?) -> CardinalStyleManager {
        let headerTitle = LocalizableKeys.ChallengeView.headerTitle.localizedString
        let cancelTitle = LocalizableKeys.ChallengeView.headerCancelTitle.localizedString
        
        if let manager = styleManager {
            if let toolbar = manager.toolbarStyleManager {
                if toolbar.headerText == nil {
                    toolbar.headerText = headerTitle
                }
                if toolbar.buttonText == nil {
                    toolbar.buttonText = cancelTitle
                }
            } else {
                manager.toolbarStyleManager = CardinalToolbarStyleManager(textColor: nil,
                                                                          textFont: nil,
                                                                          backgroundColor: nil,
                                                                          headerText: headerTitle,
                                                                          buttonText: cancelTitle)
            }
            return manager
        } else {
            let toolbarStyleManager = CardinalToolbarStyleManager(textColor: nil,
                                                                  textFont: nil,
                                                                  backgroundColor: nil,
                                                                  headerText: headerTitle,
                                                                  buttonText: cancelTitle)
            return CardinalStyleManager(toolbarStyleManager: toolbarStyleManager,
                                        labelStyleManager: nil,
                                        verifyButtonStyleManager: nil,
                                        continueButtonStyleManager: nil,
                                        resendButtonStyleManager: nil,
                                        textBoxStyleManager: nil)
        }
    }
}
