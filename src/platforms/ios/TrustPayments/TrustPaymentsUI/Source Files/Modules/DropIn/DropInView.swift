//
//  DropInView.swift
//  TrustPaymentsUI
//

import UIKit

@objc open class DropInView: BaseView, DropInViewProtocol {
    @objc open var isFormValid: Bool {
        // Do not validate fields that are not added to the view's hierarchy, for example by specifying visible fields
        let inputsToValidate = [cardNumberInput, expiryDateInput, cvvInput].filter { ($0 as? UIView)?.isHidden == false }
        return (inputsToValidate.count == inputsToValidate.filter(\.isInputValid).count) && (additionalFieldsToValidate.count == additionalFieldsToValidate.filter(\.isInputValid).count)
    }

    /// Your custom fields, like shipping address, that needs to be also validated before proceeding with transaction.
    @objc public var additionalFieldsToValidate: [InputValidation] = []

    /// Closure triggered before processing transaction. Update the JWT if needed.
    @objc public var payButtonTappedClosure: (() -> Void)? {
        get { payButton.onTap }
        set { payButton.onTap = newValue }
    }

    /// Closure triggered before Apple Pay authorisation.
    @objc public var applePayButtonTappedClosure: (() -> Void)? {
        get { applePayButton?.buttonTappedClosure }
        set { applePayButton?.buttonTappedClosure = newValue }
    }

    /// Closure triggered before processing ZIP.
    @objc public var zipButtonTappedClosure: (() -> Void)? {
        get { zipButton.onTap }
        set { zipButton.onTap = newValue }
    }
    
    /// Closure triggered before processing ATA.
    @objc public var ataButtonTappedClosure: (() -> Void)? {
        get { ataButton.onTap }
        set { ataButton.onTap = newValue }
    }

    @objc public private(set) lazy var cardNumberInput: CardNumberInput = CardNumberInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)

    @objc public private(set) lazy var expiryDateInput: ExpiryDateInput = ExpiryDateInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)

    @objc public private(set) lazy var cvvInput: CVVInput = CVVInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)

    @objc public private(set) lazy var payButton: PayButtonProtocol = {
        let styleManager = dropInViewStyleManager?.requestButtonStyleManager as? PayButtonStyleManager
        let darkModeStyleManager = dropInViewDarkModeStyleManager?.requestButtonStyleManager as? PayButtonStyleManager
        return PayButton(payButtonStyleManager: styleManager, payButtonDarkModeStyleManager: darkModeStyleManager)
    }()

    @objc public private(set) lazy var zipButton: ZipButtonProtocol = {
        let styleManager = dropInViewStyleManager?.zipButtonStyleManager
        let darkModeStyleManager = dropInViewDarkModeStyleManager?.zipButtonStyleManager
        return ZIPButton(styleManager: styleManager, darkModeStyleManager: darkModeStyleManager)
    }()
    
    @objc public private(set) lazy var ataButton: ATAButtonProtocol = {
        let styleManager = dropInViewStyleManager?.ataButtonStyleManager
        let darkModeStyleManager = dropInViewDarkModeStyleManager?.ataButtonStyleManager
        return ATAButton(styleManager: styleManager, darkModeStyleManager: darkModeStyleManager)
    }()

    /// Add Apple Pay button above Pay button if exists otherwise insert at the bottom
    var applePayButton: ApplePayButton? {
        didSet {
            guard let button = applePayButton else { return }
            if let payButtonIndex = stackView.arrangedSubviews.firstIndex(where: { $0 is PayButton }) {
                stackView.insertArrangedSubview(button, at: payButtonIndex)
            } else {
                stackView.addArrangedSubview(button)
            }
        }
    }
    
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom

    private let stackContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    @objc public lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardNumberInput, expiryDateInput, cvvInput, payButton, zipButton, ataButton])
        stackView.axis = .vertical
        stackView.spacing = spacingBetweenInputViews
        stackView.alignment = .fill
        stackView.distribution = .fill
        if deviceIdiom == .pad {
            let fixedSizeView = UIView()
            fixedSizeView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(fixedSizeView)

            NSLayoutConstraint.activate([
                fixedSizeView.widthAnchor.constraint(equalToConstant: (UIApplication.shared.keyWindow?.rootViewController?.view.frame.size.width ?? UIScreen.main.bounds.size.width) / 2),
                fixedSizeView.heightAnchor.constraint(equalToConstant: (UIApplication.shared.keyWindow?.rootViewController?.view.frame.size.height ?? UIScreen.main.bounds.size.height) / 2)
            ])
        }
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
    private let stackViewCenterXConstraint = "stackViewCenterXConstraint"
    private let stackViewCenterYConstraint = "stackViewCenterYConstraint"

    @objc public let dropInViewStyleManager: DropInViewStyleManager?
    @objc public let dropInViewDarkModeStyleManager: DropInViewStyleManager?

    /// Vertical spacing between input components.
    @objc public var spacingBetweenInputViews: CGFloat = 30 {
        didSet {
            stackView.spacing = spacingBetweenInputViews
        }
    }

    /// Insets between main view bounds and UI components.
    @objc public var insets = UIEdgeInsets(top: 15, left: 30, bottom: -15, right: -30) {
        didSet {
            buildStackViewConstraints()
        }
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - dropInViewStyleManager: instance of manager to customize view
    ///   - dropInViewDarkModeStyleManager: instance of dark mode manager to customize view
    @objc public init(dropInViewStyleManager: DropInViewStyleManager?, dropInViewDarkModeStyleManager: DropInViewStyleManager?) {
        self.dropInViewStyleManager = dropInViewStyleManager
        self.dropInViewDarkModeStyleManager = dropInViewDarkModeStyleManager
        super.init()
    }

    public required init?(coder _: NSCoder) {
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

        if deviceIdiom == .pad {
            stackView.addConstraints([
                equal(stackContainer, \.topAnchor, \.topAnchor, constant: insets.top, identifier: stackViewTopConstraint),
                equal(stackContainer, \.bottomAnchor, \.bottomAnchor, constant: insets.bottom, identifier: stackViewBottomConstraint),
                equal(stackContainer, \.centerXAnchor, \.centerXAnchor, constant: 0, identifier: stackViewCenterXConstraint),
                equal(stackContainer, \.centerYAnchor, \.centerYAnchor, constant: 0, identifier: stackViewCenterYConstraint)
            ])
        } else {
            stackView.addConstraints([
                equal(stackContainer, \.topAnchor, \.topAnchor, constant: insets.top, identifier: stackViewTopConstraint),
                equal(stackContainer, \.bottomAnchor, \.bottomAnchor, constant: insets.bottom, identifier: stackViewBottomConstraint),
                equal(stackContainer, \.leadingAnchor, \.leadingAnchor, constant: insets.left, identifier: stackViewLeadingConstraint),
                equal(stackContainer, \.trailingAnchor, \.trailingAnchor, constant: insets.right, identifier: stackViewTrailingConstraint)
            ])
        }
    }
}

extension DropInView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.customizeView
    @objc open func customizeView() {
        var styleManager: DropInViewStyleManager!
        if #available(iOS 12.0, *) {
            styleManager = traitCollection.userInterfaceStyle == .dark && dropInViewDarkModeStyleManager != nil ? dropInViewDarkModeStyleManager : dropInViewStyleManager
        } else {
            styleManager = dropInViewStyleManager
        }
        customizeView(dropInViewStyleManager: styleManager)
    }

    /// - SeeAlso: ViewSetupable.setupProperties
    @objc open func setupProperties() {
        (cardNumberInput as? CardNumberInputView)?.cardNumberInputViewDelegate = self
        (cardNumberInput as? CardNumberInputView)?.delegate = self
        (cvvInput as? CVVInputView)?.delegate = self
        (expiryDateInput as? ExpiryDateInputView)?.delegate = self
    }

    public func setupView(callback: ((UIView) -> Void)?) {
        // Setting custom properties
        callback?(self)
        // Finished setting custom properties
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    @objc open func setupViewHierarchy() {
        stackContainer.addSubview(stackView)
        scrollView.addSubview(stackContainer)
        addSubviews([scrollView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    @objc open func setupConstraints() {
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

extension DropInView: CardNumberInputViewDelegate {
    public func cardNumberInputViewDidComplete(_ cardNumberInputView: CardNumberInputView) {
        (cvvInput as? CVVInputView)?.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }

    public func cardNumberInputViewDidChangeText(_ cardNumberInputView: CardNumberInputView) {
        (cvvInput as? CVVInputView)?.cardType = cardNumberInputView.cardType
        cvvInput.isEnabled = cardNumberInputView.isCVVRequired
    }
}

extension DropInView: SecureFormInputViewDelegate {
    public func inputViewTextFieldDidEndEditing(_: SecureFormInputView) {}

    public func showHideError(_: Bool) {
        payButton.isEnabled = isFormValid
    }
}
