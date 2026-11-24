import CoreAudio

/// How a device is connected to the Mac.
enum AudioTransport: Sendable, Equatable {
    case builtIn, bluetooth, usb, hdmi, displayPort, airPlay, aggregate, virtual, other

    init(rawValue: UInt32) {
        switch rawValue {
        case kAudioDeviceTransportTypeBuiltIn: self = .builtIn
        case kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE: self = .bluetooth
        case kAudioDeviceTransportTypeUSB: self = .usb
        case kAudioDeviceTransportTypeHDMI: self = .hdmi
        case kAudioDeviceTransportTypeDisplayPort: self = .displayPort
        case kAudioDeviceTransportTypeAirPlay: self = .airPlay
        case kAudioDeviceTransportTypeAggregate: self = .aggregate
        case kAudioDeviceTransportTypeVirtual: self = .virtual
        default: self = .other
        }
    }
}

/// A snapshot of one audio device that can play sound.
struct AudioOutputDevice: Identifiable, Equatable, Sendable {
    let id: AudioObjectID
    let uid: String
    let name: String
    /// Active data source of the device, e.g. "External Headphones" for the headphone jack.
    let dataSourceName: String?
    let transport: AudioTransport

    /// Name shown to the user; the data source is more specific for built-in outputs.
    var displayName: String { dataSourceName ?? name }
}
