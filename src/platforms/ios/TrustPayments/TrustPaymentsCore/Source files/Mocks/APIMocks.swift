//
//  APIMocks.swift
//  TrustPaymentsCore
//

import Foundation

final class EmptyResponseMock: APIResponse {}

final class EmptyRequestMock: APIRequestModel {
    typealias Response = EmptyResponseMock
    var method: APIRequestMethod { .post }
    var path: String { "" }
    var isNoContentResponse: Bool

    init(isNoContent: Bool = false) {
        isNoContentResponse = isNoContent
    }
}

class APIManagerMock: APIManager {
    var successBlock: (() -> (GeneralRequest.Response))?
    var failureBlock: (() -> (APIClientError))?

    func makeGeneralRequest(jwt: String, request _: RequestObject, success: @escaping ((GeneralRequest.Response) -> Void), failure: @escaping ((APIClientError) -> Void)) {
        if let s = successBlock {
            success(s())
        }
        if let f = failureBlock {
            failure(f())
        }
    }

    func makeGeneralRequests(jwt _: String, requests _: [RequestObject], success _: @escaping (([JWTResponseObject], String, String) -> Void), failure _: @escaping ((APIClientError) -> Void)) {
        fatalError("Not yet implemented")
    }
}
