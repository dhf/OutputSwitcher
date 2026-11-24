import SwiftUI

/// An output row plus, for the active headset, its collapsible options panel.
struct OutputEntry: View {
    let manager: AudioDeviceManager
    let device: AudioOutputDevice
    @Binding var isOptionsExpanded: Bool

    private var isActive: Bool { device.isConnected && device.id == manager.defaultID }

    private var isConnecting: Bool {
        guard !device.isConnected, let address = BluetoothBattery.address(fromAudioUID: device.uid),
              let connecting = manager.connectingAddress else { return false }
        return BluetoothHeadsets.isSame(address, connecting)
    }
    private var hasOptions: Bool { isActive && !manager.listeningState.supported.isEmpty }

    var body: some View {
        VStack(alignment: .leading) {
            OutputRow(
                device: device,
                symbol: manager.icons.symbol(for: device),
                isActive: isActive,
                batteryPercent: isActive ? manager.batteryPercent : nil,
                isConnecting: isConnecting,
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
