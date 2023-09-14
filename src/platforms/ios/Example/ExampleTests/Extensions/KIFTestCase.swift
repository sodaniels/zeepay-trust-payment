//
//  KIFTestCase.swift
//  ExampleTests
//

extension KIFTestCase {
    private func findView(withClassname className: String, starting fromVC: UIViewController?) -> UIView? {
        func searchViewController(from controller: UIViewController?) -> UIView? {
            guard let parentController = controller else { return nil }
            if let foundView = searchView(from: parentController.view) {
                return foundView
            }
            if parentController.children.isEmpty == true {
                return searchViewController(from: parentController.presentedViewController)
            } else {
                for vcc in parentController.children {
                    if let v = searchViewController(from: vcc) {
                        return v
                    }
                    continue
                }
            }
            return nil
        }
        func searchView(from view: UIView) -> UIView? {
            if className == "\(type(of: view))" {
                return view
            }
            for subView in view.subviews {
                if let foundView = searchView(from: subView) {
                    return foundView
                }
                continue
            }
            return nil
        }
        return searchViewController(from: fromVC)
    }

    func enterCardinalSecurityCodeV2(delay: TimeInterval) {
        // Wait for the cardinal view to be presented
        wait(interval: delay, completion: { [unowned self] in
            // Find the Cardinal input text field, set its accessibility label and enter a security code
            // Then 'tap' the submit button
            if let caTextField = self.findView(withClassname: "CCATextField", starting: UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController) {
                caTextField.accessibilityLabel = "idCardinal"
                self.tester().validateEnteredText(false).enterText("1234", intoViewWithAccessibilityLabel: "idCardinal")
                self.wait(interval: 1) {
                    self.tester().tapView(withAccessibilityLabel: "SUBMIT")
                }
            } else {
                XCTFail("Could not find Cardinal Text field")
            }
        })
    }

    func enterCardinalSecurityCodeV1(delay: TimeInterval) {
        // Wait for the cardinal view to be presented
        wait(interval: delay, completion: { [unowned self] in
            // Find the Cardinal input text field, set its accessibility label and enter a security code
            // Then 'tap' the submit button
            self.tester().tapScreen(at: CGPoint(x: 230, y: 175))
            self.tester().wait(forTimeInterval: 2.0)
            self.tester().tapView(withAccessibilityLabel: "numbers")
            self.tester().wait(forTimeInterval: 1.0)
            self.tester().tapView(withAccessibilityLabel: "1")
            self.tester().tapView(withAccessibilityLabel: "2")
            self.tester().tapView(withAccessibilityLabel: "3")
            self.tester().tapView(withAccessibilityLabel: "4")
            do {
                // depending on the language set in simulator settings
                try self.tester().tryFindingView(withAccessibilityLabel: "go")
                self.tester().tapView(withAccessibilityLabel: "go")
            } catch {
                self.tester().tapView(withAccessibilityLabel: "idź")
            }
        })
    }
}
