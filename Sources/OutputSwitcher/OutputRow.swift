import SwiftUI

/// One output device: round icon badge (blue when active), its name, battery, and an
/// optional chevron that expands device options below the row.
struct OutputRow: View {
    let device: AudioOutputDevice
    let symbol: String
    let isActive: Bool
    let batteryPercent: Int?
    /// True while a paired headset is being connected to this Mac.
    let isConnecting: Bool
    let isExpanded: Bool
    /// Non-nil when the device has options to show; called by the chevron.
    let toggleExpanded: (() -> Void)?
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack {
            Button(action: action) {
                HStack {
                    Image(systemName: symbol)
                        .foregroundStyle(isActive ? Color.white : Color.primary)
                        .frame(width: 26, height: 26)
                        .background(isActive ? Color.accentColor : Color.secondary.opacity(0.3), in: .circle)

                    Text(device.displayName)

                    Spacer()

                    if isConnecting {
                        ProgressView()
                            .controlSize(.small)
                    } else if let batteryPercent {
                        BatteryLabel(percent: batteryPercent)
                    }
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if let toggleExpanded {
                Button(isExpanded ? "Hide Options" : "Show Options", systemImage: "chevron.right", action: toggleExpanded)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    // Points right when collapsed, down when expanded.
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(isHovering ? Color.secondary.opacity(0.2) : Color.clear, in: .rect(cornerRadius: 6))
        .onHover { isHovering = $0 }
    }
}
