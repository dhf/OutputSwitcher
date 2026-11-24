import SwiftUI

@main
struct OutputSwitcherApp: App {
    @State private var manager = AudioDeviceManager()
    @State private var launchAtLogin = LaunchAtLogin()
    @State private var settings = AppSettings()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(manager: manager, settings: settings)
        } label: {
            MenuBarLabel(manager: manager)
        }
        .menuBarExtraStyle(.window)

        Window("OutputSwitcher Settings", id: WindowID.settings) {
            SettingsView(manager: manager, launchAtLogin: launchAtLogin, settings: settings)
        }
        .windowResizability(.contentMinSize)
        .defaultLaunchBehavior(.suppressed)
    }
}
