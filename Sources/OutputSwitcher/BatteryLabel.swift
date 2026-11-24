import SwiftUI

/// "97 %" with a matching battery indicator.
struct BatteryLabel: View {
    let percent: Int

    var body: some View {
        HStack {
            Text(Double(percent) / 100, format: .percent)
                .foregroundStyle(.secondary)
            BatteryIndicator(percent: percent)
        }
        .font(.callout)
    }
}
