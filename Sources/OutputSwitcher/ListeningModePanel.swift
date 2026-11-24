import SwiftUI

/// The expanded options under an AirPods row: a "Listening Mode" header and its modes.
struct ListeningModePanel: View {
    let manager: AudioDeviceManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Listening Mode")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)

            ForEach(manager.listeningState.supported, id: \.self) { mode in
                ListeningModeRow(mode: mode, isSelected: mode == manager.listeningState.current) {
                    manager.setListeningMode(mode)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.15), in: .rect(cornerRadius: 8))
    }
}
