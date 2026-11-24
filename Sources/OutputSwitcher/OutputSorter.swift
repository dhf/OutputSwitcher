import Foundation

/// Orders outputs like the system Sound menu: wired first, then wireless, then AirPlay,
/// alphabetical within each group.
enum OutputSorter {
    static func sorted(_ devices: [AudioOutputDevice]) -> [AudioOutputDevice] {
        devices.sorted { lhs, rhs in
            let lhsRank = rank(of: lhs)
            let rhsRank = rank(of: rhs)
            if lhsRank != rhsRank { return lhsRank < rhsRank }
            return lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
        }
    }

    /// Lower ranks come first. Built-in speakers lead, then the headphone jack, then other
    /// wired outputs (displays, USB), then Bluetooth, then AirPlay.
    private static func rank(of device: AudioOutputDevice) -> Int {
        switch device.transport {
        case .builtIn:
            (device.dataSourceName ?? "").localizedStandardContains("headphone") ? 1 : 0
        case .usb, .hdmi, .displayPort, .aggregate, .virtual, .other:
            2
        case .bluetooth:
            10
        case .airPlay:
            20
        }
    }
}
