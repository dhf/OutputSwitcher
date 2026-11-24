import Testing
@testable import OutputSwitcher

struct AirBuddyBridgeTests {
    @Test func parsesCurrentAndSupportedModes() {
        let state = AirBuddyBridge.parse("transparency|normal,noise cancellation,transparency,adaptive")
        #expect(state.current == .transparency)
        #expect(state.supported == [.normal, .noiseCancellation, .transparency, .adaptive])
    }

    @Test func emptyOutputMeansNoModes() {
        let state = AirBuddyBridge.parse("|")
        #expect(state.current == nil)
        #expect(state.supported.isEmpty)
    }

    @Test func ignoresUnknownModeNames() {
        let state = AirBuddyBridge.parse("something new|normal,something new,adaptive")
        #expect(state.current == nil)
        #expect(state.supported == [.normal, .adaptive])
    }

    @Test func titlesMatchSystemMenu() {
        #expect(ListeningMode.normal.title == "Off")
        #expect(ListeningMode.noiseCancellation.title == "Noise Cancellation")
    }
}
