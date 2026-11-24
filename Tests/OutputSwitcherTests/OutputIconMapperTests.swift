import Testing
@testable import OutputSwitcher

struct OutputIconMapperTests {
    private func device(
        _ name: String, source: String? = nil, transport: AudioTransport
    ) -> AudioOutputDevice {
        AudioOutputDevice(id: 1, uid: name, name: name, dataSourceName: source, transport: transport)
    }

    @Test func airPodsMaxDiffersFromHeadphoneJack() {
        let airPods = OutputIconMapper.symbol(for: device("Daniel's AirPods Max", transport: .bluetooth))
        let jack = OutputIconMapper.symbol(for: device("Mac Studio Speakers", source: "External Headphones", transport: .builtIn))
        #expect(airPods == "airpodsmax")
        #expect(jack == "headphones")
        #expect(airPods != jack)
    }

    @Test func builtInSpeakersShowMacModel() {
        let speakers = device("Mac Studio Speakers", source: "Internal Speakers", transport: .builtIn)
        #expect(OutputIconMapper.symbol(for: speakers) == "macstudio")
    }

    @Test func displaysUseDisplaySymbol() {
        #expect(OutputIconMapper.symbol(for: device("LG UltraFine Display Audio", transport: .displayPort)) == "display")
    }

    @Test func displayNamePrefersDataSource() {
        #expect(device("Mac Studio Speakers", source: "External Headphones", transport: .builtIn).displayName == "External Headphones")
        #expect(device("Büro", transport: .airPlay).displayName == "Büro")
    }
}
