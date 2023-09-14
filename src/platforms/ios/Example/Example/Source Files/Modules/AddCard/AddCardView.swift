//
//  AddCardView.swift
//  Example
//

import UIKit

final class AddCardView: BaseView {
    var isFormValid: Bool {
        cardNumberInput.isInputValid && expiryDateInput.isInputValid && cvvInput.isInputValid
    }

    var addCardButtonTappedClosure: (() -> Void)? {
        get { addCardButton.onTap }
        set { addCardButton.onTap = newValue }
    }

    private(set) lazy var cardNumberInput: CardNumberInputView = CardNumberInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: darkModeDropInStyleManager?.inputViewStyleManager)

    private(set) lazy var expiryDateInput: ExpiryDateInputView = ExpiryDateInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: darkModeDropInStyleManager?.inputViewStyleManager)

    private(set) lazy var cvvInput: CVVInputView = CVVInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: darkModeDropInStyleManager?.inputViewStyleManager)

    private(set) lazy var addCardButton: AddCardButton = {
        guard let styleManager = dropInViewStyleManager?.requestButtonStyleManager as? AddCardButtonStyleManager else {
            fatalError("Expected style manager of type AddCardButtonStyleManager")
        }
        return AddCardButton(addCardButtonStyleManager: styleManager)
    }()

    private let stackContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardNumberInput, expiryDateInput, cvvInput, addCardButton])
        stackView.axis = .vertical
        stackView.spacing = spacingBetweenInputViews
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let stackViewLeadingConstraint = "stackViewLeadingConstraint"
    private let stackViewTrailingConstraint = "stackViewTrailingConstraint"
    private let stackViewTopConstraint = "stackViewTopConstraint"
    private let stackViewBottomConstraint = "stackViewBottomConstraint"

    let dropInViewStyleManager: DropInViewStyleManager?
    let darkModeDropInStyleManager: DropInViewStyleManager?

    var spacingBetweenInputViews: CGFloat = 30 {
        didSet {
            stackView.spacing = spacingBetweenInputViews
        }
    }

    var insets = UIEdgeInsets(top: 15, left: 30, bottom: -15, right: -30) {
        didSet {
            buildStackViewConstraints()
        }
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - dropInViewStyleManager: instance of manager to customize view
    public init(dropInViewStyleManager: DropInViewStyleManager?, darkModekStyleManager: DropInViewStyleManager?) {
        self.dropInViewStyleManager = dropInViewStyleManager
        darkModeDropInStyleManager = darkModekStyleManager
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Functions

    /// Change scroll view insets
    func adjustContentInsets(_ contentInsets: UIEdgeInsets) {
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    private func customizeView(dropInViewStyleManager: DropInViewStyleManager?) {
        backgroundColor = dropInViewStyleManager?.backgroundColor ?? .white
        if let spacingBetweenInputViews = dropInViewStyleManager?.spacingBetweenInputViews {
            self.spacingBetweenInputViews = spacingBetweenInputViews
        }
        if let insets = dropInViewStyleManager?.insets {
            self.insets = insets
        }
        buildStackViewConstraints()
    }

    private func buildStackViewConstraints() {
        if let top = stackContainer.constraint(withIdentifier: stackViewTopConstraint) {
            top.isActive = false
        }

        if let bottom = stackContainer.constraint(withIdentifier: stackViewBottomConstraint) {
            bottom.isActive = false
        }

        if let leading = stackContainer.constraint(withIdentifier: stackViewLeadingConstraint) {
            leading.isActive = false
        }

        if let trailing = stackContainer.constraint(withIdentifier: stackViewTrailingConstraint) {
            trailing.isActive = false
        }

        stackView.addConstraints([
            equal(stackContainer, \.topAnchor, \.topAnchor, constant: insets.top, identifier: stackViewTopConstraint),
            equal(stackContainer, \.bottomAnchor, \.bottomAnchor, constant: insets.bottom, identifier: stackViewBottomConstraint),
            equal(stackContainer, \.leadingAnchor, \.leadingAnchor, constant: insets.left, identifier: stackViewLeadingConstraint),
            equal(stackContainer, \.trailingAnchor, \.trailingAnchor, constant: insets.right, identifier: stackViewTrailingConstraint)
        ])
    }
}

extension AddCardView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        cardNumberInput.cardNumberInputViewDelegate = self
        cardNumberInput.delegate = self
        cvvInput.delegate = self
        expiryDateInput.delegate = self

        var styleManager = dropInViewStyleManager
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                styleManager = darkModeDropInStyleManager
            }
        }
        customizeView(dropInViewStyleManager: styleManager)
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        stackContainer.addSubview(stackView)
        scrollView.addSubview(stackContainer)
        addSubviews([scrollView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        scrollView.addConstraints([
            equal(self, \.topAnchor, \.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(self, \.bottomAnchor, \.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            equal(self, \.leadingAnchor, constant: 0),
            equal(self, \.trailingAnchor, constant: 0)
        ])

        stackContainer.addConstraints(equalToSuperview(with: .init(top: 0, left: 0, bottom: 0, right: 0), usingSafeArea: false))

        stackContainer.addConstraints([
            equal(self, \.widthAnchor, to: \.widthAnchor, constant: 0.0)
        ])

        buildStackViewConstraints()
    }
}

extension AddCardView: CardNumberInputViewDelegate {
    func cardNumberInputViewDidComplete(_ cardNumberInputView: CardNumberInputView) {
        cvvInput.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }

    func cardNumberInputViewDidChangeText(_ cardNumberInputView: CardNumberInputView) {
        cvvInput.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }
}

extension AddCardView: SecureFormInputViewDelegate {
    func inputViewTextFieldDidEndEditing(_: SecureFormInputView) {}

    func showHideError(_: Bool) {
        addCardButton.isEnabled = isFormValid
    }
}
