import Foundation
import Testing
@testable import OutputSwitcher

@MainActor
struct IconStoreTests {
    private let device = AudioOutputDevice(
        id: 1, uid: "airpods-uid", name: "AirPods Max", dataSourceName: nil, transport: .bluetooth
    )

    private func makeDefaults() -> UserDefaults {
        let suite = "IconStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @Test func fallsBackToAutomaticIcon() {
        let store = IconStore(defaults: makeDefaults())
        #expect(store.symbol(for: device) == "airpodsmax")
        #expect(!store.hasOverride(for: device))
    }

    @Test func overrideIsUsedAndPersisted() {
        let defaults = makeDefaults()
        IconStore(defaults: defaults).setSymbol("star", for: device)

        let reloaded = IconStore(defaults: defaults)
        #expect(reloaded.symbol(for: device) == "star")
        #expect(reloaded.hasOverride(for: device))
    }

    @Test func resetRestoresAutomaticIcon() {
        let store = IconStore(defaults: makeDefaults())
        store.setSymbol("star", for: device)
        store.setSymbol(nil, for: device)
        #expect(store.symbol(for: device) == "airpodsmax")
    }

    @Test func invalidSymbolNameIsIgnored() {
        let store = IconStore(defaults: makeDefaults())
        store.setSymbol("this.symbol.does.not.exist", for: device)
        #expect(!store.hasOverride(for: device))
    }
}
