import SwiftUI

/// A plain text row with a hover highlight, used for settings links and Quit.
struct MenuLinkRow: View {
    let title: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
                .padding(.horizontal, 6)
                .contentShape(.rect)
                .background(isHovering ? Color.secondary.opacity(0.2) : Color.clear, in: .rect(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
