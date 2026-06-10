import Cocoa
import Carbon

public enum KeyboardShortcuts {
    
    // MARK: - Types
    
    public struct Name: Hashable, RawRepresentable, Sendable {
        public let rawValue: String
        public let initialShortcut: Shortcut?
        
        public init(_ name: String, default defaultShortcut: Shortcut? = nil) {
            self.rawValue = name
            self.initialShortcut = defaultShortcut
            
            if let defaultShortcut {
                KeyboardShortcuts.setInitialShortcutIfNeeded(defaultShortcut, forRawValue: name)
            }
        }
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
            self.initialShortcut = nil
        }
    }
    
    public struct Shortcut: Hashable, Codable, Sendable {
        public let keyCode: UInt16
        public let carbonModifiers: UInt32
        
        public var modifiers: NSEvent.ModifierFlags {
            NSEvent.ModifierFlags(carbon: Int(carbonModifiers))
        }
        
        public init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
            self.keyCode = keyCode
            self.carbonModifiers = UInt32(modifiers.carbon)
        }
        
        public init(_ key: VirtualKeyCode, modifiers: NSEvent.ModifierFlags = []) {
            self.keyCode = key.rawValue
            self.carbonModifiers = UInt32(modifiers.carbon)
        }
    }
    
    // MARK: - Public API
    
    @MainActor
    public static var isEnabled: Bool {
        get { Manager.shared.isEnabled }
        set { Manager.shared.isEnabled = newValue }
    }
    
    @MainActor
    public static func onKeyDown(for name: Name, default defaultShortcut: Shortcut? = nil, action: @escaping @MainActor () -> Void) {
        Manager.shared.registerHandler(for: name, defaultShortcut: defaultShortcut, action: action)
    }
    
    @MainActor
    public static func unregisterAll() {
        Manager.shared.unregisterAll()
    }
    
    @MainActor
    public static func setShortcut(_ shortcut: Shortcut?, for name: Name) {
        Manager.shared.setShortcut(shortcut, for: name)
    }
    
    @MainActor
    public static func getShortcut(for name: Name) -> Shortcut? {
        Manager.shared.getShortcut(for: name)
    }
    
    // MARK: - Internal Storage Helper
    
    nonisolated fileprivate static let userDefaultsPrefix = "KeyboardShortcuts_"
    
    nonisolated fileprivate static func userDefaultsKey(forRawValue rawValue: String) -> String {
        "\(userDefaultsPrefix)\(rawValue)"
    }
    
    nonisolated fileprivate static func setInitialShortcutIfNeeded(_ shortcut: Shortcut, forRawValue rawValue: String) {
        let key = userDefaultsKey(forRawValue: rawValue)
        guard UserDefaults.standard.object(forKey: key) == nil else { return }
        if let encoded = try? JSONEncoder().encode(shortcut),
           let string = String(data: encoded, encoding: .utf8) {
            UserDefaults.standard.set(string, forKey: key)
        }
    }
    
    // MARK: - Manager Class
    
    @MainActor
    fileprivate final class Manager: Sendable {
        static let shared = Manager()
        
        private struct SendableHotKeyRef: @unchecked Sendable {
            let raw: EventHotKeyRef
        }
        
        private struct RegisteredShortcut {
            let hotKeyRef: SendableHotKeyRef
            let id: UInt32
        }
        
        private var registeredShortcuts: [Shortcut: RegisteredShortcut] = [:]
        private var nameHandlers: [Name: [@MainActor () -> Void]] = [:]
        private var nameToShortcutMap: [Name: Shortcut] = [:]
        
        private var eventHandlerRef: EventHandlerRef? = nil
        private var nextHotKeyID: UInt32 = 1
        private let signature: OSType = 0x475A484B // "GZHK" (Gaze HotKey)
        
        var isEnabled: Bool = true {
            didSet {
                if oldValue != isEnabled {
                    if isEnabled {
                        for (_, shortcut) in nameToShortcutMap {
                            registerCarbonHotKeyIfNeeded(for: shortcut)
                        }
                    } else {
                        for shortcut in registeredShortcuts.keys {
                            let status = UnregisterEventHotKey(registeredShortcuts[shortcut]!.hotKeyRef.raw)
                            if status != noErr {
                                print("KeyboardShortcuts: Failed to temporarily unregister hotkey (Carbon Status: \(status))")
                            }
                        }
                        registeredShortcuts.removeAll()
                    }
                }
            }
        }
        
        private init() {}
        
        func registerHandler(for name: Name, defaultShortcut: Shortcut?, action: @escaping @MainActor () -> Void) {
            setupEventHandlerIfNeeded()
            
            nameHandlers[name, default: []].append(action)
            
            // Resolve shortcut from defaults/user defaults
            let shortcut: Shortcut
            if let custom = getShortcut(for: name) {
                shortcut = custom
                nameToShortcutMap[name] = custom
            } else if let initial = name.initialShortcut {
                shortcut = initial
                nameToShortcutMap[name] = initial
            } else if let def = defaultShortcut {
                shortcut = def
                nameToShortcutMap[name] = def
            } else {
                return
            }
            
            registerCarbonHotKeyIfNeeded(for: shortcut)
        }
        
        func setShortcut(_ shortcut: Shortcut?, for name: Name) {
            let key = KeyboardShortcuts.userDefaultsKey(forRawValue: name.rawValue)
            
            let oldShortcut = nameToShortcutMap[name]
            
            if let shortcut = shortcut {
                nameToShortcutMap[name] = shortcut
                if let encoded = try? JSONEncoder().encode(shortcut),
                   let string = String(data: encoded, encoding: .utf8) {
                    UserDefaults.standard.set(string, forKey: key)
                }
                registerCarbonHotKeyIfNeeded(for: shortcut)
            } else {
                nameToShortcutMap.removeValue(forKey: name)
                UserDefaults.standard.removeObject(forKey: key)
            }
            
            if let old = oldShortcut {
                let stillUsed = nameToShortcutMap.values.contains(old)
                if !stillUsed {
                    unregisterCarbonHotKeyIfNeeded(for: old)
                }
            }
        }
        
        func getShortcut(for name: Name) -> Shortcut? {
            let key = KeyboardShortcuts.userDefaultsKey(forRawValue: name.rawValue)
            guard let string = UserDefaults.standard.string(forKey: key),
                  let data = string.data(using: .utf8) else {
                return nil
            }
            return try? JSONDecoder().decode(Shortcut.self, from: data)
        }
        
        private func registerCarbonHotKeyIfNeeded(for shortcut: Shortcut) {
            guard isEnabled else { return }
            guard registeredShortcuts[shortcut] == nil else { return }
            
            let hotKeyIDVal = nextHotKeyID
            nextHotKeyID += 1
            
            let hotKeyID = EventHotKeyID(signature: signature, id: hotKeyIDVal)
            let carbonMods = carbonModifiers(from: shortcut.modifiers)
            
            var hotKeyRef: EventHotKeyRef? = nil
            let status = RegisterEventHotKey(
                UInt32(shortcut.keyCode),
                carbonMods,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )
            
            guard status == noErr, let ref = hotKeyRef else {
                print("KeyboardShortcuts: Failed to register hotkey \(shortcut.keyCode) (Carbon Status: \(status))")
                return
            }
            
            registeredShortcuts[shortcut] = RegisteredShortcut(
                hotKeyRef: SendableHotKeyRef(raw: ref),
                id: hotKeyIDVal
            )
        }
        
        private func unregisterCarbonHotKeyIfNeeded(for shortcut: Shortcut) {
            guard let registered = registeredShortcuts.removeValue(forKey: shortcut) else { return }
            let status = UnregisterEventHotKey(registered.hotKeyRef.raw)
            if status != noErr {
                print("KeyboardShortcuts: Failed to unregister hotkey (Carbon Status: \(status))")
            }
        }
        
        func unregisterAll() {
            for registered in registeredShortcuts.values {
                UnregisterEventHotKey(registered.hotKeyRef.raw)
            }
            registeredShortcuts.removeAll()
            nameHandlers.removeAll()
            nameToShortcutMap.removeAll()
            
            if let ref = eventHandlerRef {
                RemoveEventHandler(ref)
                eventHandlerRef = nil
            }
        }
        
        fileprivate func dispatchHotkey(id: UInt32) {
            // Find shortcut matching this ID
            guard let (shortcut, _) = registeredShortcuts.first(where: { $0.value.id == id }) else { return }
            for (name, mappedShortcut) in nameToShortcutMap {
                if mappedShortcut == shortcut {
                    if let handlers = nameHandlers[name] {
                        for handler in handlers {
                            handler()
                        }
                    }
                }
            }
        }
        
        private func setupEventHandlerIfNeeded() {
            guard eventHandlerRef == nil else { return }
            
            var eventType = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )
            
            let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            var handlerRef: EventHandlerRef? = nil
            
            let status = InstallEventHandler(
                GetApplicationEventTarget(),
                hotKeyEventHandlerProc,
                1,
                &eventType,
                userData,
                &handlerRef
            )
            
            if status == noErr {
                eventHandlerRef = handlerRef
            } else {
                print("KeyboardShortcuts: Failed to install event handler (Carbon Status: \(status))")
            }
        }
        
        private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
            var carbonFlags: UInt32 = 0
            if flags.contains(.command) { carbonFlags |= UInt32(cmdKey) }
            if flags.contains(.option) { carbonFlags |= UInt32(optionKey) }
            if flags.contains(.control) { carbonFlags |= UInt32(controlKey) }
            if flags.contains(.shift) { carbonFlags |= UInt32(shiftKey) }
            return carbonFlags
        }
    }
}

// MARK: - Carbon Callback C-Function

private func hotKeyEventHandlerProc(
    nextHandler: EventHandlerCallRef?,
    theEvent: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData = userData else { return noErr }
    
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        theEvent,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )
    
    if status == noErr {
        let manager = Unmanaged<KeyboardShortcuts.Manager>.fromOpaque(userData).takeUnretainedValue()
        
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                manager.dispatchHotkey(id: hotKeyID.id)
            }
        }
    }
    
    return noErr
}

// MARK: - Extension for NSEvent.ModifierFlags Carbon Mapping

extension NSEvent.ModifierFlags {
    public init(carbon: Int) {
        var flags = NSEvent.ModifierFlags()
        if (carbon & cmdKey) != 0 { flags.insert(.command) }
        if (carbon & optionKey) != 0 { flags.insert(.option) }
        if (carbon & controlKey) != 0 { flags.insert(.control) }
        if (carbon & shiftKey) != 0 { flags.insert(.shift) }
        self = flags
    }
    
    public var carbon: Int {
        var carbonMods = 0
        if contains(.command) { carbonMods |= cmdKey }
        if contains(.option) { carbonMods |= optionKey }
        if contains(.control) { carbonMods |= controlKey }
        if contains(.shift) { carbonMods |= shiftKey }
        return carbonMods
    }
}

// MARK: - Gaze Hotkey Name Extensions

extension KeyboardShortcuts.Name {
    public static let selectCursor = Self("selectCursor", default: .init(.one, modifiers: [.option]))
    public static let selectPencil = Self("selectPencil", default: .init(.two, modifiers: [.option]))
    public static let selectHighlighter = Self("selectHighlighter", default: .init(.three, modifiers: [.option]))
    public static let selectText = Self("selectText", default: .init(.four, modifiers: [.option]))
    public static let selectSelect = Self("selectSelect", default: .init(.five, modifiers: [.option]))
    public static let selectLaser = Self("selectLaser", default: .init(.six, modifiers: [.option]))
    public static let selectEraser = Self("selectEraser", default: .init(.seven, modifiers: [.option]))
    public static let undo = Self("undo", default: .init(.eight, modifiers: [.option]))
    public static let redo = Self("redo", default: .init(.nine, modifiers: [.option]))
    public static let deleteSelection = Self("deleteSelection", default: .init(.k, modifiers: [.command, .shift]))
    public static let clearScreen = Self("clearScreen", default: .init(.minus, modifiers: [.option]))
    public static let toggleCanvasMode = Self("toggleCanvasMode", default: .init(.zero, modifiers: [.option]))
    
    // Shape tools (Cmd + Option)
    public static let shapeSquare = Self("shapeSquare", default: .init(.one, modifiers: [.command, .option]))
    public static let shapeCircle = Self("shapeCircle", default: .init(.two, modifiers: [.command, .option]))
    public static let shapeTriangle = Self("shapeTriangle", default: .init(.three, modifiers: [.command, .option]))
    public static let shapeLine = Self("shapeLine", default: .init(.four, modifiers: [.command, .option]))
    public static let shapeArrow = Self("shapeArrow", default: .init(.five, modifiers: [.command, .option]))
    
    // Extra actions
    public static let toggleTimer = Self("toggleTimer", default: .init(.t, modifiers: [.command, .option]))
    public static let toggleHUDDetached = Self("toggleHUDDetached", default: .init(.j, modifiers: [.command, .option]))
    public static let triggerCapture = Self("triggerCapture", default: .init(.c, modifiers: [.command, .option]))
    public static let toggleMirroring = Self("toggleMirroring", default: .init(.m, modifiers: [.command, .option]))
    public static let toggleToolbarVisibility = Self("toggleToolbarVisibility", default: .init(.q, modifiers: [.option]))
    
    // Dynamic selection actions (Registered/unregistered dynamically when elements are selected)
    public static let deleteSelectionBackspace = Self("deleteSelectionBackspace")
}

extension KeyboardShortcuts.Shortcut {
    public var displayName: String {
        var str = ""
        if modifiers.contains(.control) { str += "⌃" }
        if modifiers.contains(.option) { str += "⌥" }
        if modifiers.contains(.shift) { str += "⇧" }
        if modifiers.contains(.command) { str += "⌘" }
        
        switch keyCode {
        case VirtualKeyCode.one.rawValue: str += "1"
        case VirtualKeyCode.two.rawValue: str += "2"
        case VirtualKeyCode.three.rawValue: str += "3"
        case VirtualKeyCode.four.rawValue: str += "4"
        case VirtualKeyCode.five.rawValue: str += "5"
        case VirtualKeyCode.six.rawValue: str += "6"
        case VirtualKeyCode.seven.rawValue: str += "7"
        case VirtualKeyCode.eight.rawValue: str += "8"
        case VirtualKeyCode.nine.rawValue: str += "9"
        case VirtualKeyCode.zero.rawValue: str += "0"
        case VirtualKeyCode.q.rawValue: str += "Q"
        case VirtualKeyCode.w.rawValue: str += "W"
        case VirtualKeyCode.e.rawValue: str += "E"
        case VirtualKeyCode.r.rawValue: str += "R"
        case VirtualKeyCode.t.rawValue: str += "T"
        case VirtualKeyCode.y.rawValue: str += "Y"
        case VirtualKeyCode.u.rawValue: str += "U"
        case VirtualKeyCode.i.rawValue: str += "I"
        case VirtualKeyCode.o.rawValue: str += "O"
        case VirtualKeyCode.p.rawValue: str += "P"
        case VirtualKeyCode.a.rawValue: str += "A"
        case VirtualKeyCode.s.rawValue: str += "S"
        case VirtualKeyCode.d.rawValue: str += "D"
        case VirtualKeyCode.f.rawValue: str += "F"
        case VirtualKeyCode.g.rawValue: str += "G"
        case VirtualKeyCode.h.rawValue: str += "H"
        case VirtualKeyCode.j.rawValue: str += "J"
        case VirtualKeyCode.k.rawValue: str += "K"
        case VirtualKeyCode.l.rawValue: str += "L"
        case VirtualKeyCode.z.rawValue: str += "Z"
        case VirtualKeyCode.x.rawValue: str += "X"
        case VirtualKeyCode.c.rawValue: str += "C"
        case VirtualKeyCode.v.rawValue: str += "V"
        case VirtualKeyCode.b.rawValue: str += "B"
        case VirtualKeyCode.m.rawValue: str += "M"
        case VirtualKeyCode.space.rawValue: str += "Space"
        case VirtualKeyCode.escape.rawValue: str += "Esc"
        case VirtualKeyCode.delete.rawValue: str += "⌫"
        case VirtualKeyCode.minus.rawValue: str += "-"
        case VirtualKeyCode.equals.rawValue: str += "="
        case VirtualKeyCode.comma.rawValue: str += ","
        case VirtualKeyCode.dot.rawValue: str += "."
        case VirtualKeyCode.slash.rawValue: str += "/"
        case VirtualKeyCode.semicolon.rawValue: str += ";"
        case VirtualKeyCode.quote.rawValue: str += "'"
        case VirtualKeyCode.bracketLeft.rawValue: str += "["
        case VirtualKeyCode.bracketRight.rawValue: str += "]"
        case VirtualKeyCode.backslash.rawValue: str += "\\"
        case VirtualKeyCode.tab.rawValue: str += "⇥"
        case VirtualKeyCode.`return`.rawValue: str += "↩"
        case VirtualKeyCode.leftArrow.rawValue: str += "←"
        case VirtualKeyCode.rightArrow.rawValue: str += "→"
        case VirtualKeyCode.upArrow.rawValue: str += "↑"
        case VirtualKeyCode.downArrow.rawValue: str += "↓"
        default:
            if let key = VirtualKeyCode(rawValue: keyCode) {
                str += String(describing: key).uppercased()
            } else {
                str += "?"
            }
        }
        return str
    }
}


