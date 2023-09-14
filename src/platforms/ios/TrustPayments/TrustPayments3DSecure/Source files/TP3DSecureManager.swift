//
//  TP3DSecureManager.swift
//  TrustPayments3DSecure
//

import CardinalMobile
import Foundation

/// Mapped Cardinal warnings regarding current device and its environment
@objc public enum CardinalInitWarnings: Int {
    case jailbroken
    case integrityTampered
    case emulatorBeingUsed
    case debuggerAttached
    case osNotSupported
    case appFromNotTrustedSource

    public var localizedDescription: String {
        switch self {
        case .jailbroken:
            return "jailbroken"
        case .integrityTampered:
            return "integrity tampered"
        case .emulatorBeingUsed:
            return "emulator being used"
        case .debuggerAttached:
            return "debugger attached"
        case .osNotSupported:
            return "os not supported"
        case .appFromNotTrustedSource:
            return "app from not trusted source"
        }
    }
}

/// Base manager for dealing with 3D secure challenges via Cardinal Commerce SDK
public class TP3DSecureManager {
    // MARK: - Private properties

    let session: CardinalSession

    private let isLiveStatus: Bool

    var sessionAuthenticationValidateJWT: ((String) -> Void)?
    var sessionAuthenticationFailure: (() -> Void)?

    // MARK: - Public properties

    /// get a list of all the Warnings detected by the SDK
    public var warnings: [CardinalInitWarnings] {
        let warnings = session.getWarnings()
        var cardinalWarnings: [CardinalInitWarnings] = []

        // The device is jailbroken.
        if warnings.first(where: { $0.warningID == "SW01" }) != nil {
            cardinalWarnings.append(.jailbroken)
        }

        // The integrity of the SDK has tampered.
        if warnings.first(where: { $0.warningID == "SW02" }) != nil {
            cardinalWarnings.append(.integrityTampered)
        }

        // An emulator is being used to run the App.
        if warnings.first(where: { $0.warningID == "SW03" }) != nil {
            cardinalWarnings.append(.emulatorBeingUsed)
        }

        // A debugger is attached to the App.
        if warnings.first(where: { $0.warningID == "SW04" }) != nil {
            cardinalWarnings.append(.debuggerAttached)
        }

        // The OS or the OS version is not supported.
        if warnings.first(where: { $0.warningID == "SW05" }) != nil {
            cardinalWarnings.append(.osNotSupported)
        }

        // The application is not installed from a trusted source.
        if warnings.first(where: { $0.warningID == "SW06" }) != nil {
            cardinalWarnings.append(.appFromNotTrustedSource)
        }

        return cardinalWarnings
    }

    // MARK: - Public initializers

    /// Initializes an instance of the receiver
    /// - Parameter isLiveStatus: this instructs whether the 3-D Secure checks are performed using the test environment or production environment (if false 3-D Secure checks are performed using the test environment)
    /// - Parameter cardinalStyleManager: manager to set the interface style (view customization)
    /// - Parameter cardinalDarkModeStyleManager: manager to set the interface style in dark mode
    public init(isLiveStatus: Bool, cardinalStyleManager: CardinalStyleManager?, cardinalDarkModeStyleManager: CardinalStyleManager?, session: CardinalSession = CardinalSession()) {
        self.isLiveStatus = isLiveStatus
        self.session = session
        configure(cardinalStyleManager: cardinalStyleManager, cardinalDarkModeStyleManager: cardinalDarkModeStyleManager)
    }

    // MARK: - Private methods

    /// Configure session with env type, timeouts and UI
    private func configure(cardinalStyleManager: CardinalStyleManager?, cardinalDarkModeStyleManager: CardinalStyleManager?) {
        let config = CardinalSessionConfiguration()
        config.deploymentEnvironment = isLiveStatus ? .production : .staging
        config.requestTimeout = 8000
        config.challengeTimeout = 8
        config.uiType = .both // possible native and html

        // Set various customizations here. See "iOS UI Customization" documentation for detail.
        if let cardinalStyleManager = cardinalStyleManager {
            config.uiCustomization = getUiCustomization(cardinalStyleManager: cardinalStyleManager)
        }

        if let cardinalDarkModeStyleManager = cardinalDarkModeStyleManager {
            config.darkUiCustomization = getUiCustomization(cardinalStyleManager: cardinalDarkModeStyleManager)
        }

        config.renderType = [CardinalSessionRenderTypeOTP,
                             CardinalSessionRenderTypeHTML,
                             CardinalSessionRenderTypeOOB,
                             CardinalSessionRenderTypeSingleSelect,
                             CardinalSessionRenderTypeMultiSelect]

        // configure session
        session.configure(config)
    }

    // swiftlint:disable cyclomatic_complexity
    func getUiCustomization(cardinalStyleManager: CardinalStyleManager) -> UiCustomization {
        let ui = UiCustomization()

        if let toolbarStyleManager = cardinalStyleManager.toolbarStyleManager {
            let toolbarCust = ToolbarCustomization()
            let buttonCustomization = ButtonCustomization()

            if let headerText = toolbarStyleManager.headerText {
                toolbarCust.headerText = headerText
            }

            if let buttonText = toolbarStyleManager.buttonText {
                toolbarCust.buttonText = buttonText
            }

            if let textColor = toolbarStyleManager.textColor {
                toolbarCust.textColor = textColor.hexString
                buttonCustomization.textColor = textColor.hexString
            }

            if let backgroundColor = toolbarStyleManager.backgroundColor {
                toolbarCust.backgroundColor = backgroundColor.hexString
            }

            if let textFont = toolbarStyleManager.textFont {
                toolbarCust.textFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    toolbarCust.textFontName = name
                }
            }

            ui.setToolbar(toolbarCust)
            ui.setButton(buttonCustomization, buttonType: ButtonTypeCancel)
        }

        if let labelStyleManager = cardinalStyleManager.labelStyleManager {
            let labelCust = LabelCustomization()

            if let textColor = labelStyleManager.textColor {
                labelCust.textColor = textColor.hexString
            }

            if let textFont = labelStyleManager.textFont {
                labelCust.textFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    labelCust.textFontName = name
                }
            }

            if let textColor = labelStyleManager.headingTextColor {
                labelCust.headingTextColor = textColor.hexString
            }

            if let textFont = labelStyleManager.headingTextFont {
                labelCust.headingTextFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    labelCust.headingTextFontName = name
                }
            }

            ui.setLabel(labelCust)
        }

        if let verifyButtonStyleManager = cardinalStyleManager.verifyButtonStyleManager {
            let buttonCustomization = ButtonCustomization()

            if let textColor = verifyButtonStyleManager.textColor {
                buttonCustomization.textColor = textColor.hexString
            }

            if let textFont = verifyButtonStyleManager.textFont {
                buttonCustomization.textFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    buttonCustomization.textFontName = name
                }
            }

            if let backgroundColor = verifyButtonStyleManager.backgroundColor {
                buttonCustomization.backgroundColor = backgroundColor.hexString
            }

            buttonCustomization.cornerRadius = Int32(verifyButtonStyleManager.cornerRadius)

            ui.setButton(buttonCustomization, buttonType: ButtonTypeVerify)
        }

        if let continueButtonStyleManager = cardinalStyleManager.continueButtonStyleManager {
            let buttonCustomization = ButtonCustomization()

            if let textColor = continueButtonStyleManager.textColor {
                buttonCustomization.textColor = textColor.hexString
            }

            if let textFont = continueButtonStyleManager.textFont {
                buttonCustomization.textFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    buttonCustomization.textFontName = name
                }
            }

            if let backgroundColor = continueButtonStyleManager.backgroundColor {
                buttonCustomization.backgroundColor = backgroundColor.hexString
            }

            buttonCustomization.cornerRadius = Int32(continueButtonStyleManager.cornerRadius)

            ui.setButton(buttonCustomization, buttonType: ButtonTypeContinue)
        }

        if let resendButtonStyleManager = cardinalStyleManager.resendButtonStyleManager {
            let buttonCustomization = ButtonCustomization()

            if let textColor = resendButtonStyleManager.textColor {
                buttonCustomization.textColor = textColor.hexString
            }

            if let textFont = resendButtonStyleManager.textFont {
                buttonCustomization.textFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    buttonCustomization.textFontName = name
                }
            }

            if let backgroundColor = resendButtonStyleManager.backgroundColor {
                buttonCustomization.backgroundColor = backgroundColor.hexString
            }

            buttonCustomization.cornerRadius = Int32(resendButtonStyleManager.cornerRadius)

            ui.setButton(buttonCustomization, buttonType: ButtonTypeResend)
        }

        if let cardinalTextBoxStyleManager = cardinalStyleManager.textBoxStyleManager {
            let textboxCustomization = TextBoxCustomization()

            if let textColor = cardinalTextBoxStyleManager.textColor {
                textboxCustomization.textColor = textColor.hexString
            }

            if let textFont = cardinalTextBoxStyleManager.textFont {
                textboxCustomization.textFontSize = Int32(textFont.size)
                if let name = textFont.name {
                    textboxCustomization.textFontName = name
                }
            }

            if let borderColor = cardinalTextBoxStyleManager.borderColor {
                textboxCustomization.borderColor = borderColor.hexString
            }

            textboxCustomization.borderWidth = Int32(cardinalTextBoxStyleManager.borderWidth)

            textboxCustomization.cornerRadius = Int32(cardinalTextBoxStyleManager.cornerRadius)

            ui.setTextBox(textboxCustomization)
        }

        return ui
    }

    // swiftlint:enable cyclomatic_complexity

    // MARK: - Public methods

    /// Authenticating merchant's credentials (jwt) and completing the data collection process
    /// - Parameters:
    ///   - jwt: JWT provided by TP in response to JSINIT request
    ///   - completion: success closure with following parameters: consumer session id
    ///   - failure: if there was an error with setup, cardinal will call this closure with validate response object
    public func setup(with jwt: String, completion: @escaping ((String) -> Void), failure: @escaping ((CardinalResponse) -> Void)) {
        session.setup(jwtString: jwt, completed: { consumerSessionId in
            completion(consumerSessionId)
        }, validated: { validateResponse in
            failure(validateResponse)
        })
    }

    /// Create the authentication session - call this method to hand control to SDK for performing the challenge between the user and the issuing bank.
    /// - Parameters:
    ///   - transactionId: transaction id
    ///   - payload: transaction payload
    public func continueSession(with transactionId: String, payload: String, sessionAuthenticationValidateJWT: @escaping ((String) -> Void), sessionAuthenticationFailure: @escaping (() -> Void)) {
        self.sessionAuthenticationValidateJWT = sessionAuthenticationValidateJWT
        self.sessionAuthenticationFailure = sessionAuthenticationFailure
        session.continueWith(transactionId: transactionId, payload: payload, validationDelegate: self)
    }
}

extension TP3DSecureManager: CardinalValidationDelegate {
    /// This method is triggered when the transaction has been terminated. This is how SDK hands back control to the merchant's application. This method will include data on how the transaction attempt ended and you should have your logic for reviewing the results of the transaction and making decisions regarding next steps.
    /// - Parameters:
    ///   - session: session object
    ///   - validateResponse: validate response object
    ///   - serverJWT: token which should be send to TP backend for validation (AUTH request)
    public func cardinalSession(cardinalSession _: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {
        // The field ActionCode should be used to determine the overall state of the transaction. On the first pass, we recommend that on an ActionCode of 'SUCCESS' or 'NOACTION' you send the response JWT to your backend for verification.
        switch validateResponse.actionCode {
        // Handle no actionable outcome
        case .noAction:
            fallthrough
        // Handle successful transaction, send JWT to backend to verify
        case .success:
            sessionAuthenticationValidateJWT?(serverJWT)
        // Handle transaction timedout
        case .timeout:
            fallthrough
        // Handle transaction canceled by user
        case .cancel:
            fallthrough
        // Handle failed transaction attempt
        case .failure:
            fallthrough
        // Handle service level error
        case .error:
            fallthrough
        @unknown default:
            sessionAuthenticationFailure?()
        }
    }
}
