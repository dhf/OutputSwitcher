import CoreAudio
import Foundation

/// Thin, stateless wrappers around the CoreAudio property API.
enum CoreAudioProperties {
    /// 'vmvc': the device's virtual main volume (what the system volume keys change).
    static let virtualMainVolume: AudioObjectPropertySelector = 0x766D_7663

    static func address(
        _ selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
    }

    // MARK: Generic access

    static func has(_ id: AudioObjectID, _ address: AudioObjectPropertyAddress) -> Bool {
        var address = address
        return AudioObjectHasProperty(id, &address)
    }

    static func value<T: BitwiseCopyable>(
        of id: AudioObjectID, _ address: AudioObjectPropertyAddress, initial: T
    ) -> T? {
        var address = address
        guard AudioObjectHasProperty(id, &address) else { return nil }
        var result = initial
        var size = UInt32(MemoryLayout<T>.size)
        let status = AudioObjectGetPropertyData(id, &address, 0, nil, &size, &result)
        return status == noErr ? result : nil
    }

    @discardableResult
    static func set<T: BitwiseCopyable>(
        _ value: T, on id: AudioObjectID, _ address: AudioObjectPropertyAddress
    ) -> Bool {
        var address = address
        var settable: DarwinBoolean = false
        guard AudioObjectHasProperty(id, &address),
              AudioObjectIsPropertySettable(id, &address, &settable) == noErr,
              settable.boolValue else { return false }
        var value = value
        return AudioObjectSetPropertyData(id, &address, 0, nil, UInt32(MemoryLayout<T>.size), &value) == noErr
    }

    static func string(of id: AudioObjectID, _ address: AudioObjectPropertyAddress) -> String? {
        var address = address
        guard AudioObjectHasProperty(id, &address) else { return nil }
        var reference: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        guard AudioObjectGetPropertyData(id, &address, 0, nil, &size, &reference) == noErr else { return nil }
        return reference?.takeRetainedValue() as String?
    }

    static func objectIDs(of id: AudioObjectID, _ address: AudioObjectPropertyAddress) -> [AudioObjectID] {
        var address = address
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size) == noErr, size > 0 else { return [] }
        var ids = [AudioObjectID](repeating: 0, count: Int(size) / MemoryLayout<AudioObjectID>.size)
        let status = ids.withUnsafeMutableBytes {
            AudioObjectGetPropertyData(id, &address, 0, nil, &size, $0.baseAddress!)
        }
        return status == noErr ? ids : []
    }

    // MARK: Devices

    static func allOutputDevices() -> [AudioOutputDevice] {
        let system = AudioObjectID(kAudioObjectSystemObject)
        return objectIDs(of: system, address(kAudioHardwarePropertyDevices))
            .filter(hasOutput)
            .compactMap(device)
    }

    static func hasOutput(_ id: AudioObjectID) -> Bool {
        var address = address(kAudioDevicePropertyStreams, scope: kAudioObjectPropertyScopeOutput)
        var size: UInt32 = 0
        return AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size) == noErr && size > 0
    }

    static func device(_ id: AudioObjectID) -> AudioOutputDevice? {
        guard let name = string(of: id, address(kAudioObjectPropertyName)),
              let uid = string(of: id, address(kAudioDevicePropertyDeviceUID)) else { return nil }
        if let hidden: UInt32 = value(of: id, address(kAudioDevicePropertyIsHidden), initial: 0), hidden != 0 {
            return nil
        }
        let transport: UInt32 = value(of: id, address(kAudioDevicePropertyTransportType), initial: 0) ?? 0
        return AudioOutputDevice(
            id: id, uid: uid, name: name,
            dataSourceName: dataSourceName(of: id),
            transport: AudioTransport(rawValue: transport)
        )
    }

    static func dataSourceName(of id: AudioObjectID) -> String? {
        let scope = kAudioObjectPropertyScopeOutput
        guard var source: UInt32 = value(of: id, address(kAudioDevicePropertyDataSource, scope: scope), initial: 0)
        else { return nil }
        var nameAddress = address(kAudioDevicePropertyDataSourceNameForIDCFString, scope: scope)
        var reference: Unmanaged<CFString>?
        let status = withUnsafeMutablePointer(to: &source) { sourcePointer in
            withUnsafeMutablePointer(to: &reference) { referencePointer in
                var translation = AudioValueTranslation(
                    mInputData: UnsafeMutableRawPointer(sourcePointer),
                    mInputDataSize: UInt32(MemoryLayout<UInt32>.size),
                    mOutputData: UnsafeMutableRawPointer(referencePointer),
                    mOutputDataSize: UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
                )
                var size = UInt32(MemoryLayout<AudioValueTranslation>.size)
                return AudioObjectGetPropertyData(id, &nameAddress, 0, nil, &size, &translation)
            }
        }
        guard status == noErr else { return nil }
        return reference?.takeRetainedValue() as String?
    }

    // MARK: Default output

    static func defaultOutputID() -> AudioObjectID {
        value(of: AudioObjectID(kAudioObjectSystemObject), address(kAudioHardwarePropertyDefaultOutputDevice), initial: 0) ?? 0
    }

    static func setDefaultOutput(_ id: AudioObjectID) {
        let system = AudioObjectID(kAudioObjectSystemObject)
        set(id, on: system, address(kAudioHardwarePropertyDefaultOutputDevice))
        set(id, on: system, address(kAudioHardwarePropertyDefaultSystemOutputDevice))
    }

    // MARK: Volume and mute

    private static let output = kAudioObjectPropertyScopeOutput

    static func volume(of id: AudioObjectID) -> Float? {
        for selector in [virtualMainVolume, kAudioDevicePropertyVolumeScalar] {
            if let v: Float32 = value(of: id, address(selector, scope: output), initial: 0) { return v }
        }
        let channels = (1...2).compactMap { channel -> Float32? in
            value(of: id, address(kAudioDevicePropertyVolumeScalar, scope: output, element: channel), initial: 0)
        }
        return channels.isEmpty ? nil : channels.reduce(0, +) / Float(channels.count)
    }

    static func setVolume(_ volume: Float, of id: AudioObjectID) {
        let volume = Float32(min(max(volume, 0), 1))
        if set(volume, on: id, address(virtualMainVolume, scope: output)) { return }
        if set(volume, on: id, address(kAudioDevicePropertyVolumeScalar, scope: output)) { return }
        for channel: AudioObjectPropertyElement in 1...2 {
            set(volume, on: id, address(kAudioDevicePropertyVolumeScalar, scope: output, element: channel))
        }
    }

    static func isMuted(_ id: AudioObjectID) -> Bool {
        let muted: UInt32 = value(of: id, address(kAudioDevicePropertyMute, scope: output), initial: 0)
            ?? value(of: id, address(kAudioDevicePropertyMute, scope: output, element: 1), initial: 0)
            ?? 0
        return muted != 0
    }

    static func setMuted(_ muted: Bool, of id: AudioObjectID) {
        let flag: UInt32 = muted ? 1 : 0
        if set(flag, on: id, address(kAudioDevicePropertyMute, scope: output)) { return }
        for channel: AudioObjectPropertyElement in 1...2 {
            set(flag, on: id, address(kAudioDevicePropertyMute, scope: output, element: channel))
        }
    }

    /// Property addresses on a device whose changes should refresh the UI.
    static func watchedDeviceAddresses() -> [AudioObjectPropertyAddress] {
        var result: [AudioObjectPropertyAddress] = []
        for selector in [virtualMainVolume, kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyMute] {
            for element in [kAudioObjectPropertyElementMain, 1, 2] {
                result.append(address(selector, scope: output, element: element))
            }
        }
        result.append(address(kAudioDevicePropertyDataSource, scope: output))
        return result
    }
}
