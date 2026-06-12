import SwiftUI
import AppKit

@main
struct GazeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Pure status item scene. No main window is created automatically by SwiftUI.
        MenuBarExtra {
            AppMenuView(manager: appDelegate.manager)
        } label: {
            if let image = NSImage(named: "gaze-icon") {
                Image(nsImage: image.resized(to: NSSize(width: 22, height: 22)))
            } else {
                Image(systemName: "pencil.line")
            }
        }
    }
}

extension NSImage {
    func resized(to size: NSSize) -> NSImage {
        self.size = size
        return self
    }
}

// MARK: - App Delegate
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let manager = AppManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Explicitly set activation policy to accessory (hides Dock icon, allows click events on native full-screen spaces)
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize canvas and floating toolbar
        manager.setupWindows()
        
        // Setup global hotkeys
        manager.setupGlobalHotKeys()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        KeyboardShortcuts.unregisterAll()
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        manager.commitAllActiveTextElements()
    }
}
