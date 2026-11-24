import SwiftUI

/// Popover with a grid of symbols, a field for any SF Symbol name, and a reset button.
struct SymbolPickerView: View {
    let device: AudioOutputDevice
    let store: IconStore

    @State private var customName = ""

    private let columns = [GridItem(.adaptive(minimum: 40))]

    var body: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: columns) {
                ForEach(SymbolCatalog.suggestions, id: \.self) { name in
                    Button {
                        store.setSymbol(name, for: device)
                    } label: {
                        Image(systemName: name)
                            .imageScale(.large)
                            .foregroundStyle(isSelected(name) ? Color.white : Color.primary)
                            .frame(width: 36, height: 36)
                            .background(isSelected(name) ? Color.accentColor : Color.secondary.opacity(0.2), in: .circle)
                    }
                    .buttonStyle(.plain)
                    .help(name)
                }
            }

            Divider()

            HStack {
                TextField("Any SF Symbol name", text: $customName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(applyCustomName)
                Button("Use", action: applyCustomName)
                    .disabled(!SymbolCatalog.isValid(customName))
            }

            Button("Automatic") {
                store.setSymbol(nil, for: device)
            }
            .disabled(!store.hasOverride(for: device))
        }
        .padding()
        .frame(width: 320)
    }

    private func isSelected(_ name: String) -> Bool {
        store.symbol(for: device) == name
    }

    private func applyCustomName() {
        store.setSymbol(customName, for: device)
    }
}
