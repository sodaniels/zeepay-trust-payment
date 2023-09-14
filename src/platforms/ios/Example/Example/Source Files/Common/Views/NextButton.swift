//
//  NextButton.swift
//  Example
//

/// A subclass of RequestButton, consists of title and spinner for the request interval
public final class NextButton: RequestButton {
    override public func configureView() {
        super.configureView()
        accessibilityIdentifier = "nextButton"
        title = Localizable.NextButton.title.text
    }
}

private extension Localizable {
    enum NextButton: String, Localized {
        case title
    }
}
