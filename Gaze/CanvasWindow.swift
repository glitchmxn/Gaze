import AppKit

class CanvasWindow: NSWindow {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Gaze Canvas"
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = true // Default is click-through
        self.level = .screenSaver
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.sharingType = .readOnly
    }
    
    var allowsKeyFocus: Bool = false
    
    // Ensure the drawing overlay never steals keyboard focus from active apps unless editing text
    override var canBecomeKey: Bool {
        return allowsKeyFocus
    }
    
    override var canBecomeMain: Bool {
        return allowsKeyFocus
    }
}
