import Foundation
import Testing
@testable import OutputSwitcher

@MainActor
struct AppSettingsTests {
    private func makeDefaults() -> UserDefaults {
        let suite = "AppSettingsTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @Test func playingAppIsShownByDefault() {
        #expect(AppSettings(defaults: makeDefaults()).showPlayingApp)
    }

    @Test func turningItOffPersists() {
        let defaults = makeDefaults()
        AppSettings(defaults: defaults).showPlayingApp = false
        #expect(!AppSettings(defaults: defaults).showPlayingApp)
    }

    @Test func turningItBackOnPersists() {
        let defaults = makeDefaults()
        let settings = AppSettings(defaults: defaults)
        settings.showPlayingApp = false
        settings.showPlayingApp = true
        #expect(AppSettings(defaults: defaults).showPlayingApp)
    }
}
