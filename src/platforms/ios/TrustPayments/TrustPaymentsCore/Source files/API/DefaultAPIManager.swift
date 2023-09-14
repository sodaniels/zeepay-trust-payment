//
//  DefaultAPIManager.swift
//  TrustPaymentsCore
//

import Foundation

final class DefaultAPIManager: NSObject, APIManager {
    // MARK: Properties

    /// - SeeAlso: APIClient
    private let apiClient: APIClient
    /// merchant's username
    private let username: String
    /// JSON format version
    private let version = "1.00"
    /// accept customer output
    private let acceptCustomerOutput = "2.00"
    /// sdk name
    private let sdkName = "MSDK"
    /// swift language version
    private var swiftVersion: String {
        #if swift(>=5.2)
            return "swift-5.2"
        #elseif swift(>=5.1)
            return "swift-5.1"
        #elseif swift(>=5.0)
            return "swift-5.0"
        #elseif swift(>=4.2)
            return "swift-4.2"
        #elseif swift(>=4.1)
            return "swift-4.1"
        #endif
    }

    // MARK: Timeouts

    /// The maximum number a request will retry
    private let maxNumberOfRetries: Int = 20
    /// The maximum time interval in seconds a request will retry
    /// depending on what will happen first, number of retries or time limit
    private let maxIntervalForRetries: TimeInterval = 40
    /// The maximum time allowed in seconds for request to return a response
    /// Set on URLSession
    private let maxRequestTime: TimeInterval = 60

    /// sdk release version
    private var sdkVersion: String {
        Bundle(for: DefaultAPIManager.self).releaseVersionNumber ?? ""
    }

    /// ios version
    private var iosVersion: String {
        let os = ProcessInfo().operatingSystemVersion
        return "iOS\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
    }

    /// version info for general request parameter
    var versionInfo: String {
        "\(sdkName)::\(swiftVersion)::\(sdkVersion)::\(iosVersion)"
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - username: merchant's username
    ///   - apiClient: Object conforming to APIClient protocol, manages url session
    init(username: String, apiClient: APIClient) {
        self.username = username
        self.apiClient = apiClient
        super.init()

        apiClient.setEphemeralSession(maxRequestTime: maxRequestTime)
    }

    // MARK: Functions

    /// Performs the payment transaction request
    /// - Parameters:
    ///   - jwt: encoded JWT token
    ///   - request: object in which transaction parameters should be specified (e.g. what type - auth, 3dsecure etc)
    ///   - success: success closure with response objects (decoded transaction responses, in which settle status and transaction error code can be checked), and a JWT key that allows you to check the signature, and new JWT to be swapped in the request sequence
    ///   - failure: failure closure with general APIClient error like: connection error, server error, decoding problem
    func makeGeneralRequest(jwt: String, request: RequestObject, success: @escaping ((_ response: GeneralRequest.Response) -> Void), failure: @escaping ((_ error: APIClientError) -> Void)) {
        let generalRequest = GeneralRequest(alias: username, jwt: jwt, version: version, versionInfo: versionInfo, acceptCustomerOutput: acceptCustomerOutput, requests: [request])
        apiClient.perform(request: generalRequest,
                          maxRetries: maxNumberOfRetries,
                          maxRetryInterval: maxIntervalForRetries) { result in
            switch result {
            case let .success(response):
                success(response)
            case let .failure(error):
                failure(error)
            }
        }
    }

    /// Performs the payment transaction requests
    /// - Parameters:
    ///   - jwt: encoded JWT token
    ///   - requests: request objects (in each object transaction parameters should be specified - e.g. what type - auth, 3dsecure etc)
    ///   - success: success closure with response objects (decoded transaction responses, in which settle status and transaction error code can be checked), and a JWT key that allows you to check the signature, and new JWT to be swapped in the request sequence
    ///   - failure: failure closure with general APIClient error like: connection error, server error, decoding problem
    func makeGeneralRequests(jwt: String, requests: [RequestObject], success: @escaping ((_ jwtResponses: [JWTResponseObject], _ jwt: String, _ newJWT: String) -> Void), failure: @escaping ((_ error: APIClientError) -> Void)) {
        let generalRequest = GeneralRequest(alias: username, jwt: jwt, version: version, versionInfo: versionInfo, acceptCustomerOutput: acceptCustomerOutput, requests: requests)
        apiClient.perform(request: generalRequest,
                          maxRetries: maxNumberOfRetries,
                          maxRetryInterval: maxIntervalForRetries) { result in
            switch result {
            case let .success(response):
                // Sentry 16 - check if error and log request reference
                success(response.jwtResponses, response.jwt, response.newJWT)
            case let .failure(error):
                failure(error)
            }
        }
    }
}
