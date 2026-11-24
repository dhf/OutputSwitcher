import SwiftUI

@main
struct OutputSwitcherApp: App {
    @State private var manager = AudioDeviceManager()
    @State private var launchAtLogin = LaunchAtLogin()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(manager: manager)
        } label: {
            MenuBarLabel(manager: manager)
        }
        .menuBarExtraStyle(.window)

        Window("OutputSwitcher Settings", id: WindowID.settings) {
            SettingsView(manager: manager, launchAtLogin: launchAtLogin)
        }
        .windowResizability(.contentMinSize)
        .defaultLaunchBehavior(.suppressed)
    }
}
