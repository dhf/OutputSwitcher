import SwiftUI

/// Mute button, volume slider and loud-speaker glyph, like the system Sound menu.
struct VolumeRow: View {
    let manager: AudioDeviceManager

    var body: some View {
        HStack {
            Button(
                manager.isMuted ? "Unmute" : "Mute",
                systemImage: manager.isMuted ? "speaker.slash.fill" : "speaker.fill",
                action: manager.toggleMute
            )
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Slider(
                value: Binding(
                    get: { Double(manager.volume) },
                    set: { manager.setVolume(Float($0)) }
                ),
                in: 0...1
            )

            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(.secondary)
        }
    }
}
