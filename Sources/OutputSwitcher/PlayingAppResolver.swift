import AppKit

/// Maps audio-producing processes to the regular apps the user knows.
///
/// Sound is often played by a helper (Safari's `com.apple.WebKit.GPU`, Chrome or Electron helpers),
/// so each process is traced back to its owning app.
@MainActor
enum PlayingAppResolver {
    static func apps(for processes: [AudioProcess]) -> [PlayingApp] {
        let regularApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
        let ownPID = ProcessInfo.processInfo.processIdentifier
        var seen = Set<pid_t>()
        var result: [PlayingApp] = []

        for process in processes where process.pid != ownPID {
            guard let app = owner(of: process, among: regularApps),
                  seen.insert(app.processIdentifier).inserted else { continue }
            result.append(PlayingApp(
                id: app.processIdentifier,
                name: app.localizedName ?? app.bundleIdentifier ?? "App"
            ))
        }
        return result
    }

    /// The bundle identifier from `candidates` that owns `bundleID`: equal to it, or a prefix
    /// followed by a dot (`com.google.Chrome` owns `com.google.Chrome.helper.Renderer`).
    /// The longest match wins.
    nonisolated static func parentBundleID(of bundleID: String, candidates: [String]) -> String? {
        candidates
            .filter { bundleID == $0 || bundleID.hasPrefix($0 + ".") }
            .max { $0.count < $1.count }
    }

    private static func owner(of process: AudioProcess, among apps: [NSRunningApplication]) -> NSRunningApplication? {
        if let app = apps.first(where: { $0.processIdentifier == process.pid }) { return app }

        if let responsible = responsiblePID(for: process.pid),
           let app = apps.first(where: { $0.processIdentifier == responsible }) { return app }

        if let bundleID = process.bundleID,
           let match = parentBundleID(of: bundleID, candidates: apps.compactMap(\.bundleIdentifier)) {
            return apps.first { $0.bundleIdentifier == match }
        }
        return nil
    }

    /// The app macOS holds responsible for a process (what Activity Monitor groups by).
    /// Looked up at runtime because the function is not in any public header.
    private static func responsiblePID(for pid: pid_t) -> pid_t? {
        typealias Function = @convention(c) (pid_t) -> pid_t
        guard let symbol = dlsym(dlopen(nil, RTLD_NOW), "responsibility_get_pid_responsible_for_pid") else {
            return nil
        }
        let responsible = unsafeBitCast(symbol, to: Function.self)(pid)
        return responsible > 0 ? responsible : nil
    }
}
