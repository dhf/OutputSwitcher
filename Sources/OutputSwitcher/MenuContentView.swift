import SwiftUI

/// Popover content modelled on the system Sound menu: volume, outputs, settings links.
struct MenuContentView: View {
    let manager: AudioDeviceManager

    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    @State private var isOptionsExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Sound")
                .font(.headline)

            VolumeRow(manager: manager)

            Divider()

            Text("Output")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                ForEach(manager.outputs) { device in
                    OutputEntry(manager: manager, device: device, isOptionsExpanded: $isOptionsExpanded)
                }
            }

            Divider()

            VStack(alignment: .leading) {
                if let active = manager.activeDevice, active.transport == .bluetooth {
                    MenuLinkRow(title: "\(active.name) Settings…") {
                        PopoverDismisser.dismiss()
                        openURL(SystemSettingsPane.bluetooth.url)
                    }
                }
                MenuLinkRow(title: "Sound Settings…") {
                    PopoverDismisser.dismiss()
                    openURL(SystemSettingsPane.sound.url)
                }

                Divider()

                MenuLinkRow(title: "OutputSwitcher Settings…") {
                    PopoverDismisser.dismiss()
                    openWindow(id: WindowID.settings)
                    NSApplication.shared.activate()
                }
                MenuLinkRow(title: "Quit OutputSwitcher") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 310)
        .task {
            // Keep battery and listening mode fresh while the popover is on screen.
            while !Task.isCancelled {
                manager.refreshAccessoryState()
                try? await Task.sleep(for: .seconds(10))
            }
        }
    }
}
