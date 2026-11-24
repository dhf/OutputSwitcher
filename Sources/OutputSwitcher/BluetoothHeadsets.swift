import Foundation

/// Headphones that are nearby but not connected to this Mac, for example AirPods in use on an
/// iPhone. The system Sound menu lists them and connects on click; OutputSwitcher does the same.
///
/// macOS's own list of paired devices is useless for this: it also contains every stale pairing
/// synced through iCloud. AirBuddy knows which headsets are actually in range, so it is the
/// source for the list and for connecting. Without AirBuddy running, no extra devices are shown.
enum BluetoothHeadsets {
    /// Nearby headsets that are not connected and not already an audio output in `connected`.
    static func disconnected(excluding connected: [AudioOutputDevice]) -> [AudioOutputDevice] {
        let connectedAddresses = connected.compactMap { BluetoothBattery.address(fromAudioUID: $0.uid) }

        return AirBuddyBridge.readNearbyHeadsets().compactMap { headset in
            guard !connectedAddresses.contains(where: { isSame($0, headset.address) }) else { return nil }
            return AudioOutputDevice(
                id: AudioOutputDevice.notConnectedID,
                uid: audioUID(forAddress: headset.address),
                name: headset.name,
                dataSourceName: nil,
                transport: .bluetooth
            )
        }
    }

    /// Starts connecting in the background; connecting can take several seconds.
    static func connect(toAddress address: String) {
        Task.detached(priority: .userInitiated) {
            AirBuddyBridge.connect(address: address)
        }
    }

    /// The UID CoreAudio will use for this device once connected (so icon choices carry over):
    /// uppercase, dash separated, with an ":output" suffix.
    static func audioUID(forAddress address: String) -> String {
        "\(normalized(address)):output"
    }

    /// Bluetooth addresses compare equal regardless of case and of ":" versus "-".
    static func isSame(_ lhs: String, _ rhs: String) -> Bool {
        normalized(lhs) == normalized(rhs)
    }

    private static func normalized(_ address: String) -> String {
        address.uppercased().replacing(":", with: "-")
    }
}
