import Testing
@testable import OutputSwitcher

struct BluetoothHeadsetsTests {
    @Test func audioUIDMatchesCoreAudioFormat() {
        #expect(BluetoothHeadsets.audioUID(forAddress: "70-f9-4a-8d-52-63") == "70-F9-4A-8D-52-63:output")
        // AirBuddy reports colon-separated addresses; they normalise to the same UID.
        #expect(BluetoothHeadsets.audioUID(forAddress: "74:77:86:01:a3:cc") == "74-77-86-01-A3-CC:output")
        let uid = BluetoothHeadsets.audioUID(forAddress: "70:f9:4a:8d:52:63")
        #expect(BluetoothBattery.address(fromAudioUID: uid) == "70-F9-4A-8D-52-63")
    }

    @Test func addressesCompareIgnoringCaseAndSeparator() {
        #expect(BluetoothHeadsets.isSame("70-f9-4a-8d-52-63", "70-F9-4A-8D-52-63"))
        #expect(BluetoothHeadsets.isSame("70:f9:4a:8d:52:63", "70-F9-4A-8D-52-63"))
        #expect(!BluetoothHeadsets.isSame("70-f9-4a-8d-52-63", "70-f9-4a-8d-52-64"))
    }

    @Test func notConnectedDevicesAreFlagged() {
        let offline = AudioOutputDevice(
            id: AudioOutputDevice.notConnectedID, uid: "AA-BB-CC-DD-EE-FF:output",
            name: "AirPods Max", dataSourceName: nil, transport: .bluetooth
        )
        let online = AudioOutputDevice(id: 42, uid: "x", name: "Speakers", dataSourceName: nil, transport: .builtIn)
        #expect(!offline.isConnected)
        #expect(online.isConnected)
    }

    @Test func parsesNearbyHeadsetLines() {
        let headsets = AirBuddyBridge.parseHeadsets("AirPods Pro|74:77:86:01:a3:cc\nAirPods Max 2 DHF|70:f9:4a:8d:52:63")
        #expect(headsets == [
            .init(name: "AirPods Pro", address: "74:77:86:01:a3:cc"),
            .init(name: "AirPods Max 2 DHF", address: "70:f9:4a:8d:52:63"),
        ])
    }

    @Test func parserSkipsMalformedLinesAndKeepsPipesInNames() {
        let headsets = AirBuddyBridge.parseHeadsets("no separator\n|74:77:86:01:a3:cc\nBad|not an address\nA|B headset|aa:bb:cc:dd:ee:ff")
        #expect(headsets == [.init(name: "A|B headset", address: "aa:bb:cc:dd:ee:ff")])
    }

    @Test func addressValidationBlocksScriptInjection() {
        #expect(AirBuddyBridge.isValidAddress("70:f9:4a:8d:52:63"))
        #expect(AirBuddyBridge.isValidAddress("70-F9-4A-8D-52-63"))
        #expect(!AirBuddyBridge.isValidAddress(""))
        #expect(!AirBuddyBridge.isValidAddress("70:f9\" & (do shell script \"x\") & \""))
    }
}
