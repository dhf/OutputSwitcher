import Testing
@testable import OutputSwitcher

struct OutputSorterTests {
    private func device(
        _ name: String, source: String? = nil, transport: AudioTransport
    ) -> AudioOutputDevice {
        AudioOutputDevice(id: 1, uid: name, name: name, dataSourceName: source, transport: transport)
    }

    @Test func ordersWiredThenWirelessThenAirPlayAlphabetically() {
        let shuffled = [
            device("Wohnzimmer", transport: .airPlay),
            device("LG ULTRAGEAR+", transport: .displayPort),
            device("AirPods Max 2 DHF", transport: .bluetooth),
            device("Büro", transport: .airPlay),
            device("External Headphones", source: "External Headphones", transport: .builtIn),
            device("LG UltraFine Display Audio", transport: .usb),
            device("Daniel’s MacBook Pro", transport: .airPlay),
            device("Mac Studio Speakers", source: "Internal Speakers", transport: .builtIn),
        ]
        let names = OutputSorter.sorted(shuffled).map(\.displayName)
        #expect(names == [
            "Internal Speakers", "External Headphones",
            "LG UltraFine Display Audio", "LG ULTRAGEAR+",
            "AirPods Max 2 DHF",
            "Büro", "Daniel’s MacBook Pro", "Wohnzimmer",
        ])
    }

    @Test func connectedAndNotConnectedHeadsetsSortTogether() {
        let devices = [
            device("Zed Headset", transport: .bluetooth),
            device("AirPods Pro", transport: .bluetooth),
        ]
        #expect(OutputSorter.sorted(devices).map(\.name) == ["AirPods Pro", "Zed Headset"])
    }
}
