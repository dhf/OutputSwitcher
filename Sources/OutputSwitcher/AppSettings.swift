import Foundation
import Observation

/// User preferences, persisted in UserDefaults.
@MainActor
@Observable
final class AppSettings {
    private static let showPlayingAppKey = "showPlayingApp"

    /// Show the icon of the app that is playing sound in the popover header.
    /// CoreAudio only reports that an app keeps an output open, so an app can appear while
    /// nothing is audible; this switch hides the icon.
    var showPlayingApp: Bool {
        didSet { defaults.set(showPlayingApp, forKey: Self.showPlayingAppKey) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        showPlayingApp = defaults.object(forKey: Self.showPlayingAppKey) as? Bool ?? true
    }
}
