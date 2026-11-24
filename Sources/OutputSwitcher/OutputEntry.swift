import SwiftUI

/// An output row plus, for the active headset, its collapsible options panel.
struct OutputEntry: View {
    let manager: AudioDeviceManager
    let device: AudioOutputDevice
    @Binding var isOptionsExpanded: Bool

    private var isActive: Bool { device.id == manager.defaultID }
    private var hasOptions: Bool { isActive && !manager.listeningState.supported.isEmpty }

    var body: some View {
        VStack(alignment: .leading) {
            OutputRow(
                device: device,
                symbol: manager.icons.symbol(for: device),
                isActive: isActive,
                batteryPercent: isActive ? manager.batteryPercent : nil,
                isExpanded: isOptionsExpanded,
                toggleExpanded: hasOptions ? { withAnimation { isOptionsExpanded.toggle() } } : nil
            ) {
                manager.select(device)
            }

            if hasOptions && isOptionsExpanded {
                ListeningModePanel(manager: manager)
            }
        }
    }
}
