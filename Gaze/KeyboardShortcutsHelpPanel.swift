import AppKit

/// A floating, activating panel for the Keyboard Shortcuts help overlay.
/// Unlike ToolbarPanel, this CAN become key so the user can close it with Escape.
class KeyboardShortcutsHelpPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        self.title = "Keyboard Shortcuts"
        self.isFloatingPanel = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 1)
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = true
        self.sharingType = .readOnly
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
