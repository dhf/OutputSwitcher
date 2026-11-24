import Darwin

/// A process that CoreAudio reports as currently playing sound.
struct AudioProcess: Equatable, Sendable {
    let pid: pid_t
    let bundleID: String?
}
