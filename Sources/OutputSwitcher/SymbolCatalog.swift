import AppKit

/// SF Symbols offered in the icon picker, plus validation for custom names.
enum SymbolCatalog {
    private static let candidates = [
        "headphones", "headphones.circle", "airpods", "airpods.gen3", "airpodspro", "airpodsmax",
        "beats.headphones", "earbuds", "hearingdevice.ear",
        "speaker.wave.2", "speaker.wave.3", "hifispeaker", "hifispeaker.2", "homepod", "homepod.2",
        "display", "tv", "appletv", "macstudio", "macmini", "laptopcomputer", "desktopcomputer",
        "iphone", "ipad", "airplayaudio", "car", "gamecontroller", "mic", "music.note", "waveform",
        "cable.connector", "square.stack.3d.up", "dot.radiowaves.left.and.right", "star", "heart", "bolt",
    ]

    /// Candidates that exist on this macOS version (an unknown name would render blank).
    static let suggestions: [String] = candidates.filter(isValid)

    static func isValid(_ name: String) -> Bool {
        !name.isEmpty && NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
    }
}
