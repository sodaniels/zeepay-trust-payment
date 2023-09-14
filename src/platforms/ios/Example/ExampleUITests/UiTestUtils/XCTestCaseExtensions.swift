import XCTest

extension XCTestCase {
    /// Take screenshot method
    /// - Parameters:
    ///   - element: element from current view
    ///   - name: name of screenshot file
    func takeScreenshot(of element: XCUIElement, name: String) {
        let screenshot = element.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        add(attachment)
    }

    func waitUntilCanInteract(with element: XCUIElement, timeout: TimeInterval = DefaultTestTimeouts.threeDSecureTextFieldDisplayed, message: String? = nil) {
        let userInteractionPossiblePredicate = NSPredicate(format: "%K == true && %K == true", #keyPath(XCUIElement.exists), #keyPath(XCUIElement.isHittable))
        let messageToShow = message ?? "Failed to find hittable \(element) after \(timeout) seconds."
        waitUntilElementExpectationIsFullfilled(for: element, predicate: userInteractionPossiblePredicate, timeout: timeout, errorMessage: messageToShow)
    }

    private func waitUntilElementExpectationIsFullfilled(for element: XCUIElement, predicate: NSPredicate, timeout: TimeInterval, errorMessage: String,
                                                         file: String = #file, line: Int = #line) {
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                self.recordFailure(withDescription: errorMessage, inFile: file, atLine: line, expected: true)
            }
        }
    }
}
