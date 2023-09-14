//
//  SingleInputView.swift
//  Example
//

import UIKit

final class SingleInputView: BaseView {
    private lazy var cardNumberInput: CardNumberInputView = CardNumberInputView(inputViewStyleManager: inputViewStyleManager, inputViewDarkModeStyleManager: darkModeInputViewStyleManager)

    private lazy var expiryDateInput: ExpiryDateInputView = ExpiryDateInputView(inputViewStyleManager: inputViewStyleManager, inputViewDarkModeStyleManager: darkModeInputViewStyleManager)

    private lazy var cvvInput: CVVInputView = CVVInputView(inputViewStyleManager: inputViewStyleManager, inputViewDarkModeStyleManager: darkModeInputViewStyleManager)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardNumberInput, expiryDateInput, cvvInput])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    let inputViewStyleManager: InputViewStyleManager?
    let darkModeInputViewStyleManager: InputViewStyleManager?

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - inputViewStyleManager: instance of manager to customize view
    ///   - darkModeInputViewStyleManager: instance of manager to customize view in dark mode
    @objc public init(inputViewStyleManager: InputViewStyleManager?, darkModeInputViewStyleManager: InputViewStyleManager?) {
        self.inputViewStyleManager = inputViewStyleManager
        self.darkModeInputViewStyleManager = darkModeInputViewStyleManager
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SingleInputView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    @objc func setupProperties() {
        cardNumberInput.cardNumberInputViewDelegate = self
        backgroundColor = UIColor(light: .white, dark: .black)
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        addSubviews([stackView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        stackView.addConstraints([
            equal(self, \.centerYAnchor),
            equal(self, \.centerXAnchor)
        ])
    }
}

extension SingleInputView: CardNumberInputViewDelegate {
    func cardNumberInputViewDidComplete(_ cardNumberInputView: CardNumberInputView) {
        cvvInput.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }

    func cardNumberInputViewDidChangeText(_ cardNumberInputView: CardNumberInputView) {
        cvvInput.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }
}
