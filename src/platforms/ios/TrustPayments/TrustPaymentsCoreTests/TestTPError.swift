//
//  TestResponseError.swift
//  TrustPaymentsCoreTests
//

@testable import TrustPaymentsCore
import XCTest

class TestTPError: XCTestCase {
    func test_invalidJWT() throws {
        let sut = try responseErrorForInvalidJWT()
        let expectedError = TPError.invalidField(.invalidJWT, "Invalid field: jwt")
        XCTAssertEqual(expectedError.errorCode, sut.response.errorCode)
    }

    func test_invalidSiteReference() throws {
        let sut = try responseErrorForInvalidSiteReference()
        let expectedError = TPError.invalidField(.invalidSiteReference, "Invalid field: sitereference")
        XCTAssertEqual(expectedError.errorCode, sut.response.errorCode)
    }

    func test_unsupported() throws {
        let sut = try responseErrorForUnsupported()
        let expectedError = TPError.invalidField(.unknown, "Invalid field: unknown")
        XCTAssertEqual(expectedError.errorCode, sut.response.errorCode)
    }

    func test_missingResponse() throws {
        XCTAssertThrowsError(try responseErrorForMissingResponse())
    }
}

// MARK: Helper methods

extension TestTPError {
    enum ResponseErrorCodingKey: CodingKey {
        case response
    }

    /// Parses response with error in plain JSON format
    struct ResponseError: APIResponse {
        /// received response
        let response: JWTResponseObject

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ResponseErrorCodingKey.self)
            let responses = try container.decode([JWTResponseObject].self, forKey: .response)

            if let response = responses.first {
                self.response = response
            } else {
                let errorContext = DecodingError.Context(codingPath: [ResponseErrorCodingKey.response], debugDescription: "Missing response data")
                throw DecodingError.valueNotFound(JWTResponseObject.self, errorContext)
            }
        }
    }

    private func responseErrorForInvalidJWT() throws -> ResponseError {
        let json = invalidFieldJSON(forError: "jwt", code: 12_503)
        return try responseErrorWithJSON(json: json)
    }

    private func responseErrorForInvalidSiteReference() throws -> ResponseError {
        let json = invalidFieldJSON(forError: "sitereference", code: 12_507)
        return try responseErrorWithJSON(json: json)
    }

    private func responseErrorForUnsupported() throws -> ResponseError {
        let json = invalidFieldJSON(forError: "unknown", code: 12_500)
        return try responseErrorWithJSON(json: json)
    }

    private func responseErrorForMissingResponse() throws -> ResponseError {
        let json = ["response": []]
        return try responseErrorWithJSON(json: json)
    }

    private func invalidFieldJSON(forError detail: String, code: Int) -> [String: Any?] {
        let errorMessage = "Invalid field"
        let errorDetails = [detail]

        let json: [String: Any?] = ["response":
            [["errorcode": "\(code)",
              "errormessage": errorMessage,
              "errordata": errorDetails]]]
        return json
    }

    private func responseErrorWithJSON(json: [String: Any?]) throws -> ResponseError {
        let jsonObject = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions(rawValue: 0))
        let responseError = try JSONDecoder().decode(ResponseError.self, from: jsonObject)
        return responseError
    }
}
