import SwiftUI

/// A battery glyph whose fill matches the exact percentage; yellow below 30 %, red below 10 %.
struct BatteryIndicator: View {
    let percent: Int

    private var fraction: Double {
        Double(min(max(percent, 0), 100)) / 100
    }

    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.secondary, lineWidth: 1)

                RoundedRectangle(cornerRadius: 1.5)
                    .fill(BatteryLevel(percent: percent).color)
                    .padding(2)
                    .scaleEffect(x: fraction, anchor: .leading)
            }
            .frame(width: 24, height: 12)

            RoundedRectangle(cornerRadius: 1)
                .fill(Color.secondary)
                .frame(width: 2, height: 5)
        }
        .accessibilityElement()
        .accessibilityLabel("Battery")
        .accessibilityValue(Text(Double(percent) / 100, format: .percent))
    }
}
