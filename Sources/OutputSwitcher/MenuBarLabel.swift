import SwiftUI

/// The status item icon: reflects the active output device and mute state.
struct MenuBarLabel: View {
    let manager: AudioDeviceManager

    var body: some View {
        Image(systemName: manager.menuBarSymbol)
            .symbolVariant(manager.isMuted ? .slash : .none)
    }
}
