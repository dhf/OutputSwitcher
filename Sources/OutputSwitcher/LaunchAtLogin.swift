import Observation
import ServiceManagement

/// Registers the app as a login item so it starts with the Mac.
@MainActor
@Observable
final class LaunchAtLogin {
    private(set) var status: SMAppService.Status
    private(set) var errorMessage: String?

    init() {
        status = SMAppService.mainApp.status
    }

    /// True when the app will start at login (including when the user still has to approve it).
    var isEnabled: Bool {
        status == .enabled || status == .requiresApproval
    }

    var needsApproval: Bool {
        status == .requiresApproval
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        refresh()
    }

    /// Re-reads the state; the user can also change it in System Settings.
    func refresh() {
        status = SMAppService.mainApp.status
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
