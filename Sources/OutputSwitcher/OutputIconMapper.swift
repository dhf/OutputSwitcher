/// Chooses the SF Symbol shown for a device. Edit the rules here to change icons.
enum OutputIconMapper {
    static func symbol(for device: AudioOutputDevice) -> String {
        let name = device.name.lowercased()
        let source = (device.dataSourceName ?? "").lowercased()

        // Specific products first, so AirPods Max and the headphone jack differ.
        if name.contains("airpods max") { return "airpodsmax" }
        if name.contains("airpods pro") { return "airpodspro" }
        if name.contains("airpods") { return "airpods" }
        if name.contains("homepod") { return "homepod" }
        if name.contains("beats") { return "beats.headphones" }

        if source.contains("headphone") { return "headphones" }

        // Built-in speakers: show the Mac model like the system menu does.
        if device.transport == .builtIn {
            if name.contains("mac studio") { return "macstudio" }
            if name.contains("mac mini") { return "macmini" }
            if name.contains("macbook") { return "laptopcomputer" }
        }

        switch device.transport {
        case .bluetooth: return "headphones.circle"
        case .hdmi, .displayPort: return "display"
        case .airPlay: return "airplayaudio"
        case .aggregate: return "square.stack.3d.up"
        case .usb: return "hifispeaker"
        case .builtIn, .virtual, .other: return "speaker.wave.2"
        }
    }
}
