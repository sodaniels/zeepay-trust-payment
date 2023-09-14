//
//  CITestDevices.swift
//  ExampleTests
//

import SnapshotTesting

enum CITestDevices: String, CaseIterable {
    // swiftlint:disable identifier_name
    case iPhone5s_ios11
    case iPhone11Pro_ios14
    case iPhone8_ios12
    case iPadPro_ios13
    case unknown
    // swiftlint:enable identifier_name

    private var deviceName: String {
        switch self {
        case .iPhone5s_ios11: return "iPhone 5s"
        case .iPhone8_ios12: return "iPhone 8"
        case .iPhone11Pro_ios14: return "iPhone 11 Pro"
        case .iPadPro_ios13: return "iPad Pro"
        case .unknown: return rawValue
        }
    }

    var viewImageConfig: ViewImageConfig {
        switch self {
        case .iPhone5s_ios11: return .iPhoneSe
        case .iPhone8_ios12: return .iPhone8
        case .iPhone11Pro_ios14: return .iPhoneX
        case .iPadPro_ios13: return .iPadPro12_9
        case .unknown: return .iPhone8
        }
    }

    static var current: CITestDevices {
        let currentDeviceName = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"]!
        if let supportedDevice = CITestDevices.allCases.first(where: { currentDeviceName.contains($0.deviceName) }) {
            return supportedDevice
        }
        return CITestDevices.unknown
    }
}
