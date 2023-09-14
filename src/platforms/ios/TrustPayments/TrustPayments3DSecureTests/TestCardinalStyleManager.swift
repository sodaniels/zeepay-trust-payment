//
//  TestCardinalStyleManager.swift
//  TrustPayments3DSecureTests
//

import CardinalMobile
@testable import TrustPayments3DSecure
import XCTest

class TestCardinalStyleManager: XCTestCase {
    let color = UIColor.black
    let font = CardinalFont(name: "Arial", size: 11)
    let text = "Cardinal Style Manager"
    let size: CGFloat = 8

    func test_cardinalFont() {
        let size: CGFloat = 11.5
        let name = "Arial"
        let sut = CardinalFont(name: name, size: size)

        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.size, size)
    }

    func test_cardinalToolbar() {
        let textColor = UIColor.green
        let backgroundColor = UIColor.purple
        let textFont = CardinalFont(name: "Times", size: 21)
        let headerText = "Header Text"
        let buttonText = "Button Text"
        let sut = CardinalToolbarStyleManager(textColor: textColor, textFont: textFont, backgroundColor: backgroundColor, headerText: headerText, buttonText: buttonText)

        XCTAssertEqual(sut.textColor, textColor)
        XCTAssertEqual(sut.backgroundColor, backgroundColor)
        XCTAssertEqual(sut.textFont?.size, textFont.size)
        XCTAssertEqual(sut.textFont?.name, textFont.name)
        XCTAssertEqual(sut.headerText, headerText)
        XCTAssertEqual(sut.buttonText, buttonText)
    }

    func test_cardinalLabels() {
        let textColor = UIColor.red
        let headingTextColor = UIColor.blue
        let textFont = CardinalFont(size: 1)
        let headingTextFont = CardinalFont(name: "Cardinal", size: 31)
        let sut = CardinalLabelStyleManager(textColor: textColor, textFont: textFont, headingTextColor: headingTextColor, headingTextFont: headingTextFont)

        XCTAssertEqual(sut.textColor, textColor)
        XCTAssertEqual(sut.headingTextColor, headingTextColor)
        XCTAssertEqual(sut.textFont?.name, textFont.name)
        XCTAssertEqual(sut.textFont?.size, textFont.size)
        XCTAssertEqual(sut.headingTextFont?.name, headingTextFont.name)
        XCTAssertEqual(sut.headingTextFont?.size, headingTextFont.size)
    }

    func test_cardinalButton() {
        let textColor = UIColor.green
        let backgroundColor = UIColor.systemPink
        let textFont = CardinalFont(size: 11)
        let cornerRadius: CGFloat = 8
        let sut = CardinalButtonStyleManager(textColor: textColor, textFont: textFont, backgroundColor: backgroundColor, cornerRadius: cornerRadius)

        XCTAssertEqual(sut.textColor, textColor)
        XCTAssertEqual(sut.backgroundColor, backgroundColor)
        XCTAssertEqual(sut.textFont?.name, textFont.name)
        XCTAssertEqual(sut.textFont?.size, textFont.size)
        XCTAssertEqual(sut.cornerRadius, cornerRadius)
    }

    func test_cardinalTextbox() {
        let textColor = UIColor.gray
        let borderColor = UIColor.yellow
        let textFont = CardinalFont(name: "Noteworthy", size: 90)
        let cornerRadius: CGFloat = 12
        let borderWidth: CGFloat = 2
        let sut = CardinalTextBoxStyleManager(textColor: textColor, textFont: textFont, borderColor: borderColor, cornerRadius: cornerRadius, borderWidth: borderWidth)

        XCTAssertEqual(sut.textColor, textColor)
        XCTAssertEqual(sut.borderColor, borderColor)
        XCTAssertEqual(sut.textFont?.name, textFont.name)
        XCTAssertEqual(sut.textFont?.size, textFont.size)
        XCTAssertEqual(sut.cornerRadius, cornerRadius)
        XCTAssertEqual(sut.borderWidth, borderWidth)
    }

    func test_setStyleManager() {
        let color = UIColor.black
        let font = CardinalFont(name: "Arial", size: 11)
        let text = "Cardinal Style Manager"
        let size: CGFloat = 8
        let toolbarStyleManager = CardinalToolbarStyleManager(textColor: color, textFont: font, backgroundColor: color, headerText: text, buttonText: text)
        let labelStyleManager = CardinalLabelStyleManager(textColor: color, textFont: font, headingTextColor: color, headingTextFont: font)
        let verifyButtonStyleManager = CardinalButtonStyleManager(textColor: color, textFont: font, backgroundColor: color, cornerRadius: size)
        let continueButtonStyleManager = CardinalButtonStyleManager(textColor: color, textFont: font, backgroundColor: color, cornerRadius: size)
        let resendButtonStyleManager = CardinalButtonStyleManager(textColor: color, textFont: font, backgroundColor: color, cornerRadius: size)
        let textBoxStyleManager = CardinalTextBoxStyleManager(textColor: color, textFont: font, borderColor: color, cornerRadius: size, borderWidth: size)
        let sut = CardinalStyleManager(toolbarStyleManager: toolbarStyleManager,
                                       labelStyleManager: labelStyleManager,
                                       verifyButtonStyleManager: verifyButtonStyleManager,
                                       continueButtonStyleManager: continueButtonStyleManager,
                                       resendButtonStyleManager: resendButtonStyleManager,
                                       textBoxStyleManager: textBoxStyleManager)

        XCTAssertEqual(sut.toolbarStyleManager, toolbarStyleManager)
        XCTAssertEqual(sut.labelStyleManager, labelStyleManager)
        XCTAssertEqual(sut.verifyButtonStyleManager, verifyButtonStyleManager)
        XCTAssertEqual(sut.continueButtonStyleManager, continueButtonStyleManager)
        XCTAssertEqual(sut.resendButtonStyleManager, resendButtonStyleManager)
        XCTAssertEqual(sut.textBoxStyleManager, textBoxStyleManager)
    }

    func test_uiCustomizationToolbar() {
        let styleManager = getStyleManagerwithSharedProperties()
        let uiCustomization = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: styleManager, cardinalDarkModeStyleManager: styleManager).getUiCustomization(cardinalStyleManager: styleManager)
        let sut = uiCustomization.getToolbarCustomization()

        XCTAssertEqual(sut?.textColor, color.hexString)
        XCTAssertEqual(sut?.backgroundColor, color.hexString)
        XCTAssertEqual(sut?.textFontName, font.name)
        XCTAssertEqual(sut?.textFontSize, Int32(font.size))
        XCTAssertEqual(sut?.headerText, text)
        XCTAssertEqual(sut?.buttonText, text)
    }

    func test_uiCustomizationLabels() {
        let styleManager = getStyleManagerwithSharedProperties()
        let uiCustomization = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: styleManager, cardinalDarkModeStyleManager: styleManager).getUiCustomization(cardinalStyleManager: styleManager)
        let sut = uiCustomization.getLabel()

        XCTAssertEqual(sut?.textColor, color.hexString)
        XCTAssertEqual(sut?.headingTextColor, color.hexString)
        XCTAssertEqual(sut?.textFontName, font.name)
        XCTAssertEqual(sut?.textFontSize, Int32(font.size))
        XCTAssertEqual(sut?.headingTextFontName, font.name)
        XCTAssertEqual(sut?.headingTextFontSize, Int32(font.size))
    }

    func test_uiCustomizationButtonVerify() {
        let styleManager = getStyleManagerwithSharedProperties()
        let uiCustomization = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: styleManager, cardinalDarkModeStyleManager: styleManager).getUiCustomization(cardinalStyleManager: styleManager)
        let sut = uiCustomization.getButtonCustomization(ButtonTypeVerify)

        XCTAssertEqual(sut?.textColor, color.hexString)
        XCTAssertEqual(sut?.backgroundColor, color.hexString)
        XCTAssertEqual(sut?.textFontName, font.name)
        XCTAssertEqual(sut?.textFontSize, Int32(font.size))
        XCTAssertEqual(sut?.cornerRadius, Int32(size))
    }

    func test_uiCustomizationButtonContinue() {
        let styleManager = getStyleManagerwithSharedProperties()
        let uiCustomization = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: styleManager, cardinalDarkModeStyleManager: styleManager).getUiCustomization(cardinalStyleManager: styleManager)
        let sut = uiCustomization.getButtonCustomization(ButtonTypeContinue)

        XCTAssertEqual(sut?.textColor, color.hexString)
        XCTAssertEqual(sut?.backgroundColor, color.hexString)
        XCTAssertEqual(sut?.textFontName, font.name)
        XCTAssertEqual(sut?.textFontSize, Int32(font.size))
        XCTAssertEqual(sut?.cornerRadius, Int32(size))
    }

    func test_uiCustomizationButtonResend() {
        let styleManager = getStyleManagerwithSharedProperties()
        let uiCustomization = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: styleManager, cardinalDarkModeStyleManager: styleManager).getUiCustomization(cardinalStyleManager: styleManager)
        let sut = uiCustomization.getButtonCustomization(ButtonTypeResend)

        XCTAssertEqual(sut?.textColor, color.hexString)
        XCTAssertEqual(sut?.backgroundColor, color.hexString)
        XCTAssertEqual(sut?.textFontName, font.name)
        XCTAssertEqual(sut?.textFontSize, Int32(font.size))
        XCTAssertEqual(sut?.cornerRadius, Int32(size))
    }

    func test_uiCustomizationTextbox() {
        let styleManager = getStyleManagerwithSharedProperties()
        let uiCustomization = TP3DSecureManager(isLiveStatus: false, cardinalStyleManager: styleManager, cardinalDarkModeStyleManager: styleManager).getUiCustomization(cardinalStyleManager: styleManager)
        let sut = uiCustomization.getTextBox()

        XCTAssertEqual(sut?.textColor, color.hexString)
        XCTAssertEqual(sut?.borderColor, color.hexString)
        XCTAssertEqual(sut?.textFontName, font.name)
        XCTAssertEqual(sut?.textFontSize, Int32(font.size))
        XCTAssertEqual(sut?.cornerRadius, Int32(size))
        XCTAssertEqual(sut?.borderWidth, Int32(size))
    }
}

extension TestCardinalStyleManager {
    private func getStyleManagerwithSharedProperties() -> CardinalStyleManager {
        let toolbarStyleManager = CardinalToolbarStyleManager(textColor: color, textFont: font, backgroundColor: color, headerText: text, buttonText: text)
        let labelStyleManager = CardinalLabelStyleManager(textColor: color, textFont: font, headingTextColor: color, headingTextFont: font)
        let verifyButtonStyleManager = CardinalButtonStyleManager(textColor: color, textFont: font, backgroundColor: color, cornerRadius: size)
        let continueButtonStyleManager = CardinalButtonStyleManager(textColor: color, textFont: font, backgroundColor: color, cornerRadius: size)
        let resendButtonStyleManager = CardinalButtonStyleManager(textColor: color, textFont: font, backgroundColor: color, cornerRadius: size)
        let textBoxStyleManager = CardinalTextBoxStyleManager(textColor: color, textFont: font, borderColor: color, cornerRadius: size, borderWidth: size)
        let styleManager = CardinalStyleManager(toolbarStyleManager: toolbarStyleManager,
                                                labelStyleManager: labelStyleManager,
                                                verifyButtonStyleManager: verifyButtonStyleManager,
                                                continueButtonStyleManager: continueButtonStyleManager,
                                                resendButtonStyleManager: resendButtonStyleManager,
                                                textBoxStyleManager: textBoxStyleManager)
        return styleManager
    }
}
