/// Human-readable description of the output's channel layout.
enum OutputFormat {
    static func label(forChannelCount count: Int) -> String? {
        switch count {
        case ..<1: nil
        case 1: "Mono"
        case 2: "Stereo"
        default: "\(count) Channels"
        }
    }
}
