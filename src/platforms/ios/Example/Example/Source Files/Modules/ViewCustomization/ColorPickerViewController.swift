//
//  ColorPickerViewController.swift
//  Example
//

import UIKit

final class ColorPickerViewController: BaseViewController<ColorPickerView, ColorPickerViewModel> {
    /// Enum describing events that can be triggered by this controller
    enum Event {
        case selectedColor(UIColor)
    }

    /// Callback with triggered event
    var eventTriggered: ((Event) -> Void)?

    /// - SeeAlso: BaseViewController.setupView
    override func setupView() {
        title = Localizable.ColorPickerViewController.title.text
        customView.colorView.backgroundColor = viewModel.selectedColor
        setupBarButtons()
    }

    /// - SeeAlso: BaseViewController.setupCallbacks
    override func setupCallbacks() {
        customView.colorPickerComponent.delegate = self
    }

    /// - SeeAlso: BaseViewController.setupProperties
    override func setupProperties() {}

    /// Set up top navigation bar buttons
    private func setupBarButtons() {
        let selectBarButton = UIBarButtonItem(title: Localizable.ColorPickerViewController.selectButton.text, style: .plain, target: self, action: #selector(selectBarButtonTapped))
        navigationItem.rightBarButtonItem = selectBarButton

        let cancelBarButton = UIBarButtonItem(title: Localizable.ColorPickerViewController.cancelButton.text, style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        navigationItem.leftBarButtonItem = cancelBarButton
    }

    /// Action triggered after tapping select bar button
    @objc private func selectBarButtonTapped() {
        eventTriggered?(.selectedColor(viewModel.selectedColor))
        dismiss(animated: true)
    }

    /// Action triggered after tapping cancel bar button
    @objc private func cancelBarButtonTapped() {
        dismiss(animated: true)
    }
}

extension ColorPickerViewController: ColorPickerDelegate {
    func colorPickerTouched(sender _: ColorPickerViewComponent, color: UIColor, point _: CGPoint, state _: UIGestureRecognizer.State) {
        viewModel.selectedColor = color
        customView.colorView.backgroundColor = color
    }
}

private extension Localizable {
    enum ColorPickerViewController: String, Localized {
        case title
        case selectButton
        case cancelButton
    }
}
