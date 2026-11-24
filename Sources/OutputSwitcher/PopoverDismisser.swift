import AppKit

/// Closes the menu bar popover. SwiftUI offers no API for this with the `.window`
/// style, so the popover's panel is found by its class name (it contains "MenuBarExtra").
@MainActor
enum PopoverDismisser {
    static func dismiss() {
        for window in NSApplication.shared.windows where isMenuBarPopover(window) {
            window.close()
        }
    }

    private static func isMenuBarPopover(_ window: NSWindow) -> Bool {
        String(describing: type(of: window)).contains("MenuBarExtra")
    }
}
