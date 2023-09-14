//
//  ExpiryDateInputView.swift
//  TrustPaymentsUI
//

#if !COCOAPODS
    import TrustPaymentsCard
    import TrustPaymentsCore
#endif

import UIKit

class ExpiryDateTextField: BackwardTextField {}

class ExpiryDatePicker: UIPickerView {}

/// Expiry date  input view.
///
/// Validates provided date via CardValidator from Card module.
///
/// Works as a stand alone view and requires CardValidator from Card module. Can be used to build your own Pay form.
@objc public class ExpiryDateInputView: BaseView, SecureFormInputView, ExpiryDateInput {
    // MARK: Properties

    let expiryDatePickerMonthData = [LocalizableKeys.ExpiryDatePickerView.month.localizedStringOrEmpty, "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var currentMonth = 0
    var pickerYearData: [String] = [LocalizableKeys.ExpiryDatePickerView.year.localizedStringOrEmpty]
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow + 2, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh - 2, for: .horizontal)
        return label
    }()

    let asterixLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "*"
        label.textColor = .red
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, asterixLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private let textFieldImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    let expiryDateTextField: ExpiryDateTextField = {
        let textField = ExpiryDateTextField()
        textField.autocorrectionType = .no
        textField.textAlignment = .center
        return textField
    }()
    
    var expiryDateDatePicker: ExpiryDatePicker = {
        let datePicker = ExpiryDatePicker()
        datePicker.backgroundColor = UIColor.lightGray
        return datePicker
    }()
    
    private lazy var textFieldStackViewBackground: UIView = {
        let view = UIView()
        view.backgroundColor = textFieldBackgroundColor
        view.layer.cornerRadius = textFieldCornerRadius
        view.layer.borderWidth = textFieldBorderWidth
        view.layer.borderColor = textFieldBorderColor.cgColor
        return view
    }()

    private let textFieldInternalStackViewContainer: UIView = UIView()

    private lazy var textFieldInternalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [expiryDateTextField])
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textFieldImageView, textFieldInternalStackViewContainer])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: textFieldHeightMargins.top, left: 10, bottom: textFieldHeightMargins.bottom, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, textFieldStackView, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private var placeholderPrivate: String = "MM/YY"
    private var seperatorText: String = "/"

    private let tFieldStViewLeadingEqualConstraint = "tFieldStViewLeadingEqualConstraint"
    private let tFieldStViewTrailingEqualConstraint = "tFieldStViewTrailingEqualConstraint"
    private let tFieldStViewLeadingGreaterConstraint = "tFieldStViewLeadingGreaterConstraint"
    private let tFieldStViewTrailingLessConstraint = "tFieldStViewTrailingLessConstraint"
    private let tFieldStViewCenterXConstraint = "tFieldStViewCenterXConstraint"
    private let tFieldStSeparatorWidthConstraint = "tFieldStSeparatorWidthConstraint"

    private var hasStartedExpiryDateEditing = false

    let inputViewStyleManager: InputViewStyleManager?
    let inputViewDarkModeStyleManager: InputViewStyleManager?

    // MARK: Public properties

    @objc public var expiryDate: ExpiryDate {
        ExpiryDate(rawValue: text ?? .empty)
    }

    @objc public weak var delegate: SecureFormInputViewDelegate?

    @objc public var isEnabled: Bool = true {
        didSet {
            expiryDateTextField.isEnabled = isEnabled
            if isEnabled {
                alpha = 1.0
            } else {
                alpha = 0.4
                expiryDateTextField.text = .empty
                showHideError(show: false)
            }
        }
    }

    @objc public var isFieldRequired: Bool = true {
        didSet {
            asterixLabel.isHidden = !isFieldRequired
        }
    }

    @objc public var isEmpty: Bool {
        expiryDateTextField.text?.isEmpty ?? true || expiryDateTextField.text == UITextField.emptyCharacter
    }

    @objc public var isInputValid: Bool {
        CardValidator.isExpirationDateValid(date: expiryDate.rawValue, separator: seperatorText)
    }

    @objc public var isSecuredTextEntry: Bool = false {
        didSet {
            expiryDateTextField.isSecureTextEntry = isSecuredTextEntry
        }
    }

    @objc public var keyboardType: UIKeyboardType = .default

    @objc public var keyboardAppearance: UIKeyboardAppearance = .default

    @objc public var textFieldTextAligment: NSTextAlignment = .left {
        didSet {
            rebuildTextFieldInternalStackViewConstraints()

            let leadingEqualConstraint = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewLeadingEqualConstraint)
            let trailingEqualConstraint = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewTrailingEqualConstraint)
            let leadingGreaterConstraint = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewLeadingGreaterConstraint)
            let trailingLessConstraint = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewTrailingLessConstraint)
            let centerXConstraint = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewCenterXConstraint)

            switch textFieldTextAligment {
            case .center, .natural:
                leadingEqualConstraint?.isActive = false
                leadingGreaterConstraint?.isActive = true
                trailingEqualConstraint?.isActive = false
                trailingLessConstraint?.isActive = true
                centerXConstraint?.isActive = true
            case .left, .justified:
                leadingEqualConstraint?.isActive = true
                leadingGreaterConstraint?.isActive = false
                trailingEqualConstraint?.isActive = false
                trailingLessConstraint?.isActive = true
                centerXConstraint?.isActive = false
            case .right:
                leadingEqualConstraint?.isActive = false
                leadingGreaterConstraint?.isActive = true
                trailingEqualConstraint?.isActive = true
                trailingLessConstraint?.isActive = false
                centerXConstraint?.isActive = false
            @unknown default:
                return
            }
        }
    }

    // MARK: - texts

    @objc public var title: String = "default" {
        didSet {
            titleLabel.text = title
        }
    }

    @objc public var text: String? {
        get {
            let text = "\(expiryDateTextField.text ?? .empty)"
            if text != seperatorText {
                return text
            }
            return nil
        }
        set {
            expiryDateTextField.text = newValue
        }
    }

    @objc public var placeholder: String {
        get {
            placeholderPrivate
        }
        set {
            updatePlaceholder(current: newValue)
            placeholderPrivate = newValue
        }
    }

    @objc public var error: String = "error" {
        didSet {
            errorLabel.text = error
        }
    }

    @objc public var emptyError: String = "empty error" {
        didSet {
            errorLabel.text = error
        }
    }

    // MARK: - colors

    @objc public var titleColor: UIColor = .black {
        didSet {
            titleLabel.textColor = titleColor
        }
    }

    @objc public var textFieldBorderColor = UIColor.lightGray.withAlphaComponent(0.6) {
        didSet {
            textFieldStackViewBackground.layer.borderColor = textFieldBorderColor.cgColor
        }
    }

    @objc public var textFieldBackgroundColor = UIColor.lightGray.withAlphaComponent(0.2) {
        didSet {
            textFieldStackViewBackground.backgroundColor = textFieldBackgroundColor
        }
    }

    @objc public var textColor: UIColor = .black {
        didSet {
            expiryDateTextField.textColor = textColor
        }
    }

    @objc public var placeholderColor: UIColor = .lightGray {
        didSet {
            updatePlaceholder(current: placeholderPrivate)
        }
    }

    @objc public var errorColor: UIColor = .red {
        didSet {
            errorLabel.textColor = errorColor
        }
    }

    @objc public var textFieldImageColor: UIColor = .black {
        didSet {
            textFieldImageView.setImageColor(color: textFieldImageColor)
        }
    }

    // MARK: - fonts

    @objc public var titleFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            titleLabel.font = titleFont
            asterixLabel.font = titleFont
        }
    }

    @objc public var textFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            expiryDateTextField.font = textFont
        }
    }

    @objc public var placeholderFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            updatePlaceholder(current: placeholderPrivate)
        }
    }

    @objc public var errorFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            errorLabel.font = errorFont
        }
    }

    // MARK: - images

    @objc public var textFieldImage: UIImage? {
        didSet {
            textFieldImageView.image = textFieldImage
            textFieldImageView.setImageColor(color: textFieldImageColor)
        }
    }

    // MARK: - spacing/sizes

    @objc public var titleSpacing: CGFloat = 5 {
        didSet {
            stackView.setCustomSpacing(titleSpacing, after: titleStackView)
        }
    }

    @objc public var errorSpacing: CGFloat = 5 {
        didSet {
            stackView.setCustomSpacing(errorSpacing, after: textFieldStackView)
        }
    }

    @objc public var textFieldBorderWidth: CGFloat = 2 {
        didSet {
            textFieldStackViewBackground.layer.borderWidth = textFieldBorderWidth
        }
    }

    @objc public var textFieldCornerRadius: CGFloat = 5 {
        didSet {
            textFieldStackViewBackground.layer.cornerRadius = textFieldCornerRadius
        }
    }

    @objc public var textFieldHeightMargins = HeightMargins(top: 25, bottom: 25) {
        didSet {
            textFieldStackView.layoutMargins = UIEdgeInsets(top: textFieldHeightMargins.top, left: 5, bottom: textFieldHeightMargins.bottom, right: 5)
        }
    }

    // MARK: Initialization

    /// Initializes an instance of the receiver.
    /// - Parameters:
    ///   - inputViewStyleManager: instance of manager to customize view
    @objc public init(inputViewStyleManager: InputViewStyleManager? = nil, inputViewDarkModeStyleManager: InputViewStyleManager? = nil) {
        self.inputViewStyleManager = inputViewStyleManager
        self.inputViewDarkModeStyleManager = inputViewDarkModeStyleManager
        let date = Date()
        let calendar = Calendar.current
        currentMonth = calendar.component(.month, from: date)
        var year = calendar.component(.year, from: date)
        for _ in 0 ..< 10 {
            pickerYearData += [String(year)]
            year += 1
        }
        super.init()
        accessibilityIdentifier = "st-expiration-date-input"
        expiryDateTextField.accessibilityIdentifier = "st-expiration-date-input-textfield"
        expiryDateDatePicker.accessibilityIdentifier = "st-expiration-date-picker"
        errorLabel.accessibilityIdentifier = "st-expiration-date-message"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Functions

    private func updatePlaceholder(current: String) {
        expiryDateTextField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: placeholderColor, NSAttributedString.Key.font: placeholderFont])
    }

    private func rebuildTextFieldInternalStackViewConstraints() {
        if let leadingEqual = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewLeadingEqualConstraint) {
            leadingEqual.isActive = false
        }

        if let trailingEqual = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewTrailingEqualConstraint) {
            trailingEqual.isActive = false
        }

        if let leadingGreater = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewLeadingGreaterConstraint) {
            leadingGreater.isActive = false
        }

        if let trailingLess = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewTrailingLessConstraint) {
            trailingLess.isActive = false
        }

        if let centerX = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewCenterXConstraint) {
            centerX.isActive = false
        }

        textFieldInternalStackView.addConstraints([
            equal(textFieldInternalStackViewContainer, \.leadingAnchor, \.leadingAnchor, greaterOrEqual: 0, identifier: tFieldStViewLeadingGreaterConstraint),
            equal(textFieldInternalStackViewContainer, \.trailingAnchor, \.trailingAnchor, lessOrEqual: 0, identifier: tFieldStViewTrailingLessConstraint),
            equal(textFieldInternalStackViewContainer, \.leadingAnchor, \.leadingAnchor, constant: 0, identifier: tFieldStViewLeadingEqualConstraint),
            equal(textFieldInternalStackViewContainer, \.trailingAnchor, \.trailingAnchor, constant: 0, identifier: tFieldStViewTrailingEqualConstraint),
            equal(textFieldInternalStackViewContainer, \.centerXAnchor, \.centerXAnchor, constant: 0, identifier: tFieldStViewCenterXConstraint)
        ])
    }

    @objc public func showHideError(show: Bool) {
        errorLabel.text = isEmpty ? emptyError : error
        errorLabel.isHidden = !show
        textFieldStackViewBackground.layer.borderColor = show ? errorColor.cgColor : textFieldBorderColor.cgColor
        textFieldStackViewBackground.backgroundColor = show ? errorColor.withAlphaComponent(0.1) : textFieldBackgroundColor
        delegate?.showHideError(show)
    }

    // MARK: - Validation

    @discardableResult
    @objc public func validate(silent: Bool) -> Bool {
        validate(silent: silent, hideError: false)
    }

    @discardableResult
    @objc public func validate(silent: Bool, hideError: Bool = false) -> Bool {
        let result = isInputValid
        if silent == false {
            showHideError(show: !result)
        }

        if result, hideError {
            showHideError(show: false)
        }
        return result
    }
}

extension ExpiryDateInputView: ViewSetupable {
    /// - SeeAlso: ViewSetupable.customizeView
    @objc func customizeView() {
        var styleManager: InputViewStyleManager!
        if #available(iOS 12.0, *) {
            styleManager = traitCollection.userInterfaceStyle == .dark && inputViewDarkModeStyleManager != nil ? inputViewDarkModeStyleManager : inputViewStyleManager
        } else {
            styleManager = inputViewStyleManager
        }
        customizeView(inputViewStyleManager: styleManager)
    }

    /// - SeeAlso: ViewSetupable.setupProperties
    @objc func setupProperties() {
        backgroundColor = .clear

        expiryDateTextField.delegate = self
        
        expiryDateDatePicker.delegate = self
        expiryDateDatePicker.dataSource = self
        
        expiryDateTextField.inputAccessoryView = expiryDateDatePicker

        titleLabel.textColor = titleColor
        titleLabel.font = titleFont
        asterixLabel.font = titleFont

        expiryDateTextField.text = text
        expiryDateTextField.textColor = textColor
        expiryDateTextField.font = textFont

        errorLabel.textColor = errorColor
        errorLabel.font = errorFont

        title = LocalizableKeys.ExpiryDateInputView.title.localizedStringOrEmpty
        placeholder = LocalizableKeys.ExpiryDateInputView.placeholder.localizedStringOrEmpty
        error = LocalizableKeys.ExpiryDateInputView.error.localizedStringOrEmpty
        emptyError = LocalizableKeys.ExpiryDateInputView.emptyError.localizedStringOrEmpty

        keyboardType = .numberPad

        textFieldTextAligment = .center

        textFieldImage = UIImage(named: "calendar", in: Bundle(for: CVVInputView.self), compatibleWith: nil)

        stackView.setCustomSpacing(titleSpacing, after: titleStackView)
        stackView.setCustomSpacing(errorSpacing, after: textFieldStackView)

        textFieldImageView.setImageColor(color: textFieldImageColor)

        isEnabled = true
        asterixLabel.isHidden = !isFieldRequired
    }

    /// - SeeAlso: ViewSetupable.setupViewHierarchy
    func setupViewHierarchy() {
        textFieldStackViewBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textFieldStackView.insertSubview(textFieldStackViewBackground, at: 0)
        textFieldInternalStackViewContainer.addSubview(textFieldInternalStackView)
        addSubviews([stackView])
    }

    /// - SeeAlso: ViewSetupable.setupConstraints
    func setupConstraints() {
        textFieldImageView.addConstraints([
            equal(\.widthAnchor, to: 30),
            equal(\.heightAnchor, to: 33)
        ])
        textFieldInternalStackView.addConstraints([
            equal(textFieldInternalStackViewContainer, \.topAnchor),
            equal(textFieldInternalStackViewContainer, \.bottomAnchor),
            equal(textFieldInternalStackViewContainer, \.leadingAnchor),
            equal(textFieldInternalStackViewContainer, \.trailingAnchor)
        ])

        rebuildTextFieldInternalStackViewConstraints()

        if let leadingEqual = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewLeadingEqualConstraint) {
            leadingEqual.isActive = false
        }

        if let trailingEqual = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewTrailingEqualConstraint) {
            trailingEqual.isActive = false
        }

        if let leadingGreater = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewLeadingGreaterConstraint) {
            leadingGreater.isActive = true
        }

        if let trailingLess = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewTrailingLessConstraint) {
            trailingLess.isActive = true
        }

        if let centerX = textFieldInternalStackViewContainer.constraint(withIdentifier: tFieldStViewCenterXConstraint) {
            centerX.isActive = true
        }

        stackView.addConstraints(equalToSuperview(with: .init(top: 0, left: 0, bottom: 0, right: 0), usingSafeArea: false))
    }
}

// MARK: PickerView delegate

extension ExpiryDateInputView: UIPickerViewDelegate, UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return expiryDatePickerMonthData.count
        } else {
            return pickerYearData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        if component == 0 {
            return expiryDatePickerMonthData[row]
        } else {
            return pickerYearData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            pickerView.selectRow(row + 1, inComponent: component, animated: false)
        }
        if pickerView.selectedRow(inComponent: 0) < currentMonth, pickerView.selectedRow(inComponent: 1) == 1 {
            pickerView.selectRow(currentMonth, inComponent: 0, animated: false)
        }
        if pickerView.selectedRow(inComponent: 0) != 0, pickerView.selectedRow(inComponent: 1) != 0 {
            let expiryYearValue = Int(pickerYearData[pickerView.selectedRow(inComponent: 1)])! - 2000
            let expiryYear = String(expiryYearValue)
            let expireDate: String = expiryDatePickerMonthData[pickerView.selectedRow(inComponent: 0)] + seperatorText + expiryYear
            expiryDateTextField.text = expireDate
        }
    }
}

// MARK: TextField delegate

extension ExpiryDateInputView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        hasStartedExpiryDateEditing = textField is ExpiryDateTextField ? true : hasStartedExpiryDateEditing
        if (textField.text ?? .empty).isEmpty || textField is ExpiryDateTextField {
            textField.text = UITextField.emptyCharacter
        }
        let inputView = UIView(frame: .zero)
        inputView.isOpaque = false
        textField.inputView = inputView
    }

    public func textFieldDidEndEditing(_: UITextField) {
        if hasStartedExpiryDateEditing {
            validate(silent: false)
        }
        delegate?.inputViewTextFieldDidEndEditing(self)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }
}
