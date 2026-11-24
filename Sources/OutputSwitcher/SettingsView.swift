import SwiftUI

/// The settings window: startup behaviour and per-device icons.
struct SettingsView: View {
    let manager: AudioDeviceManager
    let launchAtLogin: LaunchAtLogin
    @Bindable var settings: AppSettings

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
                Toggle("Show the app playing sound in the header", isOn: $settings.showPlayingApp)
            } header: {
                Text("Popover")
            } footer: {
                Text("macOS only reports that an app keeps an audio output open, even when it is silent, so an app's icon can appear while nothing is audible. Turn this off to hide it.")
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
