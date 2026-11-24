import SwiftUI

/// The settings window: startup behaviour and per-device icons.
struct SettingsView: View {
    let manager: AudioDeviceManager
    let launchAtLogin: LaunchAtLogin

    var body: some View {
        Form {
            Section("General") {
                Toggle(
                    "Launch OutputSwitcher at login",
                    isOn: Binding(get: { launchAtLogin.isEnabled }, set: launchAtLogin.setEnabled)
                )

                if launchAtLogin.needsApproval {
                    Text("macOS needs your approval in System Settings → General → Login Items.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Open Login Items Settings…", action: launchAtLogin.openSystemSettings)
                }

                if let message = launchAtLogin.errorMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section {
                ForEach(manager.outputs) { device in
                    IconSettingsRow(device: device, store: manager.icons)
                }
            } header: {
                Text("Device Icons")
            } footer: {
                Text("Devices appear here while they are connected, for example AirPods once they are in use.")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 440, minHeight: 420)
        .onAppear { launchAtLogin.refresh() }
    }
}
