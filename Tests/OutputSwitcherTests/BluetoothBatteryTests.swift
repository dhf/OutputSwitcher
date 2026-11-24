import Testing
@testable import OutputSwitcher

struct BluetoothBatteryTests {
    @Test func parsesAddressFromAudioUID() {
        #expect(BluetoothBattery.address(fromAudioUID: "70-F9-4A-8D-52-63:output") == "70-F9-4A-8D-52-63")
    }

    @Test func rejectsNonBluetoothUIDs() {
        #expect(BluetoothBattery.address(fromAudioUID: "BuiltInSpeakerDevice") == nil)
        #expect(BluetoothBattery.address(fromAudioUID: "AppleUSBAudioEngine:Vendor:Dev:1234:1") == nil)
    }

    @Test func levelIsNormalFromThirtyPercent() {
        #expect(BatteryLevel(percent: 100) == .normal)
        #expect(BatteryLevel(percent: 30) == .normal)
    }

    @Test func levelIsLowBelowThirtyPercent() {
        #expect(BatteryLevel(percent: 29) == .low)
        #expect(BatteryLevel(percent: 10) == .low)
    }

    @Test func levelIsCriticalBelowTenPercent() {
        #expect(BatteryLevel(percent: 9) == .critical)
        #expect(BatteryLevel(percent: 0) == .critical)
    }
}
