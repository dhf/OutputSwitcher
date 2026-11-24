/// AirPods listening modes. Raw values are the names AirBuddy uses in its AppleScript dictionary.
enum ListeningMode: String, CaseIterable, Sendable {
    case normal
    case noiseCancellation = "noise cancellation"
    case transparency
    case adaptive

    var title: String {
        switch self {
        case .normal: "Off"
        case .noiseCancellation: "Noise Cancellation"
        case .transparency: "Transparency"
        case .adaptive: "Adaptive"
        }
    }

    var symbol: String {
        switch self {
        case .normal: "person.crop.circle"
        case .noiseCancellation: "person.crop.circle.fill"
        case .transparency: "sun.max.circle"
        case .adaptive: "sparkles"
        }
    }
}

/// Current and supported listening modes of the active headset.
struct ListeningModeState: Equatable, Sendable {
    var current: ListeningMode?
    var supported: [ListeningMode]

    static let unavailable = ListeningModeState(current: nil, supported: [])
}
