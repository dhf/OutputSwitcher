import SwiftUI

/// "Sound" title with, on the right, the output format and the icons of the apps playing sound.
struct SoundHeader: View {
    let manager: AudioDeviceManager
    let showPlayingApp: Bool

    var body: some View {
        HStack {
            Text("Sound")
                .font(.headline)

            Spacer()

            if let format = manager.outputFormatLabel {
                Text(format)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)
            }

            if showPlayingApp {
                ForEach(manager.playingApps.prefix(3)) { app in
                    PlayingAppIcon(app: app)
                }
            }
        }
    }
}
