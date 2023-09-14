//
//  DropInCustomViewWithPayloadParameters.swift
//  Example
//

import UIKit

final class UserDataInputView: DefaultSecureFormInputView {
    var maximumInputLength: Int = 127

    weak var relatedInput: DefaultSecureFormInputView?

    override var isInputValid: Bool {
        guard let relatedInput = relatedInput, !relatedInput.isEmpty else { return true }
        guard let text = text, !text.isEmpty else { return false }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text ?? .empty).replacingCharacters(in: range, with: string)

        let index = newText.index(newText.startIndex, offsetBy: min(maximumInputLength, newText.count))
        let currentTextFieldText = String(newText[..<index])

        textField.text = currentTextFieldText

        if isInputValid {
            showHideError(show: false)
        }

        if relatedInput?.isInputValid ?? false {
            relatedInput?.showHideError(show: false)
        }

        return false
    }
}

final class UserNameDataInputView: DefaultSecureFormInputView {
    let maximumInputLength: Int = 127

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text ?? .empty).replacingCharacters(in: range, with: string)

        let firstNameCount = newText.components(separatedBy: " ").first?.count ?? 0
        let length = newText.contains(" ") ? firstNameCount + maximumInputLength + 1 : maximumInputLength
        let index = newText.index(newText.startIndex, offsetBy: min(length, newText.count))
        let currentTextFieldText = String(newText[..<index])

        textField.text = currentTextFieldText

        return false
    }
}

final class AmountInputView: DefaultSecureFormInputView {
    var selectedAmountType: AmountType = .baseAmount

    var isDecimalOrInteger: Bool {
        switch selectedAmountType {
        case .baseAmount:
            return text?.isInteger ?? false
        case .mainAmount:
            return text?.isDecimal ?? false
        }
    }

    var maximumInputLength: Int {
        switch selectedAmountType {
        case .baseAmount:
            return 13
        case .mainAmount:
            return 14
        }
    }

    override var isInputValid: Bool {
        guard let text = text, !text.isEmpty, isDecimalOrInteger else { return false }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text ?? .empty).replacingCharacters(in: range, with: string)

        if !newText.isEmpty {
            switch selectedAmountType {
            case .baseAmount:
                if !newText.isInteger {
                    return false
                }
            case .mainAmount:
                if !newText.isDecimal {
                    return false
                }
            }
        }

        let index = newText.index(newText.startIndex, offsetBy: min(maximumInputLength, newText.count))
        let currentTextFieldText = String(newText[..<index])

        textField.text = currentTextFieldText

        if isInputValid {
            showHideError(show: false)
        }

        return false
    }

    /// - SeeAlso: SecureFormInputView.setupProperties
    override public func setupProperties() {
        super.setupProperties()

        error = Localizable.DropInCustomViewWithPayloadParameters.amountInputViewError.text
        emptyError = Localizable.DropInCustomViewWithPayloadParameters.amountInputViewEmptyError.text

        keyboardType = .decimalPad

        textFieldTextAligment = .center
        title = Localizable.DropInCustomViewWithPayloadParameters.amountInputViewTitle.text
        isFieldRequired = true
        placeholder = Localizable.DropInCustomViewWithPayloadParameters.amountInputViewPlaceholder.text
    }
}

final class CountryIsoInputView: DefaultSecureFormInputView {
    weak var relatedInput: DefaultSecureFormInputView?

    var maximumInputLength: Int {
        2
    }

    override var isInputValid: Bool {
        guard let relatedInput = relatedInput, !relatedInput.isEmpty else {
            if text?.isEmpty ?? true {
                return true
            }
            return text?.count == 2 && text?.isAlphabetic ?? false
        }
        guard let text = text, text.count == 2, text.isAlphabetic else { return false }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text ?? .empty).replacingCharacters(in: range, with: string)

        if !newText.isEmpty, !newText.isAlphabetic {
            return false
        }

        let index = newText.index(newText.startIndex, offsetBy: min(maximumInputLength, newText.count))
        let currentTextFieldText = String(newText[..<index])

        textField.text = currentTextFieldText.uppercased()

        if isInputValid {
            showHideError(show: false)
        }

        if relatedInput?.isInputValid ?? false {
            relatedInput?.showHideError(show: false)
        }

        return false
    }
}

public enum AmountType: String, CaseIterable {
    case baseAmount = "baseamount"
    case mainAmount = "mainamount"
}

public enum CurrencyType: String, CaseIterable {
    case gbp = "GBP"
    case usd = "USD"
}

public final class DropInCustomViewWithPayloadParameters: DropInView {
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = Localizable.DropInCustomViewWithPayloadParameters.changeAmount.text
        return label
    }()

    private lazy var amountSwitch: UISegmentedControl = {
        let items = AmountType.allCases.map(\.rawValue)
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(amountSwitchAction(_:)), for: .valueChanged)
        return segmentedControl
    }()

    private lazy var amountInput: AmountInputView = {
        let input = AmountInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "amountInput"
        return input
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = Localizable.DropInCustomViewWithPayloadParameters.changeCurrency.text
        return label
    }()

    private let currencySwitch: UISegmentedControl = {
        let items = CurrencyType.allCases.map(\.rawValue)
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private lazy var amountStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amountLabel, amountSwitch, amountInput])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var currencytStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currencyLabel, currencySwitch])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private let container: UIView = UIView()

    private lazy var payloadStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amountStackView, currencytStackView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()

    private let billingDataLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = Localizable.DropInCustomViewWithPayloadParameters.billingData.text
        label.textAlignment = .center
        return label
    }()

    private lazy var billingName: UserNameDataInputView = {
        let input = UserNameDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "billingName"
        return input
    }()

    private lazy var billingAddress: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "billingStreet"
        return input
    }()

    private lazy var billingCity: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "billingCity"
        return input
    }()

    private lazy var billingZipCode: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "billingPostcode"
        return input
    }()

    private lazy var billingCounty: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "billingCounty"
        return input
    }()

    private lazy var billingCountryIso: CountryIsoInputView = {
        let input = CountryIsoInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "billingCountryIso"
        return input
    }()

    private lazy var billingDataStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [billingDataLabel, billingName, billingAddress, billingCity, billingZipCode, billingCounty, billingCountryIso])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()

    private let deliveryDataLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = Localizable.DropInCustomViewWithPayloadParameters.deliveryData.text
        label.textAlignment = .center
        return label
    }()

    private lazy var deliveryName: UserNameDataInputView = {
        let input = UserNameDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "deliveryName"
        return input
    }()

    private lazy var deliveryAddress: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "deliveryStreet"
        return input
    }()

    private lazy var deliveryCity: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "deliveryCity"
        return input
    }()

    private lazy var deliveryZipCode: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "deliveryPostcode"
        return input
    }()

    private lazy var deliveryCounty: UserDataInputView = {
        let input = UserDataInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "deliveryCounty"
        return input
    }()

    private lazy var deliveryCountryIso: CountryIsoInputView = {
        let input = CountryIsoInputView(inputViewStyleManager: dropInViewStyleManager?.inputViewStyleManager, inputViewDarkModeStyleManager: dropInViewDarkModeStyleManager?.inputViewStyleManager)
        input.textFieldAccessibilityIdentifier = "deliveryCountryIso"
        return input
    }()

    private lazy var deliveryDataStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [deliveryDataLabel, deliveryName, deliveryAddress, deliveryCity, deliveryZipCode, deliveryCounty, deliveryCountryIso])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()

    init(dropInViewStyleManager: DropInViewStyleManager?, dropInViewDarkModeStyleManager: DropInViewStyleManager?, baseAmount: Int) {
        super.init(dropInViewStyleManager: dropInViewStyleManager, dropInViewDarkModeStyleManager: dropInViewDarkModeStyleManager)
        amountInput.text = "\(baseAmount)"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public data

    public var selectedAmountType: AmountType {
        let title = amountSwitch.titleForSegment(at: amountSwitch.selectedSegmentIndex)!
        return AmountType(rawValue: title)!
    }

    public var selectedCurrentType: CurrencyType {
        let title = currencySwitch.titleForSegment(at: currencySwitch.selectedSegmentIndex)!
        return CurrencyType(rawValue: title)!
    }

    public var amountValue: String {
        amountInput.text ?? .empty
    }

    public var billingFirstNameValue: String? {
        guard let billingName = billingName.text, !billingName.isEmpty else { return nil }
        return billingName.components(separatedBy: " ").first
    }

    public var billingSecondNameValue: String? {
        guard let billingName = billingName.text, !billingName.isEmpty else { return nil }
        let components = billingName.components(separatedBy: " ")
        guard components.count > 1 else { return nil }
        return components.last
    }

    public var billingAddressValue: String? {
        guard let billingAddress = billingAddress.text, !billingAddress.isEmpty else { return nil }
        return billingAddress
    }

    public var billingCityValue: String? {
        guard let billingCity = billingCity.text, !billingCity.isEmpty else { return nil }
        return billingCity
    }

    public var billingZipCodeValue: String? {
        guard let billingZipCode = billingZipCode.text, !billingZipCode.isEmpty else { return nil }
        return billingZipCode
    }

    public var billingCountyValue: String? {
        guard let billingCounty = billingCounty.text, !billingCounty.isEmpty else { return nil }
        return billingCounty
    }

    public var billingCountryIsoValue: String? {
        guard let billingCountryIso = billingCountryIso.text, billingCountryIso.count == 2 else { return nil }
        return billingCountryIso
    }

    public var deliveryFirstNameValue: String? {
        guard let deliveryName = deliveryName.text, !deliveryName.isEmpty else { return nil }
        return deliveryName.components(separatedBy: " ").first
    }

    public var deliverySecondNameValue: String? {
        guard let deliveryName = deliveryName.text, !deliveryName.isEmpty else { return nil }
        let components = deliveryName.components(separatedBy: " ")
        guard components.count > 1 else { return nil }
        return components.last
    }

    public var deliveryAddressValue: String? {
        guard let deliveryAddress = deliveryAddress.text, !deliveryAddress.isEmpty else { return nil }
        return deliveryAddress
    }

    public var deliveryCityValue: String? {
        guard let deliveryCity = deliveryCity.text, !deliveryCity.isEmpty else { return nil }
        return deliveryCity
    }

    public var deliveryZipCodeValue: String? {
        guard let deliveryZipCode = deliveryZipCode.text, !deliveryZipCode.isEmpty else { return nil }
        return deliveryZipCode
    }

    public var deliveryCountyValue: String? {
        guard let deliveryCounty = deliveryCounty.text, !deliveryCounty.isEmpty else { return nil }
        return deliveryCounty
    }

    public var deliveryCountryIsoValue: String? {
        guard let deliveryCountryIso = deliveryCountryIso.text, deliveryCountryIso.count == 2 else { return nil }
        return deliveryCountryIso
    }

    // MARK: Actions

    @objc private func amountSwitchAction(_: UISegmentedControl) {
        amountInput.selectedAmountType = selectedAmountType
        switch selectedAmountType {
        case .baseAmount:
            guard !amountValue.isEmpty else { return }
            let value = amountValue.count > amountInput.maximumInputLength ? String(amountValue.dropLast(amountValue.count - amountInput.maximumInputLength)) : amountValue
            if amountValue.contains(".") {
                let newValue = Int(Double(value)! * 100)
                amountInput.text = "\(newValue)"
            } else {
                amountInput.text = "\(value)"
            }
        case .mainAmount:
            guard !amountValue.isEmpty else { return }
            if amountValue.contains(".") {
                break
            }
            amountInput.text = String(format: "%.2f", Double(amountValue)! / 100.0)
        }
    }

    // MARK: Setup functions

    override public func setupViewHierarchy() {
        super.setupViewHierarchy()
        container.addSubview(payloadStackView)
        stackView.insertArrangedSubview(billingDataStackView, at: max(stackView.arrangedSubviews.count - 1, 0))
        stackView.insertArrangedSubview(deliveryDataStackView, at: max(stackView.arrangedSubviews.count - 1, 0))
        stackView.insertArrangedSubview(container, at: max(stackView.arrangedSubviews.count - 1, 0))
    }

    override public func setupProperties() {
        super.setupProperties()
        billingName.textFieldTextAligment = .center
        billingName.title = Localizable.DropInCustomViewWithPayloadParameters.billingNameTitle.text
        billingName.isFieldRequired = false
        billingName.placeholder = Localizable.DropInCustomViewWithPayloadParameters.billingNamePlaceholder.text

        billingAddress.textFieldTextAligment = .center
        billingAddress.title = Localizable.DropInCustomViewWithPayloadParameters.billingAddressTitle.text
        billingAddress.isFieldRequired = false
        billingAddress.placeholder = Localizable.DropInCustomViewWithPayloadParameters.billingAddressPlaceholder.text

        billingCity.textFieldTextAligment = .center
        billingCity.title = Localizable.DropInCustomViewWithPayloadParameters.billingCityTitle.text
        billingCity.isFieldRequired = false
        billingCity.placeholder = Localizable.DropInCustomViewWithPayloadParameters.billingCityPlaceholder.text

        billingZipCode.textFieldTextAligment = .center
        billingZipCode.title = Localizable.DropInCustomViewWithPayloadParameters.billingZipCodeTitle.text
        billingZipCode.isFieldRequired = false
        billingZipCode.placeholder = Localizable.DropInCustomViewWithPayloadParameters.billingZipCodePlaceholder.text
        billingZipCode.maximumInputLength = 25

        billingCounty.relatedInput = billingCountryIso
        billingCounty.textFieldTextAligment = .center
        billingCounty.title = Localizable.DropInCustomViewWithPayloadParameters.billingCountyTitle.text
        billingCounty.isFieldRequired = false
        billingCounty.placeholder = Localizable.DropInCustomViewWithPayloadParameters.billingCountyPlaceholder.text
        billingCounty.emptyError = Localizable.DropInCustomViewWithPayloadParameters.billingCountyEmptyError.text

        billingCountryIso.relatedInput = billingCounty
        billingCountryIso.textFieldTextAligment = .center
        billingCountryIso.title = Localizable.DropInCustomViewWithPayloadParameters.billingCountryIsoTitle.text
        billingCountryIso.isFieldRequired = false
        billingCountryIso.placeholder = Localizable.DropInCustomViewWithPayloadParameters.billingCountryIsoPlaceholder.text
        billingCountryIso.keyboardType = .alphabet
        billingCountryIso.emptyError = Localizable.DropInCustomViewWithPayloadParameters.billingCountryIsoEmptyError.text
        billingCountryIso.error = Localizable.DropInCustomViewWithPayloadParameters.billingCountryIsoError.text

        deliveryName.textFieldTextAligment = .center
        deliveryName.title = Localizable.DropInCustomViewWithPayloadParameters.deliveryNameTitle.text
        deliveryName.isFieldRequired = false
        deliveryName.placeholder = Localizable.DropInCustomViewWithPayloadParameters.deliveryNamePlaceholder.text

        deliveryAddress.textFieldTextAligment = .center
        deliveryAddress.title = Localizable.DropInCustomViewWithPayloadParameters.deliveryAddressTitle.text
        deliveryAddress.isFieldRequired = false
        deliveryAddress.placeholder = Localizable.DropInCustomViewWithPayloadParameters.deliveryAddressPlaceholder.text

        deliveryCity.textFieldTextAligment = .center
        deliveryCity.title = Localizable.DropInCustomViewWithPayloadParameters.deliveryCityTitle.text
        deliveryCity.isFieldRequired = false
        deliveryCity.placeholder = Localizable.DropInCustomViewWithPayloadParameters.deliveryCityPlaceholder.text

        deliveryZipCode.textFieldTextAligment = .center
        deliveryZipCode.title = Localizable.DropInCustomViewWithPayloadParameters.deliveryZipCodeTitle.text
        deliveryZipCode.isFieldRequired = false
        deliveryZipCode.placeholder = Localizable.DropInCustomViewWithPayloadParameters.deliveryZipCodePlaceholder.text
        deliveryZipCode.maximumInputLength = 25

        deliveryCounty.relatedInput = deliveryCountryIso
        deliveryCounty.textFieldTextAligment = .center
        deliveryCounty.title = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountyTitle.text
        deliveryCounty.isFieldRequired = false
        deliveryCounty.placeholder = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountyPlaceholder.text
        deliveryCountryIso.emptyError = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountyEmptyError.text

        deliveryCountryIso.relatedInput = deliveryCounty
        deliveryCountryIso.textFieldTextAligment = .center
        deliveryCountryIso.title = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountryIsoTitle.text
        deliveryCountryIso.isFieldRequired = false
        deliveryCountryIso.placeholder = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountryIsoPlaceholder.text
        deliveryCountryIso.keyboardType = .alphabet
        deliveryCountryIso.emptyError = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountryIsoEmptyError.text
        deliveryCountryIso.error = Localizable.DropInCustomViewWithPayloadParameters.deliveryCountryIsoError.text

        amountInput.delegate = self
        billingCounty.delegate = self
        billingCountryIso.delegate = self
        deliveryCounty.delegate = self
        deliveryCountryIso.delegate = self
        additionalFieldsToValidate.append(contentsOf: [amountInput, billingCounty, billingCountryIso, deliveryCounty, deliveryCountryIso])
    }

    override public func setupConstraints() {
        super.setupConstraints()
        payloadStackView.addConstraints([
            equal(container, \.topAnchor, constant: 0),
            equal(container, \.bottomAnchor, constant: 0),
            equal(container, \.centerXAnchor, constant: 0)
        ])
    }
}

private extension Localizable {
    enum DropInCustomViewWithPayloadParameters: String, Localized {
        case deliveryCountyTitle
        case deliveryCountyPlaceholder
        case deliveryCountyEmptyError
        case deliveryCountryIsoTitle
        case deliveryCountryIsoPlaceholder
        case deliveryCountryIsoEmptyError
        case deliveryCountryIsoError

        case deliveryZipCodeTitle
        case deliveryZipCodePlaceholder
        case deliveryCityTitle
        case deliveryCityPlaceholder
        case deliveryAddressTitle
        case deliveryAddressPlaceholder
        case deliveryNameTitle
        case deliveryNamePlaceholder

        case billingCountyTitle
        case billingCountyPlaceholder
        case billingCountyEmptyError
        case billingCountryIsoTitle
        case billingCountryIsoPlaceholder
        case billingCountryIsoEmptyError
        case billingCountryIsoError

        case billingZipCodeTitle
        case billingZipCodePlaceholder
        case billingCityTitle
        case billingCityPlaceholder
        case billingAddressTitle
        case billingAddressPlaceholder
        case billingNameTitle
        case billingNamePlaceholder

        case deliveryData
        case billingData

        case changeCurrency
        case changeAmount

        case amountInputViewError
        case amountInputViewEmptyError
        case amountInputViewTitle
        case amountInputViewPlaceholder
    }
}
