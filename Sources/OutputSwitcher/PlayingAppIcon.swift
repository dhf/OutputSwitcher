import AppKit
import SwiftUI

/// The icon of an app that is playing sound.
struct PlayingAppIcon: View {
    let app: PlayingApp

    var body: some View {
        if let icon = NSRunningApplication(processIdentifier: app.id)?.icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .help(app.name)
        }
    }
}
