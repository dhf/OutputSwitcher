import AppKit

/// Reads and sets AirPods listening modes through AirBuddy's AppleScript interface.
///
/// macOS offers no public API for this (it needs an Apple-only entitlement), but AirBuddy's
/// helper app exposes `listening mode` and `set listening mode` via AppleScript. This only
/// works while AirBuddy is installed and running, and macOS asks once to allow automation.
enum AirBuddyBridge {
    static let helperBundleID = "codes.rambo.AirBuddyHelper"

    static var isRunning: Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: helperBundleID).isEmpty
    }

    /// State of the current output device, or `nil` when AirBuddy is not available.
    static func readState() -> ListeningModeState? {
        guard isRunning, let output = run(readScript) else { return nil }
        return parse(output)
    }

    @discardableResult
    static func set(_ mode: ListeningMode) -> Bool {
        guard isRunning else { return false }
        return run(setScript(for: mode)) != nil
    }

    /// Parses "<current>|<supported1>,<supported2>" as produced by `readScript`.
    static func parse(_ output: String) -> ListeningModeState {
        let parts = output.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        let current = parts.first.flatMap { ListeningMode(rawValue: $0.trimmingCharacters(in: .whitespaces)) }
        let supported = parts.dropFirst().first?
            .split(separator: ",")
            .compactMap { ListeningMode(rawValue: $0.trimmingCharacters(in: .whitespaces)) } ?? []
        return ListeningModeState(current: current, supported: supported)
    }

    // MARK: Scripts

    private static let readScript = """
    tell application id "\(helperBundleID)"
        set d to current output device
        set m to ""
        try
            set m to (listening mode of d) as text
        end try
        set AppleScript's text item delimiters to ","
        set s to ""
        try
            set s to ((supported listening modes of d) as list) as text
        end try
        return m & "|" & s
    end tell
    """

    /// `mode.rawValue` comes from a fixed enum, so it is safe to place in the script.
    private static func setScript(for mode: ListeningMode) -> String {
        """
        tell application id "\(helperBundleID)"
            set d to current output device
            set r to set listening mode \(mode.rawValue) device d
            return "ok"
        end tell
        """
    }

    private static func run(_ source: String) -> String? {
        guard let script = NSAppleScript(source: source) else { return nil }
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        return error == nil ? result.stringValue ?? "" : nil
    }
}
