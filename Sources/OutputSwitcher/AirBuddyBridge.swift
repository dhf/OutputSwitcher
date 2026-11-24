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

    /// A headset AirBuddy sees nearby that is not connected to this Mac.
    struct NearbyHeadset: Equatable, Sendable {
        let name: String
        /// Bluetooth address as AirBuddy reports it (lowercase, colon separated).
        let address: String
    }

    /// Headsets that are in range but not connected here, e.g. AirPods in use on an iPhone.
    static func readNearbyHeadsets() -> [NearbyHeadset] {
        guard isRunning, let output = run(nearbyHeadsetsScript) else { return [] }
        return parseHeadsets(output)
    }

    /// Asks AirBuddy to connect a headset by Bluetooth address. Blocks until AirBuddy reports
    /// the result (several seconds), so call it off the main thread.
    @discardableResult
    static func connect(address: String) -> Bool {
        guard isRunning, isValidAddress(address) else { return false }
        return run(connectScript(address: address)) != nil
    }

    /// Parses lines of "<name>|<address>" as produced by `nearbyHeadsetsScript`.
    static func parseHeadsets(_ output: String) -> [NearbyHeadset] {
        output.split(whereSeparator: \.isNewline).compactMap { line in
            guard let separator = line.lastIndex(of: "|") else { return nil }
            let name = line[..<separator].trimmingCharacters(in: .whitespaces)
            let address = line[line.index(after: separator)...].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty, isValidAddress(address) else { return nil }
            return NearbyHeadset(name: name, address: address)
        }
    }

    /// Only hex digits and separators, so an address can never inject script text.
    static func isValidAddress(_ address: String) -> Bool {
        !address.isEmpty && address.allSatisfy { $0.isHexDigit || $0 == ":" || $0 == "-" }
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

    private static let nearbyHeadsetsScript = """
    tell application id "\(helperBundleID)"
        set l to live devices
        set out to {}
        repeat with i from 1 to (count of l)
            set d to item i of l
            try
                if (kind of d as text) is "headset" and (nearby of d) and not (connected of d) then
                    -- Only headsets in use elsewhere (playing, or worn); idle ones in a case are not offered.
                    set inUse to ((audio state of d as text) is not "idle")
                    try
                        if (any bud in ear of d) then set inUse to true
                    end try
                    if inUse then set end of out to (name of d) & "|" & (address of d)
                end if
            end try
        end repeat
        set AppleScript's text item delimiters to linefeed
        return out as text
    end tell
    """

    /// `address` must pass `isValidAddress`, so it is safe to place in the script.
    private static func connectScript(address: String) -> String {
        """
        tell application id "\(helperBundleID)"
            connect device "\(address)"
            return "ok"
        end tell
        """
    }

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
