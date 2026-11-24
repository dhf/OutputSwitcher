import Foundation
import Observation

/// Per-device icon choices, persisted in UserDefaults. Without an override the
/// automatic icon from `OutputIconMapper` is used.
@MainActor
@Observable
final class IconStore {
    private static let defaultsKey = "iconOverrides"

    /// Device UID → SF Symbol name.
    private(set) var overrides: [String: String]

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        overrides = defaults.dictionary(forKey: Self.defaultsKey) as? [String: String] ?? [:]
    }

    func symbol(for device: AudioOutputDevice) -> String {
        overrides[device.uid] ?? OutputIconMapper.symbol(for: device)
    }

    func hasOverride(for device: AudioOutputDevice) -> Bool {
        overrides[device.uid] != nil
    }

    /// Stores `name` for the device. Pass `nil` to go back to the automatic icon.
    /// Names that are not valid SF Symbols are ignored.
    func setSymbol(_ name: String?, for device: AudioOutputDevice) {
        if let name {
            guard SymbolCatalog.isValid(name) else { return }
            overrides[device.uid] = name
        } else {
            overrides[device.uid] = nil
        }
        defaults.set(overrides, forKey: Self.defaultsKey)
    }
}
