import Darwin

/// A running app that is currently playing sound on the active output.
struct PlayingApp: Identifiable, Equatable {
    /// Process identifier of the app itself (not of one of its helper processes).
    let id: pid_t
    let name: String
}
