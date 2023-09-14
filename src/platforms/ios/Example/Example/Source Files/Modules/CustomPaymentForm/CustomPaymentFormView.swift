//
//  CustomPaymentFormView.swift
//  Example
//

import UIKit

final class CustomPaymentFormView: BaseView {
    var isFormValid: Bool {
        cardNumberInput.isInputValid && expiryDateInput.isInputValid && cvvInput.isInputValid
    }

    var payButtonTappedClosure: (() -> Void)? {
        get { payButton.onTap }
        set { payButton.onTap = newValue }
    }

    var zipButtonTappedClosure: (() -> Void)? {
        get { zipButton.onTap }
        set { zipButton.onTap = newValue }
    }
    
    var ataButtonTappedClosure: (() -> Void)? {
        get { ataButton.onTap }
        set { ataButton.onTap = newValue }
    }

    private(set) lazy var cardNumberInput: CardNumberInputView = {
        let inputView = CardNumberInputView()
        inputView.highlightIfNeeded()
        return inputView
    }()

    private(set) lazy var expiryDateInput: ExpiryDateInputView = {
        let inputView = ExpiryDateInputView()
        inputView.highlightIfNeeded()
        return inputView
    }()

    private(set) lazy var cvvInput: CVVInputView = {
        let inputView = CVVInputView()
        inputView.highlightIfNeeded()
        return inputView
    }()

    private lazy var horizontalInputsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [expiryDateInput, cvvInput])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        return stackView
    }()

    private(set) lazy var payButton: PayButton = {
        let button = PayButton()
        button.highlightIfNeeded()
        return button
    }()

    private(set) lazy var zipButton: ZIPButton = {
        let green = UIColor(red: 14 / 255, green: 125 / 255, blue: 124 / 255, alpha: 1.0)
        let lightStyleManager = ZIPButtonStyleManager(logoTheme: .light, backgroundColor: green, borderColor: .clear, borderWith: 0, spinnerStyle: .white, spinnerColor: .red, contentHeightMargins: HeightMargins(top: 5, bottom: 5), cornerRadius: 10)
        let button = ZIPButton(styleManager: lightStyleManager, darkModeStyleManager: nil)
        return button
    }()
    
    private(set) lazy var ataButton: ATAButton = {
        let button = ATAButton()
        button.highlightIfNeeded()
        return button
    }()

    private let stackContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardNumberInput, horizontalInputsStackView, payButton, zipButton, ataButton])
        stackView.axis = .vertical
        stackView.spacing = 15
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

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    override public init() {
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
}

extension CustomPaymentFormView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.setupProperties
    func setupProperties() {
        let mainColor = UIColor(light: .black, dark: .white)
        backgroundColor = UIColor(light: .white, dark: .black)
        cardNumberInput.cardNumberInputViewDelegate = self
        cardNumberInput.delegate = self
        cvvInput.delegate = self
        expiryDateInput.delegate = self

        cardNumberInput.titleColor = mainColor
        expiryDateInput.titleColor = mainColor
        cvvInput.titleColor = mainColor

        cardNumberInput.textFieldImageColor = mainColor
        expiryDateInput.textFieldImageColor = mainColor
        cvvInput.textFieldImageColor = mainColor

        cardNumberInput.textColor = mainColor
        expiryDateInput.textColor = mainColor
        cvvInput.textColor = mainColor

        let errorColor = UIColor(red: 29 / 255, green: 118 / 255, blue: 118 / 255, alpha: 1.0)
        cardNumberInput.errorColor = errorColor
        expiryDateInput.errorColor = errorColor
        cvvInput.errorColor = errorColor

        let borderWidth: CGFloat = 3
        cardNumberInput.textFieldBorderWidth = borderWidth
        expiryDateInput.textFieldBorderWidth = borderWidth
        cvvInput.textFieldBorderWidth = borderWidth

        let payButtonColor = UIColor(red: 14 / 255, green: 125 / 255, blue: 124 / 255, alpha: 1.0)
        payButton.disabledBackgroundColor = payButtonColor.withAlphaComponent(0.7)
        payButton.enabledBackgroundColor = payButtonColor
        payButton.isEnabled = false
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

        stackView.addConstraints([
            equal(stackContainer, \.topAnchor, \.topAnchor, constant: 15),
            equal(stackContainer, \.bottomAnchor, \.bottomAnchor, constant: -15),
            equal(stackContainer, \.leadingAnchor, \.leadingAnchor, constant: 15),
            equal(stackContainer, \.trailingAnchor, \.trailingAnchor, constant: -15)
        ])
    }
}

extension CustomPaymentFormView: CardNumberInputViewDelegate {
    func cardNumberInputViewDidComplete(_ cardNumberInputView: CardNumberInputView) {
        cvvInput.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }

    func cardNumberInputViewDidChangeText(_ cardNumberInputView: CardNumberInputView) {
        cvvInput.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }
}

extension CustomPaymentFormView: SecureFormInputViewDelegate {
    func inputViewTextFieldDidEndEditing(_: SecureFormInputView) {}

    func showHideError(_: Bool) {
        payButton.isEnabled = isFormValid
    }
}
