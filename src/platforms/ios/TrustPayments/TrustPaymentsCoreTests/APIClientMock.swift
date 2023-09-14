//
//  APIClientMock.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore

class APIClientMock: APIClient {
    var configuration: APIClientConfiguration
    var requestParameters: ((_ requestJson: [String: Any], _ maxRetries: Int, _ maxRetryInterval: TimeInterval) -> Void)?

    init(configuration: APIClientConfiguration) {
        self.configuration = configuration
    }

    func setEphemeralSession(maxRequestTime: TimeInterval) {}

    func perform<Request>(request: Request, maxRetries: Int, maxRetryInterval: TimeInterval, completion: @escaping (Result<Request.Response, APIClientError>) -> Void) where Request: APIRequest {
        guard let bodyData = try? JSONEncoder().encode(request) else { return }
        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] else { return }
        requestParameters?(json, maxRetries, maxRetryInterval)
    }
}
