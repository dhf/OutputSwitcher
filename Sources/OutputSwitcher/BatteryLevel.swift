import SwiftUI

/// Severity of a battery percentage, used to colour the indicator.
enum BatteryLevel: Equatable {
    case normal, low, critical

    init(percent: Int) {
        switch percent {
        case ..<10: self = .critical
        case ..<30: self = .low
        default: self = .normal
        }
    }

    var color: Color {
        switch self {
        case .normal: Color.secondary
        case .low: Color.yellow
        case .critical: Color.red
        }
    }
}
