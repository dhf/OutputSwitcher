import SwiftUI

/// One device in the icon settings window.
struct IconSettingsRow: View {
    let device: AudioOutputDevice
    let store: IconStore

    @State private var isPickerShown = false

    var body: some View {
        HStack {
            Image(systemName: store.symbol(for: device))
                .imageScale(.large)
                .frame(width: 34, height: 34)
                .background(Color.secondary.opacity(0.3), in: .circle)

            VStack(alignment: .leading) {
                Text(device.displayName)
                Text(store.hasOverride(for: device) ? "Custom icon" : "Automatic icon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Change…") { isPickerShown = true }
                .popover(isPresented: $isPickerShown) {
                    SymbolPickerView(device: device, store: store)
                }
        }
    }
}
