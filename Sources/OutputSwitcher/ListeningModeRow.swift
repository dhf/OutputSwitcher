import SwiftUI

/// One listening mode with a leading checkmark when selected, like the system menu.
struct ListeningModeRow: View {
    let mode: ListeningMode
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark")
                    .opacity(isSelected ? 1 : 0)
                    .frame(width: 20)

                Image(systemName: mode.symbol)
                    .frame(width: 24)

                Text(mode.title)

                Spacer()
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .contentShape(.rect)
            .background(isHovering ? Color.secondary.opacity(0.2) : Color.clear, in: .rect(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
