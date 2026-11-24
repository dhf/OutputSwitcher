import Testing
@testable import OutputSwitcher

struct PlaybackInfoTests {
    @Test func channelCountLabels() {
        #expect(OutputFormat.label(forChannelCount: 0) == nil)
        #expect(OutputFormat.label(forChannelCount: 1) == "Mono")
        #expect(OutputFormat.label(forChannelCount: 2) == "Stereo")
        #expect(OutputFormat.label(forChannelCount: 6) == "6 Channels")
    }

    @Test func helperBundleIDResolvesToItsApp() {
        let apps = ["com.google.Chrome", "com.apple.Safari", "com.apple"]
        #expect(PlayingAppResolver.parentBundleID(of: "com.google.Chrome.helper.Renderer", candidates: apps) == "com.google.Chrome")
        #expect(PlayingAppResolver.parentBundleID(of: "com.apple.Safari", candidates: apps) == "com.apple.Safari")
    }

    @Test func longestMatchingPrefixWins() {
        let apps = ["com.tinyspeck", "com.tinyspeck.slackmacgap"]
        #expect(PlayingAppResolver.parentBundleID(of: "com.tinyspeck.slackmacgap.helper", candidates: apps) == "com.tinyspeck.slackmacgap")
    }

    @Test func similarNamesDoNotMatch() {
        #expect(PlayingAppResolver.parentBundleID(of: "com.google.ChromeBeta", candidates: ["com.google.Chrome"]) == nil)
        #expect(PlayingAppResolver.parentBundleID(of: "com.apple.WebKit.GPU", candidates: ["com.apple.Safari"]) == nil)
    }
}
