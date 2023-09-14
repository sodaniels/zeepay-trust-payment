//
//  ColorPickerView.swift
//  Example
//

import UIKit

internal protocol ColorPickerDelegate: AnyObject {
    func colorPickerTouched(sender: ColorPickerViewComponent, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State)
}

class ColorPickerViewComponent: UIView {
    weak var delegate: ColorPickerDelegate?
    let saturationExponentTop: Float = 2.0
    let saturationExponentBottom: Float = 1.3

    var elementSize: CGFloat = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    private func initialize() {
        clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(touchedColor(gestureRecognizer:)))
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        addGestureRecognizer(touchGesture)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y: CGFloat in stride(from: 0.0, to: rect.height, by: elementSize) {
            var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
            saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
            for x: CGFloat in stride(from: 0.0, to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x: x, y: y, width: elementSize, height: elementSize))
            }
        }
    }

    func getColorAtPoint(point: CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x: elementSize * CGFloat(Int(point.x / elementSize)),
                                   y: elementSize * CGFloat(Int(point.y / elementSize)))
        var saturation = roundedPoint.y < bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / bounds.height
            : 2.0 * CGFloat(bounds.height - roundedPoint.y) / bounds.height
        saturation = CGFloat(powf(Float(saturation), roundedPoint.y < bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
        let brightness = roundedPoint.y < bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(bounds.height - roundedPoint.y) / bounds.height
        let hue = roundedPoint.x / bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    func getPointForColor(color: UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        var yPos: CGFloat = 0
        let halfHeight = (bounds.height / 2)
        if brightness >= 0.99 {
            let percentageY = powf(Float(saturation), 1.0 / saturationExponentTop)
            yPos = CGFloat(percentageY) * halfHeight
        } else {
            // use brightness to get Y
            yPos = halfHeight + halfHeight * (1.0 - brightness)
        }
        let xPos = hue * bounds.width
        return CGPoint(x: xPos, y: yPos)
    }

    @objc func touchedColor(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let point = gestureRecognizer.location(in: self)
            let color = getColorAtPoint(point: point)
            delegate?.colorPickerTouched(sender: self, color: color, point: point, state: gestureRecognizer.state)
        }
    }
}
