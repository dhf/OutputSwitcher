import Foundation
import IOBluetooth

/// Reads the battery of a connected Bluetooth audio device (e.g. AirPods).
///
/// `IOBluetoothDevice` exposes the value only through private properties, so they are
/// called through the Objective-C runtime and guarded with `responds(to:)`. macOS needs
/// `NSBluetoothAlwaysUsageDescription` in the app's Info.plist before any Bluetooth access.
enum BluetoothBattery {
    private static let usageKey = "NSBluetoothAlwaysUsageDescription"

    static func percent(for device: AudioOutputDevice) -> Int? {
        guard device.transport == .bluetooth,
              Bundle.main.object(forInfoDictionaryKey: usageKey) != nil,
              let address = address(fromAudioUID: device.uid),
              let bluetoothDevice = IOBluetoothDevice(addressString: address) else { return nil }

        let single = byte(bluetoothDevice, "batteryPercentSingle")
        let combined = byte(bluetoothDevice, "batteryPercentCombined")
        let sides = ["batteryPercentLeft", "batteryPercentRight"]
            .compactMap { byte(bluetoothDevice, $0) }
            .filter { $0 > 0 }
        let averageOfSides = sides.isEmpty ? nil : sides.reduce(0, +) / sides.count

        return [single, combined, averageOfSides]
            .compactMap { $0 }
            .first { $0 > 0 && $0 <= 100 }
    }

    /// CoreAudio UIDs of Bluetooth devices look like "70-F9-4A-8D-52-63:output".
    static func address(fromAudioUID uid: String) -> String? {
        guard let candidate = uid.split(separator: ":").first,
              candidate.split(separator: "-").count == 6 else { return nil }
        return String(candidate)
    }

    private static func byte(_ object: NSObject, _ name: String) -> Int? {
        let selector = Selector(name)
        guard object.responds(to: selector) else { return nil }
        typealias Getter = @convention(c) (AnyObject, Selector) -> UInt8
        let getter = unsafeBitCast(object.method(for: selector), to: Getter.self)
        return Int(getter(object, selector))
    }
}
