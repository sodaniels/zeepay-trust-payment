//
//  String.swift
//  Example
//

public extension String {
    var isDecimal: Bool {
        Double(self) != nil
    }

    var isInteger: Bool {
        Int(self) != nil
    }

    var isAlphabetic: Bool {
        let characterSet = CharacterSet.letters
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        return true
    }
}
