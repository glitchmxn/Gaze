import SwiftUI
import Combine
import AppKit

enum Tool: String, CaseIterable {
    case cursor
    case pencil
    case highlighter
    case shape
    case select
    case text
    case eraser
    case laser


    var iconName: String {
        switch self {
        case .cursor:     return "pointer.arrow.ipad"
        case .pencil:     return "pencil.tip"
        case .highlighter: return "highlighter"
        case .shape:      return "square"
        case .select:     return "lasso"
        case .text:       return "character.text.justify"
        case .eraser:     return "eraser"
        case .laser:      return "smallcircle.filled.circle"
        }
    }
}

enum LaserMode: String, CaseIterable, Identifiable {
    case trail
    case dot
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .trail: return "Trail"
        case .dot: return "Laser Dot"
        }
    }
}

enum ShapeType: String, CaseIterable, Identifiable {
    case square
    case circle
    case triangle
    case line
    case arrow
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .square: return "square"
        case .circle: return "circle"
        case .triangle: return "triangle"
        case .line: return "line.diagonal"
        case .arrow: return "arrow.up.right"
        }
    }
}

enum CanvasColor: String, CaseIterable, Identifiable {
    case none, white, dark, chalkboard, paper, blueprint, sage, obsidian, sand, mint, lavender, clay, midnight, rose, stone, amber, ocean, slate, charcoal, cream, forest, lilac, terracotta, ice, steel, mustard, coral, plum, olive, sky
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .none: return "None"
        case .white: return "White"
        case .dark: return "Dark"
        case .chalkboard: return "Chalkboard"
        case .paper: return "Paper"
        case .blueprint: return "Blueprint"
        case .sage: return "Sage"
        case .obsidian: return "Obsidian"
        case .sand: return "Sand"
        case .mint: return "Mint"
        case .lavender: return "Lavender"
        case .clay: return "Clay"
        case .midnight: return "Midnight"
        case .rose: return "Rose"
        case .stone: return "Stone"
        case .amber: return "Amber"
        case .ocean: return "Ocean"
        case .slate: return "Slate"
        case .charcoal: return "Charcoal"
        case .cream: return "Cream"
        case .forest: return "Forest"
        case .lilac: return "Lilac"
        case .terracotta: return "Terracotta"
        case .ice: return "Ice Blue"
        case .steel: return "Steel"
        case .mustard: return "Mustard"
        case .coral: return "Coral"
        case .plum: return "Plum"
        case .olive: return "Olive"
        case .sky: return "Sky"
        }
    }
    var isDark: Bool {
        switch self {
        case .dark, .chalkboard, .blueprint, .obsidian, .midnight, .ocean, .charcoal, .forest, .steel, .plum, .olive:
            return true
        default:
            return false
        }
    }
    
    /// Canonical Color value for each canvas background.
    /// Single source of truth — used by CanvasColorCard, CanvasModePickerView, and canvas rendering.
    var color: Color {
        switch self {
        case .none: return Color.primary.opacity(0.06)
        case .white: return .white
        case .dark: return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .chalkboard: return Color(red: 0.11, green: 0.22, blue: 0.15)
        case .paper: return Color(red: 0.96, green: 0.95, blue: 0.91)
        case .blueprint: return Color(red: 0.11, green: 0.22, blue: 0.38)
        case .sage: return Color(red: 0.88, green: 0.91, blue: 0.88)
        case .obsidian: return Color(red: 0.05, green: 0.05, blue: 0.06)
        case .sand: return Color(red: 0.95, green: 0.92, blue: 0.86)
        case .mint: return Color(red: 0.89, green: 0.94, blue: 0.91)
        case .lavender: return Color(red: 0.91, green: 0.90, blue: 0.96)
        case .clay: return Color(red: 0.93, green: 0.90, blue: 0.86)
        case .midnight: return Color(red: 0.08, green: 0.11, blue: 0.18)
        case .rose: return Color(red: 0.96, green: 0.90, blue: 0.91)
        case .stone: return Color(red: 0.90, green: 0.90, blue: 0.91)
        case .amber: return Color(red: 0.98, green: 0.94, blue: 0.82)
        case .ocean: return Color(red: 0.07, green: 0.20, blue: 0.30)
        case .slate: return Color(red: 0.85, green: 0.87, blue: 0.91)
        case .charcoal: return Color(red: 0.18, green: 0.18, blue: 0.20)
        case .cream: return Color(red: 0.98, green: 0.97, blue: 0.94)
        case .forest: return Color(red: 0.08, green: 0.16, blue: 0.12)
        case .lilac: return Color(red: 0.94, green: 0.91, blue: 0.98)
        case .terracotta: return Color(red: 0.90, green: 0.80, blue: 0.76)
        case .ice: return Color(red: 0.90, green: 0.94, blue: 0.96)
        case .steel: return Color(red: 0.20, green: 0.24, blue: 0.28)
        case .mustard: return Color(red: 0.95, green: 0.86, blue: 0.58)
        case .coral: return Color(red: 0.96, green: 0.76, blue: 0.72)
        case .plum: return Color(red: 0.18, green: 0.12, blue: 0.20)
        case .olive: return Color(red: 0.22, green: 0.24, blue: 0.18)
        case .sky: return Color(red: 0.86, green: 0.92, blue: 0.96)
        }
    }
}

enum CanvasPattern: String, CaseIterable, Identifiable {
    case none, grid, dot, ruled
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .none: return "Solid"
        case .grid: return "Grid"
        case .dot: return "Dots"
        case .ruled: return "Ruled"
        }
    }
}

enum MirroringScaleMode: String, CaseIterable, Identifiable {
    case aspectFit = "aspectFit"
    case stretch = "stretch"
    case aspectFill = "aspectFill"
    case absolute = "absolute"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .aspectFit: return "Proportional Fit"
        case .stretch: return "Stretch to Fill"
        case .aspectFill: return "Proportional Fill"
        case .absolute: return "1:1 Absolute"
        }
    }
    
    var iconName: String {
        switch self {
        case .aspectFit: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .stretch: return "arrow.up.and.down.and.arrow.left.and.right"
        case .aspectFill: return "crop"
        case .absolute: return "square.dashed"
        }
    }
}



struct StopwatchLap: Identifiable, Equatable {
    let id = UUID()
    let lapNumber: Int
    let lapTime: TimeInterval
    let overallTime: TimeInterval
}

enum TimerAlertSound: String, CaseIterable, Identifiable {
    case tink = "Zen Bell"
    case glass = "Glass Chime"
    case submarine = "Sonar"
    case beep = "System Beep"
    case silent = "Silent (Visual Flash Only)"
    
    var id: String { self.rawValue }
    
    var systemSoundName: NSSound.Name? {
        switch self {
        case .tink: return NSSound.Name("Tink")
        case .glass: return NSSound.Name("Glass")
        case .submarine: return NSSound.Name("Submarine")
        case .beep, .silent: return nil
        }
    }
}

struct DrawingPoint {
    var location: CGPoint
    var pressure: CGFloat
    var width: CGFloat
}



enum TextBackgroundStyle: String, CaseIterable, Identifiable {
    case none, solid, glass, border
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .none: return "None"
        case .solid: return "Solid Fill"
        case .glass: return "Glass Effect"
        case .border: return "Bordered"
        }
    }
}

enum ScaleAxis {
    case both, horizontal, vertical
}

enum SelectionTransformType {
    case none
    case moving
    case scaling
    case rotating
    case adjustingCornerRadius
}

enum GazeFontFamily: String, CaseIterable, Identifiable {
    case system, rounded, monospace, serif, sketch, modern, handwritten
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .rounded: return "Rounded"
        case .monospace: return "Monospace"
        case .serif: return "Serif"
        case .sketch: return "Sketch"
        case .modern: return "Modern"
        case .handwritten: return "Handwritten"
        }
    }
    
    func toFont(size: CGFloat, isBold: Bool, isItalic: Bool) -> Font {
        let weight: Font.Weight = isBold ? .bold : .regular
        var baseFont: Font
        switch self {
        case .system:
            baseFont = Font.system(size: size).weight(weight)
        case .rounded:
            baseFont = Font.system(size: size, weight: weight, design: .rounded)
        case .monospace:
            baseFont = Font.system(size: size, weight: weight, design: .monospaced)
        case .serif:
            baseFont = Font.custom("Georgia", size: size).weight(weight)
        case .sketch:
            baseFont = Font.custom("Chalkboard SE", size: size).weight(weight)
        case .modern:
            baseFont = Font.custom("Avenir Next", size: size).weight(weight)
        case .handwritten:
            baseFont = Font.custom("Noteworthy", size: size).weight(weight)
        }
        if isItalic {
            baseFont = baseFont.italic()
        }
        return baseFont
    }
    
    func toNSFont(size: CGFloat, isBold: Bool, isItalic: Bool) -> NSFont {
        var baseFont: NSFont
        switch self {
        case .system:
            baseFont = NSFont.systemFont(ofSize: size)
        case .rounded:
            let systemFont = NSFont.systemFont(ofSize: size)
            if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                baseFont = NSFont(descriptor: descriptor, size: size) ?? systemFont
            } else {
                baseFont = systemFont
            }
        case .monospace:
            baseFont = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .serif:
            baseFont = NSFont(name: "Georgia", size: size) ?? NSFont.systemFont(ofSize: size)
        case .sketch:
            baseFont = NSFont(name: "Chalkboard SE", size: size) ?? NSFont.systemFont(ofSize: size)
        case .modern:
            baseFont = NSFont(name: "Avenir Next", size: size) ?? NSFont.systemFont(ofSize: size)
        case .handwritten:
            baseFont = NSFont(name: "Noteworthy", size: size) ?? NSFont.systemFont(ofSize: size)
        }
        
        var traits: NSFontDescriptor.SymbolicTraits = []
        if isBold { traits.insert(.bold) }
        if isItalic { traits.insert(.italic) }
        
        if !traits.isEmpty {
            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits)
            baseFont = NSFont(descriptor: descriptor, size: size) ?? baseFont
        }
        return baseFont
    }
}

struct DrawingSegment {
    var path: Path
    var width: CGFloat
}

struct DrawingElement: Identifiable {
    var id = UUID()
    var tool: Tool
    var points: [DrawingPoint]
    var color: Color
    var lineWidth: CGFloat
    var opacity: CGFloat
    var shapeType: ShapeType? = nil
    var cachedPath: Path? = nil // Pre-computed path for ultra-fast rendering
    var cachedSegments: [DrawingSegment]? = nil // Pre-computed segments for pressure-sensitive rendering
    var cachedChunkBounds: [CGRect]? = nil // Pre-computed chunk bounding boxes for optimized eraser hit testing
    var screenID: String? = nil // The display screen this stroke was drawn on
    var rotationAngle: Double = 0.0 // Rotation angle in radians
    
    // Text tool specific properties
    var text: String? = nil
    var isEditing: Bool = false
    var textSize: CGSize = .zero
    var fontSize: CGFloat = 18
    var isBold: Bool = false
    var isItalic: Bool = false
    var textAlignment: TextAlignment = .leading
    var textBackgroundStyle: TextBackgroundStyle = .none
    var fontFamily: GazeFontFamily = .system
    var cornerRadius: CGFloat = 0.0
}

struct HistoryState {
    let elements: [DrawingElement]
    let selectedElementIds: Set<UUID>
}

struct LaserPoint: Sendable {
    let location: CGPoint
    let creationTime: Date
    let screenID: String
}

@MainActor
class AppManager: ObservableObject {
    static let shared = AppManager()
    
    // MARK: - Input State
    var currentPressure: CGFloat = 1.0
    
    // MARK: - Cursor Caching State
    private var cachedCursor: NSCursor?
    private var cachedCursorType: Tool?
    private var cachedCursorWidth: CGFloat?
    private var cachedCursorColor: Color?
    
    // MARK: - Toolbar State
    @Published var selectedTool: Tool = {
        if let raw = UserDefaults.standard.string(forKey: "selectedTool"),
           let tool = Tool(rawValue: raw) {
            return tool
        }
        return .cursor
    }() {
        didSet {
            UserDefaults.standard.set(selectedTool.rawValue, forKey: "selectedTool")
            commitAllActiveTextElements()
            updateClickThrough()
            if selectedTool == .laser {
                if laserMode == .trail {
                    startLaserTimer()
                } else {
                    stopLaserTimer()
                    laserPoints.removeAll()
                }
            } else {
                stopLaserTimer()
                laserPoints.removeAll()
            }
            if selectedTool != .pencil && selectedTool != .highlighter {
                pencilHoverLocation = nil
            }
            updateCursorForCurrentTool()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.selectedTool != .select {
                    self.selectedElementId = nil
                }
                // Auto-adjust default stroke widths for better UX using tool-specific settings
                if self.selectedTool == .highlighter {
                    self.strokeWidth = self.highlighterStrokeWidth
                } else if self.selectedTool == .pencil {
                    self.strokeWidth = self.pencilStrokeWidth
                } else if self.selectedTool == .shape {
                    self.strokeWidth = self.shapeStrokeWidth
                }
            }
        }
    }
    @Published var selectedColor: Color = {
        if let hex = UserDefaults.standard.string(forKey: "selectedColor"),
           let color = Color.fromHex(hex) {
            return color
        }
        return Color(red: 1.0, green: 0.62, blue: 0.04) // Default Orange (#FF9F0A)
    }() {
        didSet {
            if let hex = selectedColor.toHex() {
                UserDefaults.standard.set(hex, forKey: "selectedColor")
            }
            updateCursorForCurrentTool()
        }
    }
    
    // Tool-specific widths (synced with UserDefaults)
    var pencilStrokeWidth: CGFloat = {
        let saved = UserDefaults.standard.double(forKey: "pencilStrokeWidth")
        return saved == 0.0 ? 4.0 : CGFloat(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Double(pencilStrokeWidth), forKey: "pencilStrokeWidth")
        }
    }
    var highlighterStrokeWidth: CGFloat = {
        let saved = UserDefaults.standard.double(forKey: "highlighterStrokeWidth")
        return saved == 0.0 ? 24.0 : CGFloat(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Double(highlighterStrokeWidth), forKey: "highlighterStrokeWidth")
        }
    }
    var shapeStrokeWidth: CGFloat = {
        let saved = UserDefaults.standard.double(forKey: "shapeStrokeWidth")
        return saved == 0.0 ? 4.0 : CGFloat(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Double(shapeStrokeWidth), forKey: "shapeStrokeWidth")
        }
    }
    @Published var strokeWidth: CGFloat = 4.0 {
        didSet {
            if selectedTool == .pencil {
                pencilStrokeWidth = strokeWidth
            } else if selectedTool == .highlighter {
                highlighterStrokeWidth = strokeWidth
            } else if selectedTool == .shape {
                shapeStrokeWidth = strokeWidth
            }
            UserDefaults.standard.set(Double(strokeWidth), forKey: "strokeWidth")
            updateCursorForCurrentTool()
        }
    }
    @Published var selectedOpacity: CGFloat = {
        let saved = UserDefaults.standard.object(forKey: "selectedOpacity") as? Double
        return CGFloat(saved ?? 1.0)
    }() {
        didSet {
            UserDefaults.standard.set(Double(selectedOpacity), forKey: "selectedOpacity")
        }
    }
    @Published var scaleLineWidth: Bool = {
        let saved = UserDefaults.standard.object(forKey: "scaleLineWidth") as? Bool
        return saved ?? true
    }() {
        didSet {
            UserDefaults.standard.set(scaleLineWidth, forKey: "scaleLineWidth")
        }
    }
    @Published var defaultFontSize: CGFloat = {
        let saved = UserDefaults.standard.double(forKey: "defaultFontSize")
        return saved == 0.0 ? 18.0 : CGFloat(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Double(defaultFontSize), forKey: "defaultFontSize")
        }
    }
    @Published var defaultFontFamily: GazeFontFamily = {
        let saved = UserDefaults.standard.string(forKey: "defaultFontFamily") ?? GazeFontFamily.system.rawValue
        return GazeFontFamily(rawValue: saved) ?? .system
    }() {
        didSet {
            UserDefaults.standard.set(defaultFontFamily.rawValue, forKey: "defaultFontFamily")
        }
    }
    @Published var selectedShape: ShapeType = {
        if let raw = UserDefaults.standard.string(forKey: "selectedShape"),
           let shape = ShapeType(rawValue: raw) {
            return shape
        }
        return .square
    }() {
        didSet {
            UserDefaults.standard.set(selectedShape.rawValue, forKey: "selectedShape")
        }
    }

    @Published var isCompact: Bool = UserDefaults.standard.bool(forKey: "toolbarIsCompact") {
        didSet { UserDefaults.standard.set(isCompact, forKey: "toolbarIsCompact") }
    }
    
    // MARK: - Canvas Background
    @Published var canvasColor: CanvasColor = {
        if let raw = UserDefaults.standard.string(forKey: "canvasColor"),
           let color = CanvasColor(rawValue: raw) {
            return color
        }
        return .none
    }() {
        didSet {
            UserDefaults.standard.set(canvasColor.rawValue, forKey: "canvasColor")
            if canvasColor != .none {
                lastActiveCanvasColor = canvasColor
            }
        }
    }
    @Published var canvasPattern: CanvasPattern = {
        if let raw = UserDefaults.standard.string(forKey: "canvasPattern"),
           let pattern = CanvasPattern(rawValue: raw) {
            return pattern
        }
        return .none
    }() {
        didSet {
            UserDefaults.standard.set(canvasPattern.rawValue, forKey: "canvasPattern")
        }
    }
    @Published var canvasGridSpacing: Double = {
        let saved = UserDefaults.standard.double(forKey: "canvasGridSpacing")
        return saved == 0.0 ? 28.0 : saved
    }() {
        didSet {
            UserDefaults.standard.set(canvasGridSpacing, forKey: "canvasGridSpacing")
        }
    }
    var lastActiveCanvasColor: CanvasColor = {
        if let raw = UserDefaults.standard.string(forKey: "lastActiveCanvasColor"),
           let color = CanvasColor(rawValue: raw) {
            return color
        }
        return .white
    }() {
        didSet {
            UserDefaults.standard.set(lastActiveCanvasColor.rawValue, forKey: "lastActiveCanvasColor")
        }
    }
    
    @Published var isWhiteboardModeEnabled: Bool = UserDefaults.standard.bool(forKey: "isWhiteboardModeEnabled") {
        didSet {
            UserDefaults.standard.set(isWhiteboardModeEnabled, forKey: "isWhiteboardModeEnabled")
        }
    }
    @Published var isMiniMapEnabled: Bool = UserDefaults.standard.object(forKey: "isMiniMapEnabled") == nil ? true : UserDefaults.standard.bool(forKey: "isMiniMapEnabled") {
        didSet {
            UserDefaults.standard.set(isMiniMapEnabled, forKey: "isMiniMapEnabled")
        }
    }
    @Published var isMiniMapCollapsed: Bool = UserDefaults.standard.bool(forKey: "isMiniMapCollapsed") {
        didSet {
            UserDefaults.standard.set(isMiniMapCollapsed, forKey: "isMiniMapCollapsed")
        }
    }
    @Published var zoomScale: CGFloat = 1.0 {
        didSet {
            let clamped = clampPanOffset(panOffset)
            if clamped != panOffset {
                panOffset = clamped
            }
        }
    }
    @Published var panOffset: CGPoint = .zero {
        didSet {
            let clamped = clampPanOffset(panOffset)
            if clamped != panOffset {
                panOffset = clamped
            }
        }
    }
    
    func clampPanOffset(_ offset: CGPoint) -> CGPoint {
        let mainScreen = NSScreen.main ?? NSScreen.screens.first
        let screenW = mainScreen?.frame.size.width ?? 1920.0
        let screenH = mainScreen?.frame.size.height ?? 1080.0
        
        let limitX: CGFloat = 4000
        let limitY: CGFloat = 4000
        
        let minX = screenW / 2.0 - limitX * zoomScale
        let maxX = screenW / 2.0 + limitX * zoomScale
        let minY = screenH / 2.0 - limitY * zoomScale
        let maxY = screenH / 2.0 + limitY * zoomScale
        
        return CGPoint(
            x: max(minX, min(maxX, offset.x)),
            y: max(minY, min(maxY, offset.y))
        )
    }

    func toCanvasSpace(_ screenPoint: CGPoint) -> CGPoint {
        guard isWhiteboardModeEnabled && canvasColor != .none else { return screenPoint }
        return CGPoint(
            x: (screenPoint.x - panOffset.x) / zoomScale,
            y: (screenPoint.y - panOffset.y) / zoomScale
        )
    }
    
    func toScreenSpace(_ canvasPoint: CGPoint) -> CGPoint {
        guard isWhiteboardModeEnabled && canvasColor != .none else { return canvasPoint }
        return CGPoint(
            x: canvasPoint.x * zoomScale + panOffset.x,
            y: canvasPoint.y * zoomScale + panOffset.y
        )
    }
    
    // MARK: - Timer State
    @Published var isTimerActive: Bool = false {
        didSet {
            if !isTimerActive {
                isTimerFinished = false
            }
        }
    }
    @Published var isTimerRunning: Bool = false
    @Published var timerDuration: TimeInterval = 300 { // default 5 minutes
        didSet {
            isTimerFinished = false
        }
    }
    @Published var timerTimeLeft: TimeInterval = 300
    @Published var isStopwatchMode: Bool = false
    /// Wall-clock anchor set when the timer starts (or resumes) — used for drift-free elapsed calculations.
    private var timerWallAnchor: Date? = nil
    /// The value of `timerTimeLeft` at the moment the timer was last started/resumed.
    private var timerAnchorValue: TimeInterval = 300
    

    
    // Stopwatch Laps
    @Published var stopwatchLaps: [StopwatchLap] = []
    
    // Alert Sound & Flash
    @Published var alertSound: TimerAlertSound = {
        let raw = UserDefaults.standard.string(forKey: "timerAlertSound") ?? "Zen Bell"
        return TimerAlertSound(rawValue: raw) ?? .tink
    }() {
        didSet {
            UserDefaults.standard.set(alertSound.rawValue, forKey: "timerAlertSound")
        }
    }
    @Published var showCanvasFlash: Bool = false
    @Published var isTimerFinished: Bool = false
    @Published var isTimerDetached: Bool = false {
        didSet {
            updateTimerHUDVisibility()
        }
    }
    
    private var countdownTimer: AnyCancellable?
    
    // MARK: - Laser Pointer State
    @Published var laserPoints: [LaserPoint] = []
    @Published var laserMode: LaserMode = {
        if let raw = UserDefaults.standard.string(forKey: "laserMode"),
           let mode = LaserMode(rawValue: raw) {
            return mode
        }
        return .trail
    }() {
        didSet {
            UserDefaults.standard.set(laserMode.rawValue, forKey: "laserMode")
            if selectedTool == .laser {
                if laserMode == .trail {
                    startLaserTimer()
                } else {
                    stopLaserTimer()
                    if let last = laserPoints.last {
                        laserPoints = [last]
                    } else {
                        laserPoints.removeAll()
                    }
                }
            }
        }
    }
    private var laserTimer: AnyCancellable?
    @Published var isDraggingLaser: Bool = false
    @Published var pencilHoverLocation: CGPoint? = nil
    
    func handlePencilHover(_ location: CGPoint) {
        pencilHoverLocation = location
    }
    
    func handlePencilHoverEnded() {
        pencilHoverLocation = nil
    }
    
    func handleLaserHover(_ location: CGPoint, screenID: String) {
        if !isDraggingLaser && !isMouseOverToolbar {
            laserPoints = [LaserPoint(location: location, creationTime: Date(), screenID: screenID)]
        }
    }
    
    func handleLaserHoverEnded() {
        if !isDraggingLaser {
            laserPoints.removeAll()
        }
    }
    
    func updateCursorForCurrentTool() {
        if isMouseOverToolbar {
            NSCursor.arrow.set()
            return
        }
        
        if let cached = cachedCursor,
           cachedCursorType == selectedTool,
           cachedCursorWidth == strokeWidth,
           cachedCursorColor == selectedColor {
            cached.set()
            return
        }
        
        let newCursor: NSCursor
        switch selectedTool {
        case .cursor, .eraser, .select:
            newCursor = NSCursor.arrow
        case .text:
            newCursor = NSCursor.iBeam
        case .shape:
            newCursor = NSCursor.crosshair
        case .pencil:
            newCursor = NSCursor.dynamicDotCursor(diameter: strokeWidth, color: NSColor(selectedColor))
        case .highlighter:
            newCursor = NSCursor.dynamicDotCursor(diameter: strokeWidth, color: NSColor(selectedColor).withAlphaComponent(0.6))
        case .laser:
            newCursor = NSCursor.customCursor(symbolName: "smallcircle.filled.circle", pointSize: 14)
        }
        
        cachedCursor = newCursor
        cachedCursorType = selectedTool
        cachedCursorWidth = strokeWidth
        cachedCursorColor = selectedColor
        newCursor.set()
    }
    
    func startLaserTimer() {
        guard laserTimer == nil else { return }
        laserTimer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLaserPoints()
            }
    }
    
    func stopLaserTimer() {
        laserTimer?.cancel()
        laserTimer = nil
    }
    
    func updateLaserPoints() {
        guard laserMode == .trail else { return }
        let now = Date()
        let lifespan: TimeInterval = 1.0
        let remaining = laserPoints.filter { now.timeIntervalSince($0.creationTime) < lifespan }
        if remaining.count != laserPoints.count {
            laserPoints = remaining
        }
    }
    
    // MARK: - Drawing State
    @Published var elements: [DrawingElement] = []
    @Published var currentElement: DrawingElement? = nil
    
    // MARK: - String-Lasso Stabilization
    // This algorithm adds a physical "slack" (dead-zone) between the pen and the ink.
    // It creates a "weighted" feel that completely eliminates hand tremors.
    private var lassoPosition: CGPoint?
    @Published var freehandStabilization: Double = {
        let saved = UserDefaults.standard.double(forKey: "freehandStabilization")
        if UserDefaults.standard.object(forKey: "freehandStabilization") == nil {
            return 0.45 // Default stabilization
        }
        return saved
    }() {
        didSet {
            UserDefaults.standard.set(freehandStabilization, forKey: "freehandStabilization")
        }
    }
    
    // MARK: - Hardware Pressure Sensitivity
    @Published var enablePressureSensitivity: Bool = {
        let saved = UserDefaults.standard.object(forKey: "enablePressureSensitivity") as? Bool
        return saved ?? true
    }() {
        didSet {
            UserDefaults.standard.set(enablePressureSensitivity, forKey: "enablePressureSensitivity")
        }
    }
    
    @Published var pressureSensitivityFactor: Double = {
        let saved = UserDefaults.standard.double(forKey: "pressureSensitivityFactor")
        return saved == 0.0 ? 1.0 : saved // Default 1.0 (Standard)
    }() {
        didSet {
            UserDefaults.standard.set(pressureSensitivityFactor, forKey: "pressureSensitivityFactor")
        }
    }

    @Published var minimumWidthRatio: Double = {
        let saved = UserDefaults.standard.double(forKey: "minimumWidthRatio")
        return saved == 0.0 ? 0.35 : saved // Default 0.35 (35%)
    }() {
        didSet {
            UserDefaults.standard.set(minimumWidthRatio, forKey: "minimumWidthRatio")
        }
    }
    // MARK: - Undo/Redo
    @Published var undoStack: [HistoryState] = []
    @Published var redoStack: [HistoryState] = []
    private let maxStackSize = 100

    func recordState() {
        if undoStack.count >= maxStackSize {
            undoStack.removeFirst()
        }
        undoStack.append(HistoryState(elements: elements, selectedElementIds: selectedElementIds))
        redoStack.removeAll()
    }

    func undo() {
        guard let previousState = undoStack.popLast() else { return }
        redoStack.append(HistoryState(elements: elements, selectedElementIds: selectedElementIds))
        elements = previousState.elements
        selectedElementIds = previousState.selectedElementIds
        updateWindowsKeyFocus()
    }

    func redo() {
        guard let nextState = redoStack.popLast() else { return }
        undoStack.append(HistoryState(elements: elements, selectedElementIds: selectedElementIds))
        elements = nextState.elements
        selectedElementIds = nextState.selectedElementIds
        updateWindowsKeyFocus()
    }
    
    // MARK: - Selection state
    @Published var selectedElementIds: Set<UUID> = [] {
        didSet {
            updateSelectionHotkeys()
            updateSelectionHUDVisibility()
        }
    }
    
    var selectedElementId: UUID? {
        get { selectedElementIds.count == 1 ? selectedElementIds.first : nil }
        set {
            if let val = newValue {
                selectedElementIds = [val]
            } else {
                selectedElementIds = []
            }
        }
    }
    
    @Published var activeSelectionLasso: [CGPoint]? = nil
    
    // Cache for multi-element transformations
    private var originalSelectedElements: [DrawingElement] = []
    var originalSelectionBounds: CGRect = .zero
    var originalSelectionCenter: CGPoint = .zero
    @Published var activeRotationAngle: Double = 0.0
    private var lastSelectClickTime: Date? = nil
    private var lastSelectClickLocation: CGPoint? = nil
    var selectDragPrevLocation: CGPoint? = nil
    @Published var activeTransformType: SelectionTransformType = .none {
        didSet {
            if oldValue != activeTransformType {
                updateSelectionHUDVisibility()
            }
        }
    }
    private var isCurrentlyErasing: Bool = false
    
    // MARK: - Multi-Monitor Mirroring Settings
    @Published var isMirroringEnabled: Bool = UserDefaults.standard.bool(forKey: "isMirroringEnabled") {
        didSet {
            UserDefaults.standard.set(isMirroringEnabled, forKey: "isMirroringEnabled")
        }
    }
    
    @Published var mirroringScaleMode: MirroringScaleMode = {
        let raw = UserDefaults.standard.string(forKey: "mirroringScaleMode") ?? MirroringScaleMode.aspectFit.rawValue
        return MirroringScaleMode(rawValue: raw) ?? .aspectFit
    }() {
        didSet {
            UserDefaults.standard.set(mirroringScaleMode.rawValue, forKey: "mirroringScaleMode")
        }
    }
    
    // Active selection screen tracking
    @Published var activeSelectionScreenID: String? = nil
    
    // Global Toast state
    @Published var showGlobalToast: Bool = false
    @Published var globalToastMessage: String = ""
    private var globalToastTask: Task<Void, Never>? = nil
    
    @MainActor
    func triggerGlobalToast(_ message: String) {
        globalToastTask?.cancel()
        globalToastMessage = message
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            showGlobalToast = true
        }
        
        globalToastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                showGlobalToast = false
            }
        }
    }

    // Shortcut Toast state
    @Published var showShortcutToast: Bool = false
    @Published var shortcutToastIcon: String = ""
    @Published var shortcutToastName: String = ""
    @Published var shortcutToastKeys: String = ""
    private var shortcutToastTask: Task<Void, Never>? = nil
    
    @MainActor
    func triggerShortcutToast(icon: String, name: String, keys: String) {
        shortcutToastTask?.cancel()
        shortcutToastIcon = icon
        shortcutToastName = name
        shortcutToastKeys = keys
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showShortcutToast = true
        }
        
        shortcutToastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                showShortcutToast = false
            }
        }
    }

    @Published var selectionHUDSize: CGSize = CGSize(width: 320, height: 32)
    @Published var selectionWindowFrame: CGRect = .zero
    @Published var isToolbarVisible: Bool = true {
        didSet {
            updateToolbarVisibility()
        }
    }
    
    @Published var isOverrideActive: Bool = false {
        didSet {
            updateClickThrough()
        }
    }
    
    @Published var isMouseOverToolbar: Bool = false {
        didSet {
            if isMouseOverToolbar {
                if selectedTool == .laser {
                    laserPoints.removeAll()
                }
            }
        }
    }
    private var localFlagsMonitor: SendableEventMonitor?
    private var globalFlagsMonitor: SendableEventMonitor?
    private var localMouseMonitor: SendableEventMonitor?
    private var localKeyMonitor: SendableEventMonitor?
    private var localScrollMonitor: SendableEventMonitor?
    private var previouslyActiveApp: NSRunningApplication? = nil
    
    var toolbarPanel: NSPanel?
    var timerHUDPanel: NSPanel?
    var selectionHUDPanel: SelectionHUDPanel?
    var shortcutsHelpPanel: KeyboardShortcutsHelpPanel?
    var canvasWindows: [NSWindow] = []

    /// Returns true when the toolbar is positioned in the top half of its screen.
    /// Used to push the shortcut toast to the opposite (bottom) side.
    var isToolbarInTopHalf: Bool {
        guard let panel = toolbarPanel,
              let screen = panel.screen else { return true }
        let screenMidY = screen.frame.midY
        let toolbarMidY = panel.frame.midY
        return toolbarMidY >= screenMidY
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        
        if let frontmost = NSWorkspace.shared.frontmostApplication,
           frontmost.bundleIdentifier != Bundle.main.bundleIdentifier {
            self.previouslyActiveApp = frontmost
        }
        
        // MARK: One-time shortcut migration (v4)
        // Reset updated option shortcuts to force KeyboardShortcuts defaults to take effect
        let migrationKey = "shortcutMigrationV4_shortcutsUpdate"
        if !UserDefaults.standard.bool(forKey: migrationKey) {
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectCursor")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectPencil")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectHighlighter")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectText")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectSelect")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectLaser")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_selectEraser")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_undo")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_redo")
            UserDefaults.standard.removeObject(forKey: "KeyboardShortcuts_toggleCanvasMode")
            UserDefaults.standard.set(true, forKey: migrationKey)
        }
        
        // Option + Shift momentary cursor override monitors
        let flagsHandler: (NSEvent) -> NSEvent? = { [weak self] event in
            DispatchQueue.main.async {
                self?.handleFlagsChanged(event)
            }
            return event
        }
        if let monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: flagsHandler) {
            self.localFlagsMonitor = SendableEventMonitor(monitor: monitor)
        }
        if let monitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: { [weak self] event in
            DispatchQueue.main.async {
                self?.handleFlagsChanged(event)
            }
        }) {
            self.globalFlagsMonitor = SendableEventMonitor(monitor: monitor)
        }
        
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { _ in
                Task { @MainActor in
                    AppManager.shared.handleScreenChange()
                }
            }
            .store(in: &cancellables)
            
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { _ in
                Task { @MainActor in
                    AppManager.shared.handleSpaceChange()
                }
            }
            .store(in: &cancellables)
            
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { notification in
                // Only clear selection when a *different* app becomes active.
                // Gaze itself triggers this notification when activating for text editing,
                // so we must not clear selection for our own activation events.
                guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                      app.processIdentifier != ProcessInfo.processInfo.processIdentifier else { return }
                Task { @MainActor [weak self] in
                    self?.previouslyActiveApp = app
                    self?.selectedElementId = nil
                }
            }
            .store(in: &cancellables)
            
        if let monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged, .tabletPoint], handler: { [weak self] event in
            guard let self = self else { return event }
            if self.selectedTool == .pencil || self.selectedTool == .highlighter {
                if self.enablePressureSensitivity {
                    let rawPressure = event.pressure
                    if rawPressure > 0.01 {
                        let gamma = self.pressureSensitivityFactor
                        let minRatio = self.minimumWidthRatio
                        // EMA smoothing factor
                        let curveValue = pow(Double(rawPressure), gamma)
                        let mappedPressure = minRatio + (1.0 - minRatio) * curveValue
                        
                        if event.type == .leftMouseDown {
                            self.currentPressure = CGFloat(mappedPressure)
                        } else {
                            let alpha = 0.35
                            self.currentPressure = CGFloat(alpha * mappedPressure + (1.0 - alpha) * Double(self.currentPressure))
                        }
                    } else {
                        self.currentPressure = 1.0
                    }
                } else {
                    self.currentPressure = 1.0
                }
            } else {
                self.currentPressure = 1.0
            }
            return event
        }) {
            self.localMouseMonitor = SendableEventMonitor(monitor: monitor)
        }
        
        if let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let self = self else { return event }
            if event.keyCode == VirtualKeyCode.escape.rawValue {
                if self.elements.contains(where: { $0.tool == .text && $0.isEditing }) {
                    self.commitAllActiveTextElements()
                    return nil // Swallow event
                }
            }
            return event
        }) {
            self.localKeyMonitor = SendableEventMonitor(monitor: monitor)
        }
        
        if let monitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .magnify], handler: { [weak self] event in
            guard let self = self else { return event }
            if self.isWhiteboardModeEnabled && self.canvasColor != .none {
                if event.type == .scrollWheel {
                    if event.modifierFlags.contains(.command) {
                        let zoomFactor: CGFloat = 1.05
                        let dy = event.scrollingDeltaY
                        let zoomIn = dy > 0
                        
                        let oldScale = self.zoomScale
                        let newScale: CGFloat
                        if zoomIn {
                            newScale = min(6.0, oldScale * zoomFactor)
                        } else {
                            newScale = max(0.15, oldScale / zoomFactor)
                        }
                        
                        let mouseLoc = event.locationInWindow
                        let scaleRatio = newScale / oldScale
                        self.panOffset.x = mouseLoc.x - (mouseLoc.x - self.panOffset.x) * scaleRatio
                        self.panOffset.y = mouseLoc.y - (mouseLoc.y - self.panOffset.y) * scaleRatio
                        self.zoomScale = newScale
                        return nil
                    } else {
                        let dx = event.hasPreciseScrollingDeltas ? event.scrollingDeltaX : event.deltaX * 10
                        let dy = event.hasPreciseScrollingDeltas ? event.scrollingDeltaY : event.deltaY * 10
                        self.panOffset.x += dx
                        self.panOffset.y += dy
                        return nil
                    }
                } else if event.type == .magnify {
                    let oldScale = self.zoomScale
                    let newScale = min(6.0, max(0.15, oldScale * (1.0 + event.magnification)))
                    
                    let mouseLoc = event.locationInWindow
                    let scaleRatio = newScale / oldScale
                    self.panOffset.x = mouseLoc.x - (mouseLoc.x - self.panOffset.x) * scaleRatio
                    self.panOffset.y = mouseLoc.y - (mouseLoc.y - self.panOffset.y) * scaleRatio
                    self.zoomScale = newScale
                    return nil
                }
            }
            return event
        }) {
            self.localScrollMonitor = SendableEventMonitor(monitor: monitor)
        }
        
        // Initialize tool-specific width for the initially selected tool
        if self.selectedTool == .highlighter {
            self.strokeWidth = self.highlighterStrokeWidth
        } else if self.selectedTool == .pencil {
            self.strokeWidth = self.pencilStrokeWidth
        } else if self.selectedTool == .shape {
            self.strokeWidth = self.shapeStrokeWidth
        }
        
        if self.selectedTool == .laser && self.laserMode == .trail {
            self.startLaserTimer()
        }
    }
    
    deinit {
        if let monitor = localFlagsMonitor { NSEvent.removeMonitor(monitor.monitor) }
        if let monitor = globalFlagsMonitor { NSEvent.removeMonitor(monitor.monitor) }
        if let monitor = localMouseMonitor { NSEvent.removeMonitor(monitor.monitor) }
        if let monitor = localKeyMonitor { NSEvent.removeMonitor(monitor.monitor) }
        if let monitor = localScrollMonitor { NSEvent.removeMonitor(monitor.monitor) }
    }
    
    func showShortcutsHelp() {
        if let existing = shortcutsHelpPanel {
            existing.orderFront(nil)
            return
        }
        let screen = toolbarPanel?.screen ?? NSScreen.main ?? NSScreen.screens[0]
        let panelWidth: CGFloat = 680
        let panelHeight: CGFloat = 420
        let panelX = screen.frame.minX + (screen.frame.width - panelWidth) / 2
        let panelY = screen.frame.minY + (screen.frame.height - panelHeight) / 2
        let rect = NSRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
        let panel = KeyboardShortcutsHelpPanel(contentRect: rect)
        panel.contentView = NSHostingView(rootView: KeyboardShortcutsHelpView {
            panel.orderOut(nil)
            self.shortcutsHelpPanel = nil
        })
        self.shortcutsHelpPanel = panel
        panel.orderFront(nil)
    }
    
    func setupWindows() {
        for window in canvasWindows {
            window.close()
        }
        canvasWindows.removeAll()
        
        self.selectionHUDPanel?.close()
        self.selectionHUDPanel = nil
        
        for screen in NSScreen.screens {
            let canvas = CanvasWindow(contentRect: screen.frame)
            let hostingView = NSHostingView(rootView: CanvasView(manager: self, screen: screen))
            hostingView.sizingOptions = []
            canvas.contentView = hostingView
            canvasWindows.append(canvas)
            canvas.orderFront(nil)
        }
        
        let screenFrame = NSScreen.screens.first?.frame ?? NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let toolbarWidth: CGFloat = 1000
        let toolbarHeight: CGFloat = 120
        let toolbarX = screenFrame.minX + (screenFrame.width - toolbarWidth) / 2
        let toolbarY = screenFrame.minY + (screenFrame.height - toolbarHeight) / 2
        
        let toolbarRect = NSRect(x: toolbarX, y: toolbarY, width: toolbarWidth, height: toolbarHeight)
        let toolbar = ToolbarPanel(contentRect: toolbarRect)
        toolbar.contentView = NSHostingView(rootView: ToolbarView(manager: self))
        self.toolbarPanel = toolbar
        toolbar.orderFront(nil)
        
        updateClickThrough()
    }
    
    func setupGlobalHotKeys() {
        // Tool Selection
        KeyboardShortcuts.onKeyDown(for: .selectCursor) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .cursor
            self.isToolbarVisible = true
            self.selectedElementId = nil
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectCursor) ?? KeyboardShortcuts.Name.selectCursor.initialShortcut {
                self.triggerShortcutToast(icon: Tool.cursor.iconName, name: "Cursor", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .selectPencil) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .pencil
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectPencil) ?? KeyboardShortcuts.Name.selectPencil.initialShortcut {
                self.triggerShortcutToast(icon: Tool.pencil.iconName, name: "Pencil", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .selectHighlighter) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .highlighter
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectHighlighter) ?? KeyboardShortcuts.Name.selectHighlighter.initialShortcut {
                self.triggerShortcutToast(icon: Tool.highlighter.iconName, name: "Highlighter", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .selectText) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .text
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectText) ?? KeyboardShortcuts.Name.selectText.initialShortcut {
                self.triggerShortcutToast(icon: Tool.text.iconName, name: "Text", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .selectSelect) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .select
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectSelect) ?? KeyboardShortcuts.Name.selectSelect.initialShortcut {
                self.triggerShortcutToast(icon: Tool.select.iconName, name: "Select", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .selectEraser) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .eraser
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectEraser) ?? KeyboardShortcuts.Name.selectEraser.initialShortcut {
                self.triggerShortcutToast(icon: Tool.eraser.iconName, name: "Eraser", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .selectLaser) { [weak self] in
            guard let self = self else { return }
            self.selectedTool = .laser
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .selectLaser) ?? KeyboardShortcuts.Name.selectLaser.initialShortcut {
                self.triggerShortcutToast(icon: Tool.laser.iconName, name: "Laser Pointer", keys: shortcut.displayName)
            }
        }

        // Undo / Redo
        KeyboardShortcuts.onKeyDown(for: .undo) { [weak self] in
            guard let self = self else { return }
            self.undo()
            if let shortcut = KeyboardShortcuts.getShortcut(for: .undo) ?? KeyboardShortcuts.Name.undo.initialShortcut {
                self.triggerShortcutToast(icon: "arrow.uturn.backward", name: "Undo", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .redo) { [weak self] in
            guard let self = self else { return }
            self.redo()
            if let shortcut = KeyboardShortcuts.getShortcut(for: .redo) ?? KeyboardShortcuts.Name.redo.initialShortcut {
                self.triggerShortcutToast(icon: "arrow.uturn.forward", name: "Redo", keys: shortcut.displayName)
            }
        }
        
        // Delete Selection
        KeyboardShortcuts.onKeyDown(for: .deleteSelection) { [weak self] in
            guard let self = self else { return }
            self.deleteSelectedElement()
            if let shortcut = KeyboardShortcuts.getShortcut(for: .deleteSelection) ?? KeyboardShortcuts.Name.deleteSelection.initialShortcut {
                self.triggerShortcutToast(icon: "trash", name: "Delete Element", keys: shortcut.displayName)
            }
        }
        
        // Clear Screen
        KeyboardShortcuts.onKeyDown(for: .clearScreen) { [weak self] in
            guard let self = self else { return }
            self.clearAll()
            if let shortcut = KeyboardShortcuts.getShortcut(for: .clearScreen) ?? KeyboardShortcuts.Name.clearScreen.initialShortcut {
                self.triggerShortcutToast(icon: "trash", name: "Clear Screen", keys: shortcut.displayName)
            }
        }
        
        // Toggle Canvas Mode
        KeyboardShortcuts.onKeyDown(for: .toggleCanvasMode) { [weak self] in
            guard let self = self else { return }
            if self.canvasColor != .none {
                self.canvasColor = .none
            } else {
                self.canvasColor = self.lastActiveCanvasColor
            }
            if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleCanvasMode) ?? KeyboardShortcuts.Name.toggleCanvasMode.initialShortcut {
                self.triggerShortcutToast(icon: "macwindow", name: self.canvasColor == .none ? "Drawing Mode" : "Whiteboard Mode", keys: shortcut.displayName)
            }
        }
        
        // Shape selection
        KeyboardShortcuts.onKeyDown(for: .shapeSquare) { [weak self] in
            guard let self = self else { return }
            self.selectedShape = .square
            self.selectedTool = .shape
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .shapeSquare) ?? KeyboardShortcuts.Name.shapeSquare.initialShortcut {
                self.triggerShortcutToast(icon: ShapeType.square.iconName, name: "Square", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .shapeCircle) { [weak self] in
            guard let self = self else { return }
            self.selectedShape = .circle
            self.selectedTool = .shape
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .shapeCircle) ?? KeyboardShortcuts.Name.shapeCircle.initialShortcut {
                self.triggerShortcutToast(icon: ShapeType.circle.iconName, name: "Circle", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .shapeTriangle) { [weak self] in
            guard let self = self else { return }
            self.selectedShape = .triangle
            self.selectedTool = .shape
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .shapeTriangle) ?? KeyboardShortcuts.Name.shapeTriangle.initialShortcut {
                self.triggerShortcutToast(icon: ShapeType.triangle.iconName, name: "Triangle", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .shapeLine) { [weak self] in
            guard let self = self else { return }
            self.selectedShape = .line
            self.selectedTool = .shape
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .shapeLine) ?? KeyboardShortcuts.Name.shapeLine.initialShortcut {
                self.triggerShortcutToast(icon: ShapeType.line.iconName, name: "Line", keys: shortcut.displayName)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .shapeArrow) { [weak self] in
            guard let self = self else { return }
            self.selectedShape = .arrow
            self.selectedTool = .shape
            self.isToolbarVisible = true
            if let shortcut = KeyboardShortcuts.getShortcut(for: .shapeArrow) ?? KeyboardShortcuts.Name.shapeArrow.initialShortcut {
                self.triggerShortcutToast(icon: ShapeType.arrow.iconName, name: "Arrow", keys: shortcut.displayName)
            }
        }
        
        // Timer toggle
        KeyboardShortcuts.onKeyDown(for: .toggleTimer) { [weak self] in
            guard let self = self else { return }
            if self.isTimerActive {
                self.pauseTimer()
                self.isTimerActive = false
            } else {
                self.isTimerActive = true
            }
            if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleTimer) ?? KeyboardShortcuts.Name.toggleTimer.initialShortcut {
                self.triggerShortcutToast(
                    icon: self.isTimerActive ? "play.fill" : "pause.fill",
                    name: self.isTimerActive ? "Timer Active" : "Timer Paused",
                    keys: shortcut.displayName
                )
            }
        }
        
        // Detached HUD toggle
        KeyboardShortcuts.onKeyDown(for: .toggleHUDDetached) { [weak self] in
            guard let self = self else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                if !self.isTimerActive {
                    self.isTimerActive = true
                    self.isTimerDetached = true
                } else {
                    self.isTimerDetached.toggle()
                }
            }
            if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleHUDDetached) ?? KeyboardShortcuts.Name.toggleHUDDetached.initialShortcut {
                self.triggerShortcutToast(
                    icon: self.isTimerDetached ? "stopwatch.fill" : "stopwatch",
                    name: self.isTimerDetached ? "Timer Detached" : "Timer Attached",
                    keys: shortcut.displayName
                )
            }
        }
        
        // Capture screenshot
        KeyboardShortcuts.onKeyDown(for: .triggerCapture) { [weak self] in
            guard let self = self else { return }
            self.captureScreen(targetScreen: nil, cropToDrawings: false, saveToURL: nil) { success in
                Task { @MainActor in
                    if success {
                        self.triggerGlobalToast("Copied!")
                    } else {
                        self.triggerGlobalToast("Capture Failed!")
                    }
                }
            }
            if let shortcut = KeyboardShortcuts.getShortcut(for: .triggerCapture) ?? KeyboardShortcuts.Name.triggerCapture.initialShortcut {
                self.triggerShortcutToast(icon: "camera.fill", name: "Screen Capture", keys: shortcut.displayName)
            }
        }
        
        // Toggle canvas mirroring
        KeyboardShortcuts.onKeyDown(for: .toggleMirroring) { [weak self] in
            guard let self = self else { return }
            self.isMirroringEnabled.toggle()
            if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleMirroring) ?? KeyboardShortcuts.Name.toggleMirroring.initialShortcut {
                self.triggerShortcutToast(
                    icon: self.isMirroringEnabled ? "rectangle.portrait.on.rectangle.portrait.fill" : "rectangle.portrait.on.rectangle.portrait",
                    name: self.isMirroringEnabled ? "Mirroring Enabled" : "Mirroring Disabled",
                    keys: shortcut.displayName
                )
            }
        }
        
        // Toggle toolbar visibility (Option + Q)
        KeyboardShortcuts.onKeyDown(for: .toggleToolbarVisibility) { [weak self] in
            guard let self = self else { return }
            self.isToolbarVisible.toggle()
            if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleToolbarVisibility) ?? KeyboardShortcuts.Name.toggleToolbarVisibility.initialShortcut {
                self.triggerShortcutToast(
                    icon: self.isToolbarVisible ? "eye.fill" : "eye.slash.fill",
                    name: self.isToolbarVisible ? "Show All Overlays" : "Hide All Overlays",
                    keys: shortcut.displayName
                )
            }
        }
        
        // Dynamic selection deletion via Backspace/Delete
        KeyboardShortcuts.onKeyDown(for: .deleteSelectionBackspace) { [weak self] in
            self?.deleteSelectedElement()
        }
    }
    
    private func repositionToolbar(onNewScreens screens: [NSScreen]) {
        guard let toolbarPanel = self.toolbarPanel else { return }
        let currentFrame = toolbarPanel.frame
        
        let toolbarCenter = CGPoint(x: currentFrame.midX, y: currentFrame.midY)
        let oldScreen = NSScreen.screens.first(where: { NSMouseInRect(toolbarCenter, $0.frame, false) })
            ?? NSScreen.main
            ?? screens.first
            
        guard let targetScreen = oldScreen else { return }
        
        var newRect = currentFrame
        let padding: CGFloat = 10
        
        if newRect.minX < targetScreen.frame.minX - newRect.width + padding {
            newRect.origin.x = targetScreen.frame.minX + padding
        }
        if newRect.maxX > targetScreen.frame.maxX + newRect.width - padding {
            newRect.origin.x = targetScreen.frame.maxX - newRect.width - padding
        }
        if newRect.minY < targetScreen.frame.minY - newRect.height + padding {
            newRect.origin.y = targetScreen.frame.minY + padding
        }
        if newRect.maxY > targetScreen.frame.maxY + newRect.height - padding {
            newRect.origin.y = targetScreen.frame.maxY - newRect.height - padding
        }
        
        if currentFrame.origin.x <= -2000 || currentFrame.origin.y <= -2000 || currentFrame.size == .zero {
            let toolbarWidth: CGFloat = 1000
            let toolbarHeight: CGFloat = 120
            let toolbarX = targetScreen.frame.minX + (targetScreen.frame.width - toolbarWidth) / 2
            let toolbarY = targetScreen.frame.minY + (targetScreen.frame.height - toolbarHeight) / 2
            newRect = NSRect(x: toolbarX, y: toolbarY, width: toolbarWidth, height: toolbarHeight)
        }
        
        toolbarPanel.setFrame(newRect, display: true)
    }

    func handleScreenChange() {
        DispatchQueue.main.async {
            for window in self.canvasWindows {
                window.close()
            }
            self.canvasWindows.removeAll()
            
            for screen in NSScreen.screens {
                let canvas = CanvasWindow(contentRect: screen.frame)
                let hostingView = NSHostingView(rootView: CanvasView(manager: self, screen: screen))
                hostingView.sizingOptions = []
                canvas.contentView = hostingView
                self.canvasWindows.append(canvas)
                canvas.orderFront(nil)
            }
            
            self.repositionToolbar(onNewScreens: NSScreen.screens)
            
            self.updateClickThrough()
        }
    }
    
    func orderAllWindowsFront() {
        for window in self.canvasWindows {
            window.orderFront(nil)
        }
        if self.isToolbarVisible {
            self.toolbarPanel?.orderFront(nil)
        }
        self.selectionHUDPanel?.orderFront(nil)
        self.timerHUDPanel?.orderFront(nil)
    }

    func handleSpaceChange() {
        DispatchQueue.main.async {
            self.orderAllWindowsFront()
            
            // Retry twice after delays to ensure windows rise front during/after space transitions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.orderAllWindowsFront()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.orderAllWindowsFront()
            }
        }
    }
    
    func updateClickThrough() {
        DispatchQueue.main.async {
            let ignore = !self.isToolbarVisible || (self.selectedTool == .cursor) || self.isOverrideActive
            for window in self.canvasWindows {
                window.ignoresMouseEvents = ignore
            }
        }
    }
    
    func updateToolbarVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let toolbarPanel = self.toolbarPanel else { return }
            if self.isToolbarVisible {
                toolbarPanel.orderFront(nil)
            } else {
                toolbarPanel.orderOut(nil)
            }
            self.updateClickThrough()
            self.updateSelectionHUDVisibility()
            self.updateTimerHUDVisibility()
        }
    }
    
    func handleFlagsChanged(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection([.option, .shift])
        let optionShiftPressed = flags == [.option, .shift]
        
        if optionShiftPressed {
            if !self.isOverrideActive {
                self.isOverrideActive = true
                self.triggerShortcutToast(
                    icon: "app.specular",
                    name: "Interaction Mode Active",
                    keys: "⌥ ⇧"
                )
            }
        } else {
            if self.isOverrideActive {
                self.isOverrideActive = false
                self.triggerShortcutToast(
                    icon: self.selectedTool.iconName,
                    name: "Drawing Canvas Restored",
                    keys: ""
                )
            }
        }
    }
    
    func positionTimerHUD() {
        guard let hud = timerHUDPanel else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) ?? NSScreen.main ?? NSScreen.screens.first
        guard let screen = targetScreen else { return }
        
        let screenFrame = screen.frame
        let hudSize = hud.contentView?.fittingSize ?? CGSize(width: 260, height: 48)
        let hudW = hudSize.width > 0 ? hudSize.width : 260
        let hudH = hudSize.height > 0 ? hudSize.height : 48
        
        // Position at the top right of the target screen, just below the menu bar
        let hudX = screenFrame.maxX - hudW - 24
        let hudY = screenFrame.maxY - hudH - 48
        
        let newRect = NSRect(x: hudX, y: hudY, width: hudW, height: hudH)
        hud.setFrame(newRect, display: true, animate: false)
    }
    
    func updateTimerHUDVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isTimerDetached && self.isToolbarVisible {
                if self.timerHUDPanel == nil {
                    let hud = FloatingTimerHUDPanel(contentRect: NSRect(x: -2000, y: -2000, width: 260, height: 48))
                    let hostingView = NSHostingView(rootView: FloatingTimerHUDView(manager: self).fixedSize())
                    hud.contentView = hostingView
                    self.timerHUDPanel = hud
                    self.positionTimerHUD()
                    hud.orderFront(nil)
                }
            } else {
                self.timerHUDPanel?.close()
                self.timerHUDPanel = nil
            }
        }
    }
    
    func updateSelectionHUDVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isToolbarVisible && !self.selectedElementIds.isEmpty && self.activeTransformType == .none {
                if self.selectionHUDPanel == nil {
                    let hud = SelectionHUDPanel(contentRect: NSRect(x: -2000, y: -2000, width: 320, height: 32))
                    let hostingView = NSHostingView(rootView: SelectionHUDWindowView(manager: self))
                    hud.contentView = hostingView
                    self.selectionHUDPanel = hud
                }
                self.positionSelectionHUD()
                self.selectionHUDPanel?.orderFront(nil)
            } else {
                self.selectionHUDPanel?.close()
                self.selectionHUDPanel = nil
            }
        }
    }
    
    func findScreen(from screenID: String?) -> NSScreen? {
        guard let screenID = screenID else { return nil }
        let components = screenID.split(separator: ",")
        guard components.count == 4,
              let x = Double(components[0]),
              let y = Double(components[1]),
              let w = Double(components[2]),
              let h = Double(components[3]) else { return nil }
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        return NSScreen.screens.first(where: {
            abs($0.frame.origin.x - rect.origin.x) < 1 &&
            abs($0.frame.origin.y - rect.origin.y) < 1 &&
            abs($0.frame.size.width - rect.size.width) < 1 &&
            abs($0.frame.size.height - rect.size.height) < 1
        })
    }
    
    func updateSelectionWindowFrame(_ frame: CGRect, screenID: String) {
        guard let firstId = selectedElementIds.first,
              let element = elements.first(where: { $0.id == firstId }) else { return }
        
        let targetScreen = findScreen(from: element.screenID) ?? NSScreen.main ?? NSScreen.screens.first
        guard let targetScreen = targetScreen else { return }
        let targetScreenID = "\(targetScreen.frame.origin.x),\(targetScreen.frame.origin.y),\(targetScreen.frame.size.width),\(targetScreen.frame.size.height)"
        
        guard screenID == targetScreenID else { return }
        
        self.selectionWindowFrame = frame
        self.positionSelectionHUD()
    }
    
    func positionSelectionHUD() {
        guard let hud = selectionHUDPanel,
              let firstId = selectedElementIds.first,
              let element = elements.first(where: { $0.id == firstId }) else { return }
              
        let screen = findScreen(from: element.screenID) ?? NSScreen.main ?? NSScreen.screens.first
        guard let targetScreen = screen else { return }
        
        let screenFrame = targetScreen.frame
        
        let canvasWindow = canvasWindows.first(where: {
            guard let winScreen = $0.screen else { return false }
            return winScreen.frame == screenFrame
        }) ?? canvasWindows.first
        
        guard let window = canvasWindow else { return }
        
        let hudSize = hud.contentView?.fittingSize ?? selectionHUDSize
        let hudW = hudSize.width > 0 ? hudSize.width : selectionHUDSize.width
        let hudH = hudSize.height > 0 ? hudSize.height : selectionHUDSize.height
        
        let offset: CGFloat = 16
        var appKitX: CGFloat = 0
        var appKitY: CGFloat = 0
        
        let angle = (selectedElementIds.count > 1) ? activeRotationAngle : (elements.first(where: { $0.id == selectedElementIds.first })?.rotationAngle ?? 0.0)
        let boxForRotation = (selectedElementIds.count > 1) ? selectionBoundingBox(projectedTo: element.screenID) : boundingBox(of: element)
        let rotationCenter = CGPoint(x: boxForRotation.midX, y: boxForRotation.midY)
        let rotPoint = CGPoint(x: boxForRotation.midX, y: boxForRotation.minY - 24)
        let rotatedHandle = rotatePoint(rotPoint, around: rotationCenter, by: angle)
        let handleIsAtBottom = rotatedHandle.y > rotationCenter.y
        let shouldPlaceHUDAtTop = handleIsAtBottom
        
        if selectionWindowFrame != .zero {
            let windowHeight = window.contentView?.bounds.height ?? screenFrame.height
            let appKitRect = NSRect(
                x: selectionWindowFrame.minX,
                y: windowHeight - selectionWindowFrame.maxY,
                width: selectionWindowFrame.width,
                height: selectionWindowFrame.height
            )
            let screenRect = window.convertToScreen(appKitRect)
            appKitX = screenRect.midX - (hudW / 2)
            
            if shouldPlaceHUDAtTop {
                appKitY = screenRect.maxY + offset
                if appKitY + hudH > screenFrame.maxY - 20 {
                    appKitY = screenRect.minY - hudH - offset
                }
            } else {
                appKitY = screenRect.minY - hudH - offset
                if appKitY < screenFrame.minY + 20 {
                    appKitY = screenRect.maxY + offset
                }
            }
        } else {
            var box = selectionBoundingBox(projectedTo: element.screenID)
            if isWhiteboardModeEnabled && canvasColor != .none {
                box = CGRect(
                    x: box.origin.x * zoomScale + panOffset.x,
                    y: box.origin.y * zoomScale + panOffset.y,
                    width: box.width * zoomScale,
                    height: box.height * zoomScale
                )
            }
            let boxMinY = box.minY
            let boxMaxY = box.maxY
            let boxMidX = box.midX
            
            appKitX = screenFrame.minX + boxMidX - (hudW / 2)
            
            if shouldPlaceHUDAtTop {
                appKitY = screenFrame.minY + (screenFrame.height - boxMinY) + offset
                if appKitY + hudH > screenFrame.maxY - 20 {
                    appKitY = screenFrame.minY + (screenFrame.height - boxMaxY) - hudH - offset
                }
            } else {
                appKitY = screenFrame.minY + (screenFrame.height - boxMaxY) - hudH - offset
                if appKitY < screenFrame.minY + 20 {
                    appKitY = screenFrame.minY + (screenFrame.height - boxMinY) + offset
                }
            }
        }
        
        let newRect = NSRect(x: appKitX, y: appKitY, width: hudW, height: hudH)
        hud.setFrame(newRect, display: true, animate: false)
    }
    
    // MARK: - Drawing gestures
    
    func handleDragChanged(_ value: DragGesture.Value, screenID: String) {
        let rawLocation = value.location
        let location = isWhiteboardModeEnabled && canvasColor != .none ? toCanvasSpace(rawLocation) : rawLocation
        
        if selectedTool == .laser {
            if isMouseOverToolbar {
                laserPoints.removeAll()
                return
            }
            isDraggingLaser = true
            updateCursorForCurrentTool()
            let newPoint = LaserPoint(location: location, creationTime: Date(), screenID: screenID)
            if laserMode == .dot {
                laserPoints = [newPoint]
            } else {
                laserPoints.append(newPoint)
            }
            return
        }
        
        if selectedTool == .eraser {
            if !isCurrentlyErasing {
                recordState()
                isCurrentlyErasing = true
            }
            eraseAtPoint(location, screenID: screenID)
            return
        }
        
        // 1. STRING-LASSO STABILIZATION
        var pointToStore = location
        if selectedTool == .pencil || selectedTool == .highlighter {
            pencilHoverLocation = location
            if freehandStabilization == 0.0 {
                // Completely raw input, bypass stabilization dead zones
                lassoPosition = nil
                pointToStore = location
            } else {
                let currentLassoLength = CGFloat(freehandStabilization * 8.0)
                let currentFollowSpeed = CGFloat(1.0 - freehandStabilization * 0.8)
                
                if let lp = lassoPosition {
                    let dx = location.x - lp.x
                    let dy = location.y - lp.y
                    let dist = hypot(dx, dy)
                    
                    if dist > currentLassoLength {
                        // Pen is outside the slack zone, pull the ink!
                        let angle = atan2(dy, dx)
                        let targetX = location.x - cos(angle) * currentLassoLength
                        let targetY = location.y - sin(angle) * currentLassoLength
                        
                        // Smooth interpolation toward the pull target
                        lassoPosition = CGPoint(
                            x: lp.x + (targetX - lp.x) * currentFollowSpeed,
                            y: lp.y + (targetY - lp.y) * currentFollowSpeed
                        )
                        pointToStore = lassoPosition!
                    } else {
                        // Still inside the "dead zone" - ignore jitter
                        return
                    }
                } else {
                    lassoPosition = location
                    pointToStore = location
                }
            }
        }
        
        // 2. CONSTANT STROKE WIDTH
        let targetWidth = strokeWidth
        var newPoint = DrawingPoint(location: pointToStore, pressure: currentPressure, width: targetWidth)
        
        if currentElement == nil {
            currentElement = DrawingElement(
                tool: selectedTool,
                points: [newPoint],
                color: selectedColor,
                lineWidth: strokeWidth,
                opacity: selectedTool == .highlighter ? (selectedOpacity * 0.45) : selectedOpacity,
                shapeType: selectedTool == .shape ? selectedShape : nil,
                screenID: screenID,
                rotationAngle: 0.0
            )
        } else {
            if selectedTool == .shape {
                // Apply Shift modifier constraints
                if NSEvent.modifierFlags.contains(.shift), let startPt = currentElement?.points.first {
                    let p1 = startPt.location
                    let p2 = newPoint.location
                    switch selectedShape {
                    case .square, .circle, .triangle:
                        let dx = p2.x - p1.x
                        let dy = p2.y - p1.y
                        let size = max(abs(dx), abs(dy))
                        let lockedX = p1.x + (dx >= 0 ? size : -size)
                        let lockedY = p1.y + (dy >= 0 ? size : -size)
                        newPoint.location = CGPoint(x: lockedX, y: lockedY)
                    case .line, .arrow:
                        let dx = p2.x - p1.x
                        let dy = p2.y - p1.y
                        let len = sqrt(dx*dx + dy*dy)
                        if len > 0.01 {
                            let angle = atan2(dy, dx)
                            let snappedAngle = round(angle / (CGFloat.pi / 4.0)) * (CGFloat.pi / 4.0)
                            newPoint.location = CGPoint(x: p1.x + len * cos(snappedAngle), y: p1.y + len * sin(snappedAngle))
                        }
                    }
                }
                
                if currentElement!.points.count < 2 {
                    currentElement!.points.append(newPoint)
                } else {
                    currentElement!.points[1] = newPoint
                }
            } else {
                currentElement!.points.append(newPoint)
            }
        }
        
        if var element = currentElement {
            updateCachedFieldsIncremental(for: &element)
            currentElement = element
        }
    }
    
    func handleDragEnded(_ value: DragGesture.Value, screenID: String) {
        if selectedTool == .laser {
            isDraggingLaser = false
            if laserMode == .dot {
                laserPoints.removeAll()
            }
            return
        }
        
        // Complete the stroke to the final pen position
        if var element = currentElement, let _ = lassoPosition {
            let endLoc = isWhiteboardModeEnabled && canvasColor != .none ? toCanvasSpace(value.location) : value.location
            let lastPoint = DrawingPoint(location: endLoc, pressure: currentPressure, width: element.lineWidth)
            element.points.append(lastPoint)
            currentElement = element
        }
        
        lassoPosition = nil
        if selectedTool == .eraser {
            isCurrentlyErasing = false
            return
        }
        if var element = currentElement {
            if element.tool == .shape {
                guard element.points.count >= 2 else {
                    currentElement = nil
                    return
                }
                let p1 = element.points[0].location
                let p2 = element.points[1].location
                if hypot(p2.x - p1.x, p2.y - p1.y) < 2.0 {
                    currentElement = nil
                    return
                }
                
                // Ensure final endpoint is properly snapped if shift is held
                if NSEvent.modifierFlags.contains(.shift) {
                    let p1 = element.points[0].location
                    var p2 = element.points[1].location
                    if let shapeType = element.shapeType {
                        switch shapeType {
                        case .square, .circle, .triangle:
                            let dx = p2.x - p1.x
                            let dy = p2.y - p1.y
                            let size = max(abs(dx), abs(dy))
                            let lockedX = p1.x + (dx >= 0 ? size : -size)
                            let lockedY = p1.y + (dy >= 0 ? size : -size)
                            p2 = CGPoint(x: lockedX, y: lockedY)
                        case .line, .arrow:
                            let dx = p2.x - p1.x
                            let dy = p2.y - p1.y
                            let len = sqrt(dx*dx + dy*dy)
                            if len > 0.01 {
                                let angle = atan2(dy, dx)
                                let snappedAngle = round(angle / (CGFloat.pi / 4.0)) * (CGFloat.pi / 4.0)
                                p2 = CGPoint(x: p1.x + len * cos(snappedAngle), y: p1.y + len * sin(snappedAngle))
                            }
                        }
                    }
                    element.points[1].location = p2
                }
            }
            updateCachedFields(for: &element)
            recordState()
            elements.append(element)
            currentElement = nil
        }
    }
    
    // MARK: - Path Pre-computation
    
    func generatePath(for element: DrawingElement) -> Path? {
        let pts = element.points
        guard !pts.isEmpty else { return nil }
        
        if element.tool == .shape, let shapeType = element.shapeType {
            var path = Path()
            if pts.count >= 2 {
                let p1 = pts[0].location
                let p2 = pts[1].location
                switch shapeType {
                case .square:
                    let rect = CGRect(from: p1, to: p2)
                    if element.cornerRadius > 0 {
                        path.addRoundedRect(in: rect, cornerSize: CGSize(width: element.cornerRadius, height: element.cornerRadius))
                    } else {
                        path.addRect(rect)
                    }
                case .circle: path.addEllipse(in: CGRect(from: p1, to: p2))
                case .triangle:
                    let rect = CGRect(from: p1, to: p2)
                    path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    path.closeSubpath()
                case .line: path.move(to: p1); path.addLine(to: p2)
                case .arrow:
                    path.move(to: p1); path.addLine(to: p2)
                    let dx = p2.x - p1.x, dy = p2.y - p1.y, len = sqrt(dx*dx + dy*dy)
                    if len > 1 {
                        let angle = atan2(dy, dx), arrowLength = max(12, element.lineWidth * 2.5), arrowAngle = CGFloat.pi / 6
                        path.move(to: p2)
                        path.addLine(to: CGPoint(x: p2.x - arrowLength * cos(angle - arrowAngle), y: p2.y - arrowLength * sin(angle - arrowAngle)))
                        path.move(to: p2)
                        path.addLine(to: CGPoint(x: p2.x - arrowLength * cos(angle + arrowAngle), y: p2.y - arrowLength * sin(angle + arrowAngle)))

                    }
                }
            }
            return path
        } else if element.tool == .highlighter || element.tool == .pencil {
            // If pressure sensitivity was disabled during drawing, or all pressures are uniform,
            // we can pre-compute the entire Catmull-Rom spline as a single Path!
            // This is a major optimization, because it completely avoids the segment-by-segment loops
            // and recalculations inside drawElement on every single frame.
            let hasDynamicPressure = element.points.contains { $0.pressure != 1.0 }
            if !hasDynamicPressure {
                var path = Path()
                if pts.count == 1 {
                    let pt = pts[0], radius = element.lineWidth / 2
                    path.addEllipse(in: CGRect(x: pt.location.x - radius, y: pt.location.y - radius, width: element.lineWidth, height: element.lineWidth))
                } else if pts.count > 1 {
                    path.move(to: pts[0].location)
                    for i in 0..<(pts.count - 1) {
                        let p0 = pts[max(0, i-1)].location
                        let p1 = pts[i].location
                        let p2 = pts[i+1].location
                        let p3 = pts[min(pts.count-1, i+2)].location
                        let cp = AppManager.getCatmullRomControlPoints(p0, p1, p2, p3)
                        path.addCurve(to: p2, control1: cp.0, control2: cp.1)
                    }
                }
                return path
            }
        }
        return nil
    }
    
    func generateSegments(for element: DrawingElement) -> [DrawingSegment]? {
        let pts = element.points
        guard pts.count > 1 && (element.tool == .pencil || element.tool == .highlighter) else { return nil }
        
        // If the path was cached as a single flat path (no dynamic pressure), we don't need cached segments.
        let hasDynamicPressure = element.points.contains { $0.pressure != 1.0 }
        guard hasDynamicPressure else { return nil }
        
        var segments: [DrawingSegment] = []
        for i in 0..<(pts.count - 1) {
            let p0 = pts[max(0, i-1)].location
            let p1 = pts[i].location
            let p2 = pts[i+1].location
            let p3 = pts[min(pts.count-1, i+2)].location
            let cp = AppManager.getCatmullRomControlPoints(p0, p1, p2, p3)
            
            var segmentPath = Path()
            segmentPath.move(to: p1)
            segmentPath.addCurve(to: p2, control1: cp.0, control2: cp.1)
            
            let w1 = element.lineWidth * pts[i].pressure
            let w2 = element.lineWidth * pts[i+1].pressure
            let segmentWidth = (w1 + w2) / 2.0
            
            segments.append(DrawingSegment(path: segmentPath, width: segmentWidth))
        }
        return segments
    }
    
    func updateCachedFields(for element: inout DrawingElement) {
        element.cachedPath = generatePath(for: element)
        element.cachedSegments = generateSegments(for: element)
        element.cachedChunkBounds = generateChunkBounds(for: element)
    }
    
    func updateCachedFieldsIncremental(for element: inout DrawingElement) {
        guard element.tool == .pencil || element.tool == .highlighter else {
            element.cachedPath = generatePath(for: element)
            element.cachedSegments = nil
            element.cachedChunkBounds = generateChunkBounds(for: element)
            return
        }
        
        let pts = element.points
        guard pts.count > 1 else { return }
        
        let hasDynamicPressure = pts.contains { $0.pressure != 1.0 }
        
        if !hasDynamicPressure {
            element.cachedPath = generatePath(for: element)
            element.cachedSegments = nil
        } else {
            var existingSegments = element.cachedSegments ?? []
            let lastSegmentIdx = existingSegments.count
            let ptsCount = pts.count
            
            if lastSegmentIdx < ptsCount - 1 {
                for i in lastSegmentIdx..<(ptsCount - 1) {
                    let p0 = pts[max(0, i-1)].location
                    let p1 = pts[i].location
                    let p2 = pts[i+1].location
                    let p3 = pts[min(ptsCount-1, i+2)].location
                    let cp = AppManager.getCatmullRomControlPoints(p0, p1, p2, p3)
                    
                    var segmentPath = Path()
                    segmentPath.move(to: p1)
                    segmentPath.addCurve(to: p2, control1: cp.0, control2: cp.1)
                    
                    let w1 = element.lineWidth * pts[i].pressure
                    let w2 = element.lineWidth * pts[i+1].pressure
                    let segmentWidth = (w1 + w2) / 2.0
                    
                    let newSeg = DrawingSegment(path: segmentPath, width: segmentWidth)
                    if i < existingSegments.count {
                        existingSegments[i] = newSeg
                    } else {
                        existingSegments.append(newSeg)
                    }
                }
                
                let reviseIdx = ptsCount - 3
                if reviseIdx >= 0 && reviseIdx < existingSegments.count {
                    let i = reviseIdx
                    let p0 = pts[max(0, i-1)].location
                    let p1 = pts[i].location
                    let p2 = pts[i+1].location
                    let p3 = pts[min(ptsCount-1, i+2)].location
                    let cp = AppManager.getCatmullRomControlPoints(p0, p1, p2, p3)
                    
                    var segmentPath = Path()
                    segmentPath.move(to: p1)
                    segmentPath.addCurve(to: p2, control1: cp.0, control2: cp.1)
                    
                    let w1 = element.lineWidth * pts[i].pressure
                    let w2 = element.lineWidth * pts[i+1].pressure
                    let segmentWidth = (w1 + w2) / 2.0
                    existingSegments[i] = DrawingSegment(path: segmentPath, width: segmentWidth)
                }
            }
            element.cachedSegments = existingSegments
            element.cachedPath = nil
        }
        element.cachedChunkBounds = generateChunkBounds(for: element)
    }
    
    func updateCachedFields(idx: Int) {
        elements[idx].cachedPath = generatePath(for: elements[idx])
        elements[idx].cachedSegments = generateSegments(for: elements[idx])
        elements[idx].cachedChunkBounds = generateChunkBounds(for: elements[idx])
    }
    
    nonisolated func generateChunkBounds(for element: DrawingElement) -> [CGRect] {
        let pts = element.points
        guard pts.count > 1 else { return [] }
        var boundsList: [CGRect] = []
        let chunkSize = 32
        
        var i = 0
        while i < pts.count - 1 {
            let end = min(i + chunkSize, pts.count - 1)
            var minX = CGFloat.infinity, maxX = -CGFloat.infinity
            var minY = CGFloat.infinity, maxY = -CGFloat.infinity
            for j in i...end {
                let loc = pts[j].location
                minX = min(minX, loc.x); maxX = max(maxX, loc.x)
                minY = min(minY, loc.y); maxY = max(maxY, loc.y)
            }
            boundsList.append(CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY))
            i = end
        }
        return boundsList
    }
    
    /// Calculates Centripetal Catmull-Rom control points for a segment (p1 -> p2).
    /// This is an INTERPOLATING spline, meaning it passes exactly through p1 and p2.
    nonisolated static func getCatmullRomControlPoints(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> (CGPoint, CGPoint) {
        let alpha: CGFloat = 0.5 // Centripetal
        func getTime(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
            let d = hypot(p2.x - p1.x, p2.y - p1.y)
            return pow(max(d, 0.01), alpha)
        }
        let t0: CGFloat = 0
        let t1 = t0 + getTime(p0, p1)
        let t2 = t1 + getTime(p1, p2)
        let t3 = t2 + getTime(p2, p3)
        let m1 = (p2 - p1) / (t2 - t1) - (p2 - p0) / (t2 - t0) + (p1 - p0) / (t1 - t0)
        let m2 = (p3 - p2) / (t3 - t2) - (p3 - p1) / (t3 - t1) + (p2 - p1) / (t2 - t1)
        let cp1 = p1 + m1 * (t2 - t1) / 3.0
        let cp2 = p2 - m2 * (t2 - t1) / 3.0
        return (cp1, cp2)
    }
    
    private func eraseAtPoint(_ point: CGPoint, screenID: String) {
        let eraserRadius: CGFloat = isWhiteboardModeEnabled && canvasColor != .none ? (20.0 / zoomScale) : 20.0
        let originalCount = elements.count
        elements.removeAll { element in
            if element.screenID == screenID {
                return elementContains(element, point: point, grabRadius: eraserRadius)
            } else if isMirroringEnabled && !isWhiteboardModeEnabled, let elementScreenID = element.screenID {
                if let srcSize = size(from: elementScreenID),
                   let destSize = size(from: screenID) {
                    let transform = getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
                    let invTransform = transform.inverted()
                    let mappedPoint = point.applying(invTransform)
                    let scale = lineWidthScale(from: srcSize, to: destSize, mode: mirroringScaleMode)
                    let adjustedEraserRadius = scale > 0 ? (eraserRadius / scale) : eraserRadius
                    return elementContains(element, point: mappedPoint, grabRadius: adjustedEraserRadius)
                }
            }
            return false
        }
        if elements.count != originalCount {
            objectWillChange.send()
        }
    }
    
    // MARK: - Select tool gestures
    
    func handleSelectDragChanged(_ value: DragGesture.Value, screenID: String) {
        let location = isWhiteboardModeEnabled && canvasColor != .none ? toCanvasSpace(value.location) : value.location
        let startLocation = isWhiteboardModeEnabled && canvasColor != .none ? toCanvasSpace(value.startLocation) : value.startLocation
        
        if selectDragPrevLocation == nil && activeSelectionLasso == nil {
            if let hitId = hitTest(point: startLocation, screenID: screenID) {
                recordState()
                if NSEvent.modifierFlags.contains(.shift) {
                    if selectedElementIds.contains(hitId) {
                        selectedElementIds.remove(hitId)
                    } else {
                        selectedElementIds.insert(hitId)
                    }
                } else {
                    if !selectedElementIds.contains(hitId) {
                        selectedElementIds = [hitId]
                    }
                }
                selectDragPrevLocation = location
            } else {
                // Record state before potentially clearing the selection,
                // so Cmd-Z can restore what was selected before the lasso started.
                if !selectedElementIds.isEmpty && !NSEvent.modifierFlags.contains(.shift) {
                    recordState()
                }
                if !NSEvent.modifierFlags.contains(.shift) {
                    selectedElementIds = []
                }
                activeSelectionLasso = [startLocation, location]
                activeSelectionScreenID = screenID
            }
        } else if let prevLoc = selectDragPrevLocation, !selectedElementIds.isEmpty {
            activeTransformType = .moving
            let delta = CGPoint(x: location.x - prevLoc.x, y: location.y - prevLoc.y)
            var updatedElements = elements
            for id in selectedElementIds {
                if let idx = updatedElements.firstIndex(where: { $0.id == id }) {
                    moveElementDirect(in: &updatedElements[idx], by: delta, gestureScreenID: screenID)
                }
            }
            elements = updatedElements
            selectDragPrevLocation = location
            positionSelectionHUD()
        } else {
            activeSelectionLasso?.append(location)
        }
    }
    
    func handleSelectDragEnded(_ value: DragGesture.Value, screenID: String) {
        selectDragPrevLocation = nil
        activeTransformType = .none
        
        let dx = value.translation.width
        let dy = value.translation.height
        let isClick = sqrt(dx*dx + dy*dy) < 4.0
        
        if isClick {
            let now = Date()
            if let lastTime = lastSelectClickTime,
               let lastLoc = lastSelectClickLocation,
               now.timeIntervalSince(lastTime) < 0.35,
               hypot(value.location.x - lastLoc.x, value.location.y - lastLoc.y) < 5.0 {
                // Double click detected!
                let hitPoint = isWhiteboardModeEnabled && canvasColor != .none ? toCanvasSpace(value.location) : value.location
                if let hitId = hitTest(point: hitPoint, screenID: screenID) {
                    if let idx = elements.firstIndex(where: { $0.id == hitId }), elements[idx].tool == .text {
                        commitAllActiveTextElements()
                        selectedTool = .text
                        elements[idx].isEditing = true
                        updateWindowsKeyFocus()
                    }
                }
                lastSelectClickTime = nil
                lastSelectClickLocation = nil
            } else {
                lastSelectClickTime = now
                lastSelectClickLocation = value.location
            }
        }
        
        if let polygon = activeSelectionLasso {
            let found = elements.filter { element in
                isElement(element, insideLasso: polygon, targetScreenID: screenID)
            }.map { $0.id }
            if NSEvent.modifierFlags.contains(.shift) {
                selectedElementIds.formUnion(found)
            } else {
                selectedElementIds = Set(found)
            }
            activeSelectionLasso = nil
            activeSelectionScreenID = nil
        }
    }
    
    // MARK: - Select helpers
    
    nonisolated func rotatedPoints(of element: DrawingElement) -> [CGPoint] {
        let box = boundingBox(of: element)
        let center = CGPoint(x: box.midX, y: box.midY)
        
        if element.tool == .shape || element.tool == .text {
            let tl = CGPoint(x: box.minX, y: box.minY)
            let tr = CGPoint(x: box.maxX, y: box.minY)
            let bl = CGPoint(x: box.minX, y: box.maxY)
            let br = CGPoint(x: box.maxX, y: box.maxY)
            
            return [
                rotatePoint(tl, around: center, by: element.rotationAngle),
                rotatePoint(tr, around: center, by: element.rotationAngle),
                rotatePoint(bl, around: center, by: element.rotationAngle),
                rotatePoint(br, around: center, by: element.rotationAngle)
            ]
        } else {
            return element.points.map { rotatePoint($0.location, around: center, by: element.rotationAngle) }
        }
    }
    
    func convertPoint(_ point: CGPoint, from srcScreenID: String?, to destScreenID: String?) -> CGPoint {
        guard let src = srcScreenID, let dest = destScreenID, src != dest else { return point }
        guard let srcSize = size(from: src), let destSize = size(from: dest) else { return point }
        let transform = getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
        return point.applying(transform)
    }
    
    func selectionBoundingBox(projectedTo targetScreenID: String? = nil) -> CGRect {
        let selected = elements.filter { selectedElementIds.contains($0.id) }
        guard !selected.isEmpty else { return .zero }
        
        var minX = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var minY = CGFloat.infinity
        var maxY = -CGFloat.infinity
        
        for element in selected {
            var pts = rotatedPoints(of: element)
            if let target = targetScreenID, let elementScreen = element.screenID, elementScreen != target {
                pts = pts.map { convertPoint($0, from: elementScreen, to: target) }
            }
            for pt in pts {
                minX = min(minX, pt.x)
                maxX = max(maxX, pt.x)
                minY = min(minY, pt.y)
                maxY = max(maxY, pt.y)
            }
        }
        
        let pad = selected.map { $0.lineWidth / 2.0 }.max() ?? 2.0
        return CGRect(x: minX - pad, y: minY - pad, width: maxX - minX + pad * 2, height: maxY - minY + pad * 2)
    }
    
    func selectedColorShared() -> Color? {
        let selected = elements.filter { selectedElementIds.contains($0.id) }
        guard !selected.isEmpty else { return nil }
        let firstColor = selected[0].color
        return selected.allSatisfy { $0.color == firstColor } ? firstColor : nil
    }
    
    
    private func isElement(_ element: DrawingElement, insideLasso polygon: [CGPoint], targetScreenID: String) -> Bool {
        func testPoints(for element: DrawingElement) -> [CGPoint] {
            let box = boundingBox(of: element)
            let center = elementCenter(element)
            // Use 5 sample points: center + 4 corners of bounding box.
            // This correctly catches shapes / text whose centroid is outside the lasso
            // but whose body is inside (e.g. large rectangle where only part is lassoed).
            let pts: [CGPoint] = [
                CGPoint(x: box.midX, y: box.midY),
                CGPoint(x: box.minX, y: box.minY),
                CGPoint(x: box.maxX, y: box.minY),
                CGPoint(x: box.minX, y: box.maxY),
                CGPoint(x: box.maxX, y: box.maxY),
            ]
            return pts.map { rotatePoint($0, around: center, by: element.rotationAngle) }
        }
        
        if element.screenID == targetScreenID {
            if element.tool == .shape || element.tool == .text {
                for p in testPoints(for: element) {
                    if pointInPolygon(p, polygon: polygon) { return true }
                }
                return false
            }
            // For freehand strokes: test each recorded point (fast path with bounding-box pre-check)
            let center = elementCenter(element)
            for p in element.points {
                let rotLoc = rotatePoint(p.location, around: center, by: element.rotationAngle)
                if pointInPolygon(rotLoc, polygon: polygon) { return true }
            }
            return false
        }
        
        if isMirroringEnabled && !isWhiteboardModeEnabled, let elementScreenID = element.screenID {
            guard let srcSize = size(from: elementScreenID),
                  let destSize = size(from: targetScreenID) else {
                return false
            }
            let transform = getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
            
            if element.tool == .shape || element.tool == .text {
                for p in testPoints(for: element) {
                    if pointInPolygon(p.applying(transform), polygon: polygon) { return true }
                }
                return false
            }
            
            let center = elementCenter(element)
            for p in element.points {
                let rotLoc = rotatePoint(p.location, around: center, by: element.rotationAngle)
                if pointInPolygon(rotLoc.applying(transform), polygon: polygon) { return true }
            }
        }
        return false
    }
    
    private func pointInPolygon(_ point: CGPoint, polygon: [CGPoint]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let pi = polygon[i]
            let pj = polygon[j]
            if ((pi.y > point.y) != (pj.y > point.y)) &&
               (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) {
                inside = !inside
            }
            j = i
        }
        return inside
    }
    
    func hitTest(point: CGPoint, screenID: String) -> UUID? {
        let grabRadius: CGFloat = isWhiteboardModeEnabled && canvasColor != .none ? (10.0 / zoomScale) : 10.0
        for element in elements.reversed() {
            if element.screenID == screenID {
                if elementContains(element, point: point, grabRadius: grabRadius) {
                    return element.id
                }
            } else if isMirroringEnabled && !isWhiteboardModeEnabled, let elementScreenID = element.screenID {
                if let srcSize = size(from: elementScreenID),
                   let destSize = size(from: screenID) {
                    let transform = getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
                    let invTransform = transform.inverted()
                    let mappedPoint = point.applying(invTransform)
                    let scale = lineWidthScale(from: srcSize, to: destSize, mode: mirroringScaleMode)
                    let adjustedGrabRadius = scale > 0 ? (grabRadius / scale) : grabRadius
                    if elementContains(element, point: mappedPoint, grabRadius: adjustedGrabRadius) {
                        return element.id
                    }
                }
            }
        }
        return nil
    }
    
    private func elementContains(_ element: DrawingElement, point: CGPoint, grabRadius: CGFloat) -> Bool {
        let testPoint: CGPoint
        if element.rotationAngle != 0 {
            let center = elementCenter(element)
            testPoint = rotatePoint(point, around: center, by: -element.rotationAngle)
        } else {
            testPoint = point
        }
        
        let threshold = (element.lineWidth / 2) + grabRadius
        if element.tool == .text {
            guard let firstPt = element.points.first else { return false }
            let rect = CGRect(origin: firstPt.location, size: element.textSize)
            return rect.insetBy(dx: -grabRadius, dy: -grabRadius).contains(testPoint)
        } else if element.tool == .shape {
            guard element.points.count >= 2 else { return false }
            let p1 = element.points[0].location
            let p2 = element.points[1].location
            switch element.shapeType {
            case .line, .arrow:
                return distanceToSegment(testPoint, p1, p2) <= threshold
            default:
                let rect = CGRect(from: p1, to: p2)
                switch element.shapeType {
                case .square:
                    let d1 = distanceToSegment(testPoint, CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY))
                    let d2 = distanceToSegment(testPoint, CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY))
                    let d3 = distanceToSegment(testPoint, CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY))
                    let d4 = distanceToSegment(testPoint, CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY))
                    return min(d1, d2, d3, d4) <= threshold
                case .circle:
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    let rx = rect.width / 2
                    let ry = rect.height / 2
                    if rx <= 0 || ry <= 0 { return false }
                    let dx = (testPoint.x - center.x) / rx
                    let dy = (testPoint.y - center.y) / ry
                    let dist = sqrt(dx*dx + dy*dy)
                    let shellThickness = threshold / min(rx, ry)
                    return abs(dist - 1.0) <= shellThickness
                case .triangle:
                    let tp1 = CGPoint(x: rect.midX, y: rect.minY)
                    let tp2 = CGPoint(x: rect.minX, y: rect.maxY)
                    let tp3 = CGPoint(x: rect.maxX, y: rect.maxY)
                    let d1 = distanceToSegment(testPoint, tp1, tp2)
                    let d2 = distanceToSegment(testPoint, tp2, tp3)
                    let d3 = distanceToSegment(testPoint, tp3, tp1)
                    return min(d1, d2, d3) <= threshold
                default:
                    return rect.insetBy(dx: -threshold, dy: -threshold).contains(testPoint)
                }
            }
        } else {
            let pts = element.points
            if pts.isEmpty { return false }
            if pts.count == 1 {
                return distance(pts[0].location, testPoint) <= threshold
            }
            if !boundingBox(of: element).insetBy(dx: -threshold, dy: -threshold).contains(testPoint) {
                return false
            }
            
            let chunkSize = 32
            if let chunkBounds = element.cachedChunkBounds, !chunkBounds.isEmpty {
                var chunkIdx = 0
                var i = 0
                while i < pts.count - 1 {
                    let end = min(i + chunkSize, pts.count - 1)
                    if chunkIdx < chunkBounds.count {
                        let bounds = chunkBounds[chunkIdx]
                        chunkIdx += 1
                        if bounds.insetBy(dx: -threshold, dy: -threshold).contains(testPoint) {
                            for j in i..<end {
                                if distanceToSegment(testPoint, pts[j].location, pts[j+1].location) <= threshold {
                                    return true
                                }
                            }
                        }
                    } else {
                        // Fallback if mismatch
                        for j in i..<end {
                            if distanceToSegment(testPoint, pts[j].location, pts[j+1].location) <= threshold {
                                return true
                            }
                        }
                    }
                    i = end
                }
            } else {
                // Fallback if not cached
                for i in 0..<(pts.count - 1) {
                    if distanceToSegment(testPoint, pts[i].location, pts[i+1].location) <= threshold {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    nonisolated func rotatePoint(_ point: CGPoint, around center: CGPoint, by angle: Double) -> CGPoint {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let cosA = cos(angle)
        let sinA = sin(angle)
        return CGPoint(
            x: center.x + dx * cosA - dy * sinA,
            y: center.y + dx * sinA + dy * cosA
        )
    }
    
    func rotateSelectedElements(to angle: Double) {
        guard !originalSelectedElements.isEmpty else { return }
        self.activeRotationAngle = angle
        
        if selectedElementIds.count == 1 {
            if let firstId = selectedElementIds.first,
               let idx = elements.firstIndex(where: { $0.id == firstId }) {
                elements[idx].rotationAngle = angle
            }
        } else {
            let selectionCenter = originalSelectionCenter
            let targetScreenID = originalSelectedElements.first?.screenID
            for origElement in originalSelectedElements {
                guard let idx = elements.firstIndex(where: { $0.id == origElement.id }) else { continue }
                
                var rotatedPoints = origElement.points
                let center = elementCenter(origElement)
                let elementScreenID = origElement.screenID
                
                let targetCenter = convertPoint(center, from: elementScreenID, to: targetScreenID)
                
                for i in rotatedPoints.indices {
                    let screenLoc = rotatePoint(rotatedPoints[i].location, around: center, by: origElement.rotationAngle)
                    
                    let targetScreenLoc = convertPoint(screenLoc, from: elementScreenID, to: targetScreenID)
                    
                    let rotatedLocTarget = rotatePoint(targetScreenLoc, around: selectionCenter, by: angle)
                    let newCenterTarget = rotatePoint(targetCenter, around: selectionCenter, by: angle)
                    
                    let rotatedLoc = convertPoint(rotatedLocTarget, from: targetScreenID, to: elementScreenID)
                    let newCenter = convertPoint(newCenterTarget, from: targetScreenID, to: elementScreenID)
                    
                    let newAngle = origElement.rotationAngle + angle
                    rotatedPoints[i].location = rotatePoint(rotatedLoc, around: newCenter, by: -newAngle)
                }
                elements[idx].points = rotatedPoints
                elements[idx].rotationAngle = origElement.rotationAngle + angle
                updateCachedFields(idx: idx)
            }
        }
        positionSelectionHUD()
    }
    
    nonisolated func boundingBox(of element: DrawingElement) -> CGRect {
        guard !element.points.isEmpty else { return .zero }
        if element.tool == .text {
            let pad: CGFloat = 6.0
            return CGRect(
                x: element.points[0].location.x - pad,
                y: element.points[0].location.y - pad,
                width: element.textSize.width + pad * 2,
                height: element.textSize.height + pad * 2
            )
        }
        var minX = element.points[0].location.x, maxX = minX
        var minY = element.points[0].location.y, maxY = minY
        for p in element.points {
            minX = min(minX, p.location.x); maxX = max(maxX, p.location.x)
            minY = min(minY, p.location.y); maxY = max(maxY, p.location.y)
        }
        let pad = element.lineWidth / 2.0
        let rect = CGRect(x: minX - pad, y: minY - pad, width: maxX - minX + pad * 2, height: maxY - minY + pad * 2)
        return rect.width < 1 || rect.height < 1 ? rect.insetBy(dx: -5, dy: -5) : rect
    }
    
    nonisolated func elementCenter(_ element: DrawingElement) -> CGPoint {
        let box = boundingBox(of: element)
        return CGPoint(x: box.midX, y: box.midY)
    }
    
    // MARK: - Multi-Monitor Coordinate Transformation Helpers
    
    nonisolated func size(from screenID: String?) -> CGSize? {
        guard let screenID = screenID else { return nil }
        let components = screenID.split(separator: ",")
        guard components.count == 4,
              let width = Double(components[2]),
              let height = Double(components[3]) else { return nil }
        return CGSize(width: width, height: height)
    }
    
    nonisolated func getTransform(from srcSize: CGSize, to destSize: CGSize, mode: MirroringScaleMode) -> CGAffineTransform {
        guard srcSize.width > 0, srcSize.height > 0 else { return .identity }
        switch mode {
        case .stretch:
            return CGAffineTransform(scaleX: destSize.width / srcSize.width, y: destSize.height / srcSize.height)
        case .aspectFit:
            let scale = min(destSize.width / srcSize.width, destSize.height / srcSize.height)
            let offsetX = (destSize.width - srcSize.width * scale) / 2
            let offsetY = (destSize.height - srcSize.height * scale) / 2
            return CGAffineTransform(translationX: offsetX, y: offsetY).scaledBy(x: scale, y: scale)
        case .aspectFill:
            let scale = max(destSize.width / srcSize.width, destSize.height / srcSize.height)
            let offsetX = (destSize.width - srcSize.width * scale) / 2
            let offsetY = (destSize.height - srcSize.height * scale) / 2
            return CGAffineTransform(translationX: offsetX, y: offsetY).scaledBy(x: scale, y: scale)
        case .absolute:
            return .identity
        }
    }
    
    nonisolated func lineWidthScale(from srcSize: CGSize, to destSize: CGSize, mode: MirroringScaleMode) -> CGFloat {
        guard srcSize.width > 0, srcSize.height > 0 else { return 1.0 }
        switch mode {
        case .stretch:
            return (destSize.width / srcSize.width + destSize.height / srcSize.height) / 2
        case .aspectFit:
            return min(destSize.width / srcSize.width, destSize.height / srcSize.height)
        case .aspectFill:
            return max(destSize.width / srcSize.width, destSize.height / srcSize.height)
        case .absolute:
            return 1.0
        }
    }
    
    func boundingBox(of element: DrawingElement, mappedTo targetScreenID: String) -> CGRect {
        let nativeBox = boundingBox(of: element)
        if element.screenID == targetScreenID || element.screenID == nil || isWhiteboardModeEnabled {
            return nativeBox
        }
        guard let srcSize = size(from: element.screenID),
              let destSize = size(from: targetScreenID) else {
            return nativeBox
        }
        let transform = getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
        return nativeBox.applying(transform)
    }
    
    func moveElement(id: UUID, by delta: CGPoint, gestureScreenID: String? = nil) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        var element = elements[idx]
        moveElementDirect(in: &element, by: delta, gestureScreenID: gestureScreenID)
        elements[idx] = element
    }
    
    func moveElementDirect(in element: inout DrawingElement, by delta: CGPoint, gestureScreenID: String? = nil) {
        var finalDelta = delta
        
        if isMirroringEnabled && !isWhiteboardModeEnabled,
           let elementScreenID = element.screenID,
           let gestureScreenID = gestureScreenID,
           elementScreenID != gestureScreenID {
            if let srcSize = size(from: elementScreenID),
               let destSize = size(from: gestureScreenID) {
                let transform = getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
                let invTransform = transform.inverted()
                let dx = delta.x * invTransform.a + delta.y * invTransform.c
                let dy = delta.x * invTransform.b + delta.y * invTransform.d
                finalDelta = CGPoint(x: dx, y: dy)
            }
        }
        
        for i in element.points.indices {
            element.points[i].location.x += finalDelta.x
            element.points[i].location.y += finalDelta.y
        }
        updateCachedFields(for: &element)
    }
    
    func startSelectionTransform() {
        let selected = elements.filter { selectedElementIds.contains($0.id) }
        originalSelectedElements = selected
        let targetScreenID = selected.first?.screenID
        if selected.count == 1 {
            originalSelectionBounds = boundingBox(of: selected[0])
        } else {
            originalSelectionBounds = selectionBoundingBox(projectedTo: targetScreenID)
        }
        originalSelectionCenter = CGPoint(x: originalSelectionBounds.midX, y: originalSelectionBounds.midY)
        activeRotationAngle = 0.0
    }
    
    func scaleSelectedElements(anchor: CGPoint, newHandle: CGPoint, lockAspectRatio: Bool = false, axis: ScaleAxis = .both, gestureScreenID: String? = nil) {
        guard !originalSelectedElements.isEmpty, originalSelectionBounds.width > 0, originalSelectionBounds.height > 0 else { return }
        
        let targetScreenID = originalSelectedElements.first?.screenID
        
        var targetAnchor = convertPoint(anchor, from: gestureScreenID, to: targetScreenID)
        var targetNewHandle = convertPoint(newHandle, from: gestureScreenID, to: targetScreenID)
        
        if isWhiteboardModeEnabled && canvasColor != .none {
            targetAnchor = toCanvasSpace(targetAnchor)
            targetNewHandle = toCanvasSpace(targetNewHandle)
        }
        
        let rotationAngle = (selectedElementIds.count == 1) ? (originalSelectedElements.first?.rotationAngle ?? 0.0) : activeRotationAngle
        let C = originalSelectionCenter
        
        let unAnchor = rotationAngle != 0 ? rotatePoint(targetAnchor, around: C, by: -rotationAngle) : targetAnchor
        var unHandle = rotationAngle != 0 ? rotatePoint(targetNewHandle, around: C, by: -rotationAngle) : targetNewHandle
        
        if lockAspectRatio {
            let dx = unHandle.x - unAnchor.x
            let dy = unHandle.y - unAnchor.y
            let oldRatio = originalSelectionBounds.width / originalSelectionBounds.height
            let changePercentX = abs(dx) / originalSelectionBounds.width
            let changePercentY = abs(dy) / originalSelectionBounds.height
            if changePercentX > changePercentY {
                let targetDy = abs(dx) / oldRatio
                unHandle.y = unAnchor.y + targetDy * (dy >= 0 ? 1.0 : -1.0)
            } else {
                let targetDx = abs(dy) * oldRatio
                unHandle.x = unAnchor.x + targetDx * (dx >= 0 ? 1.0 : -1.0)
            }
        }
        
        if axis == .horizontal {
            unHandle.y = unAnchor.y + (unHandle.y >= unAnchor.y ? originalSelectionBounds.height : -originalSelectionBounds.height)
        } else if axis == .vertical {
            unHandle.x = unAnchor.x + (unHandle.x >= unAnchor.x ? originalSelectionBounds.width : -originalSelectionBounds.width)
        }
        
        let newBounds = CGRect(from: unAnchor, to: unHandle)
        guard newBounds.width > 0, newBounds.height > 0 else { return }
        
        let sx = newBounds.width / originalSelectionBounds.width
        let sy = newBounds.height / originalSelectionBounds.height
        
        let C_prime = CGPoint(x: newBounds.midX, y: newBounds.midY)
        let currentRotatedAnchor = rotatePoint(unAnchor, around: C_prime, by: rotationAngle)
        let shift = CGPoint(x: targetAnchor.x - currentRotatedAnchor.x, y: targetAnchor.y - currentRotatedAnchor.y)
        
        var updatedElements = elements
        for origElement in originalSelectedElements {
            guard let idx = updatedElements.firstIndex(where: { $0.id == origElement.id }) else { continue }
            
            var scaledPoints = origElement.points
            let origCenter = elementCenter(origElement)
            let elementScreenID = origElement.screenID
            
            let targetOrigCenter = convertPoint(origCenter, from: elementScreenID, to: targetScreenID)
            
            // 1. Compute the new screen center of this element
            let unrotatedCenter = rotationAngle != 0 ? rotatePoint(targetOrigCenter, around: C, by: -rotationAngle) : targetOrigCenter
            var scaledUnrotatedCenter = CGPoint(
                x: unAnchor.x + (unrotatedCenter.x - unAnchor.x) * sx,
                y: unAnchor.y + (unrotatedCenter.y - unAnchor.y) * sy
            )
            scaledUnrotatedCenter.x += shift.x
            scaledUnrotatedCenter.y += shift.y
            let C_prime_shift = CGPoint(x: C_prime.x + shift.x, y: C_prime.y + shift.y)
            let newCenter_target = rotationAngle != 0 ? rotatePoint(scaledUnrotatedCenter, around: C_prime_shift, by: rotationAngle) : scaledUnrotatedCenter
            
            let newCenter_screen = convertPoint(newCenter_target, from: targetScreenID, to: elementScreenID)
            
            // 2. Scale each point's local coordinate system correctly
            for i in scaledPoints.indices {
                let pt_local = scaledPoints[i].location
                let screenPt = rotatePoint(pt_local, around: origCenter, by: origElement.rotationAngle)
                
                let targetScreenPt = convertPoint(screenPt, from: elementScreenID, to: targetScreenID)
                
                let unrotatedPt = rotationAngle != 0 ? rotatePoint(targetScreenPt, around: C, by: -rotationAngle) : targetScreenPt
                
                var scaledUnrotatedPt = CGPoint(
                    x: unAnchor.x + (unrotatedPt.x - unAnchor.x) * sx,
                    y: unAnchor.y + (unrotatedPt.y - unAnchor.y) * sy
                )
                scaledUnrotatedPt.x += shift.x
                scaledUnrotatedPt.y += shift.y
                
                let newScreenPt_target = rotationAngle != 0 ? rotatePoint(scaledUnrotatedPt, around: C_prime_shift, by: rotationAngle) : scaledUnrotatedPt
                
                let newScreenPt = convertPoint(newScreenPt_target, from: targetScreenID, to: elementScreenID)
                
                scaledPoints[i].location = rotatePoint(newScreenPt, around: newCenter_screen, by: -origElement.rotationAngle)
            }
            
            updatedElements[idx].points = scaledPoints
            
            if scaleLineWidth {
                let scaleFactor = sqrt(sx * sy)
                updatedElements[idx].lineWidth = max(4.0, min(100.0, origElement.lineWidth * scaleFactor))
            }
            updateCachedFields(for: &updatedElements[idx])
        }
        elements = updatedElements
        positionSelectionHUD()
    }
    
    func recolorSelectedElement(to color: Color) {
        guard !selectedElementIds.isEmpty else { return }
        recordState()
        for id in selectedElementIds {
            if let idx = elements.firstIndex(where: { $0.id == id }) {
                elements[idx].color = color
                updateCachedFields(idx: idx)
            }
        }
    }
    
    func adjustSelectedElementLineWidth(to width: CGFloat) {
        recordState()
        for id in selectedElementIds {
            if let idx = elements.firstIndex(where: { $0.id == id }) {
                elements[idx].lineWidth = width
                updateCachedFields(idx: idx)
            }
        }
    }
    
    func adjustSelectedElementOpacity(to opacity: CGFloat) {
        recordState()
        for id in selectedElementIds {
            if let idx = elements.firstIndex(where: { $0.id == id }) {
                elements[idx].opacity = opacity
            }
        }
    }
    

    
    func duplicateSelectedElement() {
        guard !selectedElementIds.isEmpty else { return }
        recordState()
        var newIds = Set<UUID>()
        let offset = CGPoint(x: 20, y: 20)
        
        let sortedSelected = elements.filter { selectedElementIds.contains($0.id) }
        for element in sortedSelected {
            var newElement = element
            newElement.id = UUID()
            for i in newElement.points.indices {
                newElement.points[i].location.x += offset.x
                newElement.points[i].location.y += offset.y
            }
            updateCachedFields(for: &newElement)
            elements.append(newElement)
            newIds.insert(newElement.id)
        }
        selectedElementIds = newIds
    }
    
    func deleteSelectedElement() {
        guard !selectedElementIds.isEmpty else { return }
        recordState()
        elements.removeAll { selectedElementIds.contains($0.id) }
        selectedElementIds.removeAll()
        updateWindowsKeyFocus()
    }
    
    private func updateSelectionHotkeys() {
        if !selectedElementIds.isEmpty {
            KeyboardShortcuts.setShortcut(.init(.delete, modifiers: [.option]), for: .deleteSelectionBackspace)
        } else {
            KeyboardShortcuts.setShortcut(nil, for: .deleteSelectionBackspace)
        }
    }
    
    func sendSelectedElementToBack() {
        guard !selectedElementIds.isEmpty else { return }
        recordState()
        var toMove: [DrawingElement] = []
        elements.removeAll { element in
            if selectedElementIds.contains(element.id) {
                toMove.append(element)
                return true
            }
            return false
        }
        elements.insert(contentsOf: toMove, at: 0)
    }
    
    func bringSelectedElementToFront() {
        guard !selectedElementIds.isEmpty else { return }
        recordState()
        var toMove: [DrawingElement] = []
        elements.removeAll { element in
            if selectedElementIds.contains(element.id) {
                toMove.append(element)
                return true
            }
            return false
        }
        elements.append(contentsOf: toMove)
    }
    
    // MARK: - Timer Actions
    
    func setTimer(minutes: Int) {
        timerDuration = TimeInterval(minutes * 60)
        timerTimeLeft = isStopwatchMode ? 0 : timerDuration
        pauseTimer()
        isTimerActive = true
        isTimerFinished = false
        stopwatchLaps.removeAll()
    }
    
    func startTimer() {
        isTimerRunning = true
        isTimerActive = true
        isTimerFinished = false
        // Anchor wall-clock time so ticks compute elapsed time directly,
        // avoiding accumulated drift from main-thread scheduling delays.
        timerWallAnchor = Date()
        timerAnchorValue = timerTimeLeft
        countdownTimer?.cancel()
        countdownTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let anchor = self.timerWallAnchor else { return }
                let elapsed = Date().timeIntervalSince(anchor)
                if self.isStopwatchMode {
                    self.timerTimeLeft = self.timerAnchorValue + elapsed
                } else {
                    let remaining = self.timerAnchorValue - elapsed
                    if remaining > 0 {
                        self.timerTimeLeft = remaining
                    } else {
                        self.timerTimeLeft = 0
                        self.timerFinished()
                    }
                }
            }
    }
    
    func pauseTimer() {
        isTimerRunning = false
        countdownTimer?.cancel()
        countdownTimer = nil
        // Clear wall-clock anchor so stale elapsed doesn't carry over on resume.
        timerWallAnchor = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timerTimeLeft = isStopwatchMode ? 0 : timerDuration
        isTimerActive = true
        isTimerFinished = false
        stopwatchLaps.removeAll()
    }
    
    func setStopwatchMode(_ enabled: Bool) {
        guard isStopwatchMode != enabled else { return }
        let wasRunning = isTimerRunning
        isStopwatchMode = enabled
        isTimerFinished = false
        resetTimer()
        if wasRunning {
            startTimer()
        }
    }
    
    func recordStopwatchLap() {
        guard isStopwatchMode, isTimerRunning else { return }
        let lapNumber = stopwatchLaps.count + 1
        let overallTime = timerTimeLeft
        
        let previousOverall = stopwatchLaps.last?.overallTime ?? 0.0
        let lapTime = overallTime - previousOverall
        
        let newLap = StopwatchLap(lapNumber: lapNumber, lapTime: lapTime, overallTime: overallTime)
        stopwatchLaps.append(newLap)
    }
    
    func adjustTimerTime(by seconds: TimeInterval) {
        if isStopwatchMode { return }
        
        let minDuration: TimeInterval = 10
        let maxDuration: TimeInterval = 3600 * 3
        
        let newDuration = max(minDuration, min(maxDuration, timerDuration + seconds))
        timerDuration = newDuration
        
        if isTimerFinished {
            isTimerFinished = false
            timerTimeLeft = max(0, seconds)
        } else {
            timerTimeLeft = max(0, min(timerDuration, timerTimeLeft + seconds))
            if timerTimeLeft <= 0 {
                timerFinished()
            }
        }
        // Re-anchor wall-clock if timer is currently running so the adjustment
        // takes effect immediately without accumulated drift.
        if isTimerRunning {
            timerWallAnchor = Date()
            timerAnchorValue = timerTimeLeft
        }
    }
    
    private func timerFinished() {
        pauseTimer()
        playAlertSound()
        
        // Trigger Canvas Flash overlay
        withAnimation(.easeInOut(duration: 0.15)) {
            showCanvasFlash = true
        }
        
        // Hold the flash briefly and fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                self.showCanvasFlash = false
            }
        }
        
        isTimerFinished = true
    }
    
    private func playAlertSound() {
        if alertSound == .silent { return }
        if let name = alertSound.systemSoundName, let sound = NSSound(named: name) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    // MARK: - Screen Capture and Clipboard features
    
    func copyToClipboard(image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    func captureScreen(targetScreen: NSScreen? = nil, cropToDrawings: Bool, saveToURL: URL? = nil, completion: @escaping @Sendable (Bool) -> Void) {
        let toolbarWasFront = self.isToolbarVisible
        if toolbarWasFront {
            self.toolbarPanel?.orderOut(nil)
            self.selectionHUDPanel?.orderOut(nil)
            self.timerHUDPanel?.orderOut(nil)
        }
        
        // Temporarily lower canvas window levels to .floating and disable ignoresMouseEvents so they are captured by screencapture
        for window in canvasWindows {
            window.level = .floating
            window.ignoresMouseEvents = false
        }
        
        // Let the toolbar window hide completely and level/ignoresMouseEvents change propagate to the Window Server
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            
            let screen = targetScreen ?? self.toolbarPanel?.screen ?? NSScreen.main ?? NSScreen.screens.first ?? NSScreen.screens[0]
            let screenFrame = screen.frame
            let targetScreenID = "\(screenFrame.origin.x),\(screenFrame.origin.y),\(screenFrame.size.width),\(screenFrame.size.height)"
            
            var args: [String] = []
            if saveToURL != nil {
                args = ["-x"]
            } else {
                args = ["-c", "-x"]
            }
            
            let screenElements: [DrawingElement]
            if self.isMirroringEnabled {
                screenElements = self.elements
            } else {
                screenElements = self.elements.filter { $0.screenID == targetScreenID }
            }
            
            var cropRect: CGRect? = nil
            if cropToDrawings && !screenElements.isEmpty {
                var unionBox = self.boundingBox(of: screenElements[0], mappedTo: targetScreenID)
                for element in screenElements {
                    unionBox = unionBox.union(self.boundingBox(of: element, mappedTo: targetScreenID))
                }
                let padding: CGFloat = 16
                unionBox = unionBox.insetBy(dx: -padding, dy: -padding)
                
                let screenBounds = CGRect(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
                let intersection = unionBox.intersection(screenBounds)
                if !intersection.isNull && !intersection.isEmpty {
                    cropRect = intersection
                }
            }
            
            // If cropToDrawings is false OR there are no drawings on the screen, we capture the full screen
            if cropRect == nil {
                cropRect = CGRect(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
            }
            
            if let cropRect = cropRect {
                let primaryHeight = NSScreen.screens.first?.frame.height ?? 1080
                let globalX = Int(screenFrame.origin.x + cropRect.minX)
                let globalY = Int((primaryHeight - screenFrame.maxY) + cropRect.minY)
                let w = Int(cropRect.width)
                let h = Int(cropRect.height)
                args.append(contentsOf: ["-R", "\(globalX),\(globalY),\(w),\(h)"])
            }
            
            if let saveToURL = saveToURL {
                args.append(saveToURL.path)
            }
            
            let finalArgs = args
            
            // Run the process in a background thread to avoid freezing the UI
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                task.arguments = finalArgs
                // Do NOT redirect stdout/stderr to Pipe() unless we actively drain them;
                // an un-drained pipe buffer fills up and deadlocks the subprocess.
                
                var success = false
                do {
                    try task.run()
                    task.waitUntilExit()
                    success = (task.terminationStatus == 0)
                } catch {
                    print("Failed to run screencapture: \(error)")
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    for window in self.canvasWindows {
                        window.level = .screenSaver
                    }
                    self.updateClickThrough() // Restore correct ignoresMouseEvents based on current state
                    
                    if toolbarWasFront {
                        self.toolbarPanel?.orderFront(nil)
                        self.updateSelectionHUDVisibility()
                        self.updateTimerHUDVisibility()
                    }
                    completion(success)
                }
            }
        }
    }
    
    func captureInteractiveRegion(saveToURL: URL? = nil, completion: @escaping @Sendable (Bool) -> Void) {
        let toolbarWasFront = self.isToolbarVisible
        if toolbarWasFront {
            self.toolbarPanel?.orderOut(nil)
            self.selectionHUDPanel?.orderOut(nil)
            self.timerHUDPanel?.orderOut(nil)
        }
        
        // Temporarily lower canvas window levels to .floating and disable ignoresMouseEvents so they are captured by screencapture
        for window in canvasWindows {
            window.level = .floating
            window.ignoresMouseEvents = false
        }
        
        // Let the toolbar window hide completely and level/ignoresMouseEvents change propagate to the Window Server
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            
            var args: [String] = ["-i"] // Interactive selection mode
            
            if saveToURL != nil {
                args.append("-x") // Soundless
            } else {
                args.append(contentsOf: ["-c", "-x"]) // Clipboard, soundless
            }
            
            if let saveToURL = saveToURL {
                args.append(saveToURL.path)
            }
            
            let finalArgs = args
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                task.arguments = finalArgs
                // Do NOT redirect stdout/stderr to Pipe() unless we actively drain them;
                // an un-drained pipe buffer fills up and deadlocks the subprocess.
                
                var success = false
                do {
                    try task.run()
                    task.waitUntilExit()
                    success = (task.terminationStatus == 0)
                } catch {
                    print("Failed to run screencapture: \(error)")
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    for window in self.canvasWindows {
                        window.level = .screenSaver
                    }
                    self.updateClickThrough() // Restore correct ignoresMouseEvents based on current state
                    
                    if toolbarWasFront {
                        self.toolbarPanel?.orderFront(nil)
                        self.updateSelectionHUDVisibility()
                        self.updateTimerHUDVisibility()
                    }
                    completion(success)
                }
            }
        }
    }
    
    func saveImage(_ image: NSImage, to url: URL) -> Bool {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return false
        }
        do {
            try pngData.write(to: url)
            return true
        } catch {
            print("Failed to save image: \(error)")
            return false
        }
    }
    
    func captureDrawingsOnly() -> NSImage? {
        let screen = self.toolbarPanel?.screen ?? NSScreen.main ?? NSScreen.screens.first ?? NSScreen.screens[0]
        let screenFrame = screen.frame
        let targetScreenID = "\(screenFrame.origin.x),\(screenFrame.origin.y),\(screenFrame.size.width),\(screenFrame.size.height)"
        
        let screenElements = elements.filter { $0.screenID == targetScreenID }
        guard !screenElements.isEmpty else { return nil }
        
        let renderer = ImageRenderer(content: CanvasView(manager: self, screen: screen, isCleanCapture: true).frame(width: screenFrame.width, height: screenFrame.height))
        renderer.scale = screen.backingScaleFactor
        
        guard let fullCGImage = renderer.cgImage else { return nil }
        
        var unionBox = boundingBox(of: screenElements[0])
        for element in screenElements {
            unionBox = unionBox.union(boundingBox(of: element))
        }
        let padding: CGFloat = 16
        unionBox = unionBox.insetBy(dx: -padding, dy: -padding)
        
        let screenBounds = CGRect(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
        let cropRect = unionBox.intersection(screenBounds)
        
        if cropRect.isNull || cropRect.isEmpty {
            return NSImage(cgImage: fullCGImage, size: screenFrame.size)
        }
        
        let scale = screen.backingScaleFactor
        let pixelCropRect = CGRect(
            x: cropRect.minX * scale,
            y: cropRect.minY * scale,
            width: cropRect.width * scale,
            height: cropRect.height * scale
        )
        
        guard let croppedCGImage = fullCGImage.cropping(to: pixelCropRect) else {
            return NSImage(cgImage: fullCGImage, size: cropRect.size)
        }
        
        return NSImage(cgImage: croppedCGImage, size: cropRect.size)
    }
    
    // MARK: - Clear
    
    func clearAll() {
        if !elements.isEmpty { recordState() }
        elements.removeAll()
        currentElement = nil
        selectedElementId = nil
        updateWindowsKeyFocus()
    }
    
    // MARK: - Math helpers
    
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
    
    private func distanceToSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x, dy = b.y - a.y
        let lenSq = dx*dx + dy*dy
        if lenSq == 0 { return distance(p, a) }
        let t = max(0, min(1, ((p.x - a.x)*dx + (p.y - a.y)*dy) / lenSq))
        let proj = CGPoint(x: a.x + t*dx, y: a.y + t*dy)
        return distance(p, proj)
    }
    
    // MARK: - Text Editing State Helpers
    
    func addTextElement(at point: CGPoint, screenID: String) {
        commitAllActiveTextElements()
        recordState()
        
        let newElement = DrawingElement(
            tool: .text,
            points: [DrawingPoint(location: point, pressure: 1.0, width: 2.0)],
            color: selectedColor,
            lineWidth: 2.0,
            opacity: selectedOpacity,
            screenID: screenID,
            text: "",
            isEditing: true,
            textSize: measureText("", fontSize: defaultFontSize, fontFamily: defaultFontFamily),
            fontSize: defaultFontSize,
            fontFamily: defaultFontFamily
        )
        elements.append(newElement)
        updateWindowsKeyFocus()
    }
    
    func getMaxTextWidth(for element: DrawingElement) -> CGFloat {
        let screenWidth: CGFloat = {
            if let size = self.size(from: element.screenID) {
                return size.width
            }
            return NSScreen.main?.frame.size.width ?? 1920.0
        }()
        let startX = element.points.first?.location.x ?? 0.0
        return max(200.0, screenWidth - startX - 40.0)
    }
    
    func updateTextElement(id: UUID, text: String, size: CGSize) {
        if let idx = elements.firstIndex(where: { $0.id == id }) {
            elements[idx].text = text
            elements[idx].textSize = size
        }
    }
    
    func commitTextElement(id: UUID) {
        if let idx = elements.firstIndex(where: { $0.id == id }) {
            elements[idx].isEditing = false
            if (elements[idx].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                elements.remove(at: idx)
                _ = undoStack.popLast()
            } else {
                recordState()
            }
            updateWindowsKeyFocus()
        }
    }
    
    func commitAllActiveTextElements() {
        var committedAny = false
        for idx in elements.indices {
            if elements[idx].tool == .text && elements[idx].isEditing {
                elements[idx].isEditing = false
                committedAny = true
            }
        }
        
        let originalCount = elements.count
        elements.removeAll { $0.tool == .text && !$0.isEditing && ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let removedCount = originalCount - elements.count
        
        if committedAny {
            if removedCount > 0 && elements.isEmpty {
                _ = undoStack.popLast()
            } else if removedCount > 0 && !undoStack.isEmpty {
                if let lastState = undoStack.last, lastState.elements.count == elements.count {
                    let match = zip(lastState.elements, elements).allSatisfy { $0.0.id == $0.1.id }
                    if match {
                        _ = undoStack.popLast()
                    } else {
                        recordState()
                    }
                } else {
                    recordState()
                }
            } else {
                recordState()
            }
            updateWindowsKeyFocus()
        }
    }
    
    func updateWindowsKeyFocus() {
        let isEditing = elements.contains { $0.tool == .text && $0.isEditing }
        KeyboardShortcuts.isEnabled = !isEditing
        
        for window in canvasWindows {
            if let canvas = window as? CanvasWindow {
                canvas.allowsKeyFocus = isEditing
            }
        }
        
        if isEditing {
            if self.previouslyActiveApp == nil,
               let frontmost = NSWorkspace.shared.frontmostApplication,
               frontmost.bundleIdentifier != Bundle.main.bundleIdentifier {
                self.previouslyActiveApp = frontmost
            }
            if #available(macOS 14.0, *) {
                NSApplication.shared.activate()
            } else {
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            if let activeWindow = canvasWindows.first(where: { NSScreen.main == $0.screen }) ?? canvasWindows.first {
                activeWindow.makeKey()
            }
        } else {
            for window in canvasWindows {
                window.orderFront(nil)
            }
            if let app = self.previouslyActiveApp {
                if #available(macOS 14.0, *) {
                    NSApplication.shared.yieldActivation(to: app)
                    app.activate()
                } else {
                    app.activate(options: [.activateIgnoringOtherApps])
                }
                self.previouslyActiveApp = nil
            } else if NSApplication.shared.isActive {
                NSApplication.shared.deactivate()
            }
        }
    }
}

// MARK: - CGPoint Arithmetic Helpers
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint { CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint { CGPoint(x: lhs.x / rhs, y: lhs.y / rhs) }

extension CGPoint {
    func length() -> CGFloat { sqrt(x*x + y*y) }
    func normalized() -> CGPoint {
        let len = length()
        return len > 0 ? CGPoint(x: x / len, y: y / len) : .zero
    }
}

extension CGRect {
    init(from point1: CGPoint, to point2: CGPoint) {
        let x = min(point1.x, point2.x)
        let y = min(point1.y, point2.y)
        let width = abs(point1.x - point2.x)
        let height = abs(point1.y - point2.y)
        self.init(x: x, y: y, width: width, height: height)
    }
}

// MARK: - Color Hex Extensions
extension Color {
    func toHex() -> String? {
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
            return nil
        }
        let r = Int(min(max(round(rgbColor.redComponent * 255.0), 0.0), 255.0))
        let g = Int(min(max(round(rgbColor.greenComponent * 255.0), 0.0), 255.0))
        let b = Int(min(max(round(rgbColor.blueComponent * 255.0), 0.0), 255.0))
        let a = Int(min(max(round(rgbColor.alphaComponent * 255.0), 0.0), 255.0))
        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
    
    static func fromHex(_ hex: String) -> Color? {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&rgbValue) else {
            return nil
        }
        
        let length = cleanHex.count
        if length == 6 {
            let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgbValue & 0x0000FF) / 255.0
            return Color(red: r, green: g, blue: b)
        } else if length == 8 {
            let r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(rgbValue & 0x000000FF) / 255.0
            return Color(red: r, green: g, blue: b, opacity: a)
        }
        return nil
    }
}

struct SendableEventMonitor: @unchecked Sendable {
    let monitor: Any
}
