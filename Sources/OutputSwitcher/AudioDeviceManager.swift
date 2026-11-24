import CoreAudio
import Foundation
import Observation

/// Observable model of the Mac's audio outputs: list, default device, volume and mute.
@MainActor
@Observable
final class AudioDeviceManager {
    private(set) var outputs: [AudioOutputDevice] = []
    /// Paired headphones that are not connected to this Mac (shown so they can be connected).
    private(set) var disconnectedHeadsets: [AudioOutputDevice] = []
    /// Bluetooth address of a headset we are connecting to; it becomes the output once it shows up.
    private(set) var connectingAddress: String?
    private(set) var defaultID: AudioObjectID = 0
    private(set) var volume: Float = 0
    private(set) var isMuted = false
    /// Battery of the active device, when it is a Bluetooth device that reports one.
    private(set) var batteryPercent: Int?
    /// Apps currently playing sound on the active output.
    private(set) var playingApps: [PlayingApp] = []
    private(set) var outputChannelCount: Int?
    /// Listening mode of the active headset (needs AirBuddy; unavailable otherwise).
    private(set) var listeningState = ListeningModeState.unavailable

    var activeDevice: AudioOutputDevice? { outputs.first { $0.id == defaultID } }

    /// Connected outputs plus headsets that can be connected, in the system menu's order.
    var displayedDevices: [AudioOutputDevice] {
        OutputSorter.sorted(outputs + disconnectedHeadsets.filter { !isConnectedOutput($0) })
    }

    /// True when a connected output has the same Bluetooth address as this placeholder row.
    private func isConnectedOutput(_ headset: AudioOutputDevice) -> Bool {
        guard let address = BluetoothBattery.address(fromAudioUID: headset.uid) else { return false }
        return outputs.contains {
            BluetoothBattery.address(fromAudioUID: $0.uid).map { BluetoothHeadsets.isSame($0, address) } ?? false
        }
    }

    /// SF Symbol for the menu bar item.
    var menuBarSymbol: String {
        activeDevice.map(icons.symbol(for:)) ?? "speaker.slash"
    }

    /// User-chosen icon overrides.
    let icons: IconStore

    private typealias Listener = (id: AudioObjectID, address: AudioObjectPropertyAddress, block: AudioObjectPropertyListenerBlock)

    @ObservationIgnored private var systemListeners: [Listener] = []
    @ObservationIgnored private var deviceListeners: [Listener] = []
    @ObservationIgnored private var watchedDeviceID: AudioObjectID = 0

    init(icons: IconStore = IconStore()) {
        self.icons = icons
        let system = AudioObjectID(kAudioObjectSystemObject)
        systemListeners = [
            makeListener(on: system, CoreAudioProperties.address(kAudioHardwarePropertyDevices)),
            makeListener(on: system, CoreAudioProperties.address(kAudioHardwarePropertyDefaultOutputDevice)),
        ]
        refresh()
    }

    // MARK: Actions

    func select(_ device: AudioOutputDevice) {
        guard device.isConnected else {
            connect(device)
            return
        }
        CoreAudioProperties.setDefaultOutput(device.id)
        refresh()
        refreshAccessoryState()
    }

    /// Connects a paired headset (e.g. AirPods in use on an iPhone). When its audio device appears,
    /// `refresh()` makes it the output.
    private func connect(_ headset: AudioOutputDevice) {
        guard let address = BluetoothBattery.address(fromAudioUID: headset.uid) else { return }
        connectingAddress = address
        BluetoothHeadsets.connect(toAddress: address)
        Task {
            // Give up after a while so the spinner never hangs.
            try? await Task.sleep(for: .seconds(20))
            if connectingAddress == address { connectingAddress = nil }
        }
    }

    /// Switches to the headset we are connecting to as soon as it is an audio device.
    private func completePendingConnection() {
        guard let address = connectingAddress,
              let device = outputs.first(where: {
                  BluetoothBattery.address(fromAudioUID: $0.uid).map { BluetoothHeadsets.isSame($0, address) } ?? false
              }) else { return }
        connectingAddress = nil
        CoreAudioProperties.setDefaultOutput(device.id)
    }

    func setVolume(_ newValue: Float) {
        guard defaultID != 0 else { return }
        if isMuted && newValue > 0 { CoreAudioProperties.setMuted(false, of: defaultID) }
        CoreAudioProperties.setVolume(newValue, of: defaultID)
        refresh()
    }

    func toggleMute() {
        guard defaultID != 0 else { return }
        CoreAudioProperties.setMuted(!isMuted, of: defaultID)
        refresh()
    }

    // MARK: State

    private func refresh() {
        outputs = CoreAudioProperties.allOutputDevices()
        defaultID = CoreAudioProperties.defaultOutputID()
        volume = CoreAudioProperties.volume(of: defaultID) ?? 0
        isMuted = CoreAudioProperties.isMuted(defaultID)
        // Drop placeholder rows for headsets that just became real outputs.
        let remaining = disconnectedHeadsets.filter { !isConnectedOutput($0) }
        if remaining != disconnectedHeadsets { disconnectedHeadsets = remaining }
        refreshBattery()
        watchDevice(defaultID)
        completePendingConnection()
    }

    /// Battery changes raise no CoreAudio event, so the popover calls this periodically.
    func refreshBattery() {
        batteryPercent = activeDevice.flatMap(BluetoothBattery.percent(for:))
    }

    /// "Stereo", "Mono"… for the header; `nil` when unknown.
    var outputFormatLabel: String? {
        outputChannelCount.flatMap(OutputFormat.label(forChannelCount:))
    }

    /// Which apps play sound, and in which channel layout. CoreAudio raises no event for
    /// the process list here, so the popover polls this while it is open.
    func refreshPlayback(includingApps: Bool = true) {
        guard defaultID != 0 else {
            if !playingApps.isEmpty { playingApps = [] }
            outputChannelCount = nil
            return
        }
        // Skip the process lookup entirely when the header icon is switched off.
        let apps = includingApps
            ? PlayingAppResolver.apps(for: CoreAudioProperties.outputProcesses(on: defaultID))
            : []
        if apps != playingApps { playingApps = apps }
        let channels = CoreAudioProperties.outputChannelCount(of: defaultID)
        if channels != outputChannelCount { outputChannelCount = channels }
    }

    /// Refreshes battery and listening mode. Called periodically while the popover is open.
    func refreshAccessoryState() {
        refreshBattery()
        let headsets = BluetoothHeadsets.disconnected(excluding: outputs)
        if headsets != disconnectedHeadsets { disconnectedHeadsets = headsets }
        if activeDevice?.transport == .bluetooth {
            listeningState = AirBuddyBridge.readState() ?? .unavailable
        } else {
            listeningState = .unavailable
        }
    }

    func setListeningMode(_ mode: ListeningMode) {
        guard AirBuddyBridge.set(mode) else { return }
        listeningState.current = mode
        Task {
            // Give the headset a moment, then confirm what it really switched to.
            try? await Task.sleep(for: .seconds(1))
            refreshAccessoryState()
        }
    }

    /// Re-targets the volume/mute/data-source listeners to the current default device.
    private func watchDevice(_ id: AudioObjectID) {
        guard id != watchedDeviceID else { return }
        for listener in deviceListeners {
            var address = listener.address
            AudioObjectRemovePropertyListenerBlock(listener.id, &address, DispatchQueue.main, listener.block)
        }
        deviceListeners = []
        watchedDeviceID = id
        guard id != 0 else { return }
        deviceListeners = CoreAudioProperties.watchedDeviceAddresses()
            .filter { CoreAudioProperties.has(id, $0) }
            .map { makeListener(on: id, $0) }
    }

    private func makeListener(on id: AudioObjectID, _ address: AudioObjectPropertyAddress) -> Listener {
        let block: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            Task { @MainActor in self?.refresh() }
        }
        var address = address
        // CoreAudio requires a dispatch queue here; the callback immediately hops to the main actor.
        AudioObjectAddPropertyListenerBlock(id, &address, DispatchQueue.main, block)
        return (id, address, block)
    }
}
