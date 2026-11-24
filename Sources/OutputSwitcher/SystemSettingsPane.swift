import Foundation

/// Deep links into System Settings panes.
enum SystemSettingsPane {
    case sound, bluetooth

    var url: URL {
        switch self {
        case .sound: URL(string: "x-apple.systempreferences:com.apple.Sound-Settings.extension")!
        case .bluetooth: URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings")!
        }
    }
}
