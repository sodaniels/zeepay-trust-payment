//
//  XCTestCase.swift
//  ExampleTests
//

import XCTest

/// KIF helpers
extension XCTestCase {
    func tester(file: String = #file, _ line: Int = #line) -> KIFUITestActor {
        KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(file: String = #file, _ line: Int = #line) -> KIFSystemTestActor {
        KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension XCTestCase {
    func wait(interval: TimeInterval = 1.0, completion: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
        }
    }

    /// Resolves mixed expectation (standard with inverted)
    /// Note: for test to suceed, all expectations have to be fulfilled, otherwise the test will wait till the timout occurs
    /// If only inverted expectation is fulfilled, the test will fail without waiting for the timeout
    /// - Parameters:
    /// - expectations: Array of mixed expectations
    /// - timeout: The time interval after which the test will fail
    func resolveMixed(expectations: [XCTestExpectation], timeout: TimeInterval) {
        guard let expectation = expectations.first(where: { $0.isInverted == false }) else {
            XCTFail("Missing expectation which is not inverted")
            return
        }
        let expectationWaiter = XCTWaiter()
        expectationWaiter.wait(for: expectations, timeout: timeout)
        // if standard expectation has not been fulfilled, the test fails
        guard !expectationWaiter.fulfilledExpectations.contains(expectation) else { return }
        XCTFail(expectations.first(where: { $0.isInverted })?.expectationDescription ?? "")
    }
}
