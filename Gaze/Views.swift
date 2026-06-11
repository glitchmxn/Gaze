import SwiftUI
import AppKit

// MARK: - Visual Effect View (Glassmorphism)
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var cornerRadius: CGFloat

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Toolbar View
struct ToolbarView: View {
    @ObservedObject var manager: AppManager
    @State private var isTrashHovering = false
    @State private var isTimerHovering = false
    @State private var isCanvasHovering = false
    @State private var showThicknessPopover = false
    @State private var showCanvasModePopover = false
    @State private var showTimerPopover = false
    @State private var isTimerClockHovering = false
    @State private var isTimerPlayPauseHovering = false
    @State private var isTimerResetHovering = false
    @State private var isRedoHovering = false
    @State private var isUndoHovering = false
    @State private var timerPulse = false
    
    // Curated dark-mode style colors
    let colors: [Color] = [
        .black,
        .white,
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.19, green: 0.82, blue: 0.35),
        Color(red: 0.04, green: 0.52, blue: 1.0)
    ]
    
    var body: some View {
        Group {
            if manager.isCompact {
                CompactToolbarView(manager: manager)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.92)),
                        removal: .opacity.combined(with: .scale(scale: 0.92))
                    ))
            } else {
                expandedToolbar
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.96)),
                        removal: .opacity.combined(with: .scale(scale: 0.96))
                    ))
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: manager.isCompact)
        .frame(height: 78)
        .frame(maxWidth: .infinity)
        .containerShape(.capsule)
        .onHover { hovering in
            manager.isMouseOverToolbar = hovering
        }
    }

    @ViewBuilder
    private var expandedToolbar: some View {
        GlassEffectContainer {
            HStack(spacing: 6) {
                // Tools Group (including Collapse button)
                HStack(spacing: 3) {
                    CollapseButton(manager: manager)
                    ToolButton(tool: .cursor, iconName: "pointer.arrow.ipad", activeTool: manager.selectedTool) {
                        manager.selectedTool = .cursor
                    }
                    .help("Interact with apps (Cursor)")
                    PencilToolButton(manager: manager)
                        .help("Draw (Pencil) / Hold for settings")
                    ToolButton(tool: .highlighter, iconName: "highlighter", activeTool: manager.selectedTool) {
                        manager.selectedTool = .highlighter
                    }
                    .help("Highlight (Highlighter)")
                    ShapeToolButton(manager: manager)
                        .help("Draw Shapes / Hold for settings")
                    let textTool = Tool.text
                    ToolButton(tool: textTool, iconName: textTool.iconName, activeTool: manager.selectedTool) {
                        manager.selectedTool = .text
                    }
                    .help("Type Text (Text)")
                    let selectTool = Tool.select
                    ToolButton(tool: selectTool, iconName: selectTool.iconName, activeTool: manager.selectedTool) {
                        manager.selectedTool = .select
                    }
                    .help("Lasso Select & Move")
                    LaserToolButton(manager: manager)
                        .help("Laser Pointer (Laser) / Hold for settings")
                    ToolButton(tool: .eraser, iconName: "eraser", activeTool: manager.selectedTool) {
                        manager.selectedTool = .eraser
                    }
                    .help("Erase (Eraser)")
                }

                Color.primary.opacity(0.07).frame(width: 1, height: 18)

                // Colors Group
                HStack(spacing: 3) {
                    ForEach(colors, id: \.self) { color in
                        ColorCircle(color: color, isSelected: manager.selectedColor == color) {
                            manager.selectedColor = color
                        }
                    }
                    CustomColorButton(manager: manager)
                }

                Color.primary.opacity(0.07).frame(width: 1, height: 18)

                // Actions Group
                HStack(spacing: 3) {
                    ScrollerTool(manager: manager)
                    if manager.isTimerActive && !manager.isTimerDetached {
                        HStack(spacing: 3) {
                            Button(action: { showTimerPopover.toggle() }) {
                                Text(timeString(from: manager.timerTimeLeft))
                                    .font(.system(size: 14, weight: .semibold))
                                    .monospacedDigit()
                                    .foregroundColor((manager.isTimerFinished || (!manager.isStopwatchMode && manager.timerTimeLeft <= 60)) ? Color(red: 1.0, green: 0.27, blue: 0.23) : .primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .scaleEffect(isTimerClockHovering ? 1.04 : 1.0)
                                    .opacity(manager.isTimerFinished ? (timerPulse ? 0.35 : 1.0) : (manager.isTimerRunning ? 1.0 : 0.7))
                            }
                            .buttonStyle(.plain)
                            .onHover { hovering in
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    isTimerClockHovering = hovering
                                }
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                    timerPulse = true
                                }
                            }
                            
                            Button(action: {
                                if manager.isTimerRunning { manager.pauseTimer() } else { manager.startTimer() }
                            }) {
                                Image(systemName: manager.isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isTimerPlayPauseHovering ? .primary : .secondary)
                                    .scaleEffect(isTimerPlayPauseHovering ? 1.12 : 1.0)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTimerPlayPauseHovering)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            .onHover { isTimerPlayPauseHovering = $0 }
                            
                            Button(action: { manager.resetTimer() }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isTimerResetHovering ? .primary : .secondary)
                                    .scaleEffect(isTimerResetHovering ? 1.12 : 1.0)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTimerResetHovering)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            .onHover { isTimerResetHovering = $0 }
                        }
                    }
                    Button(action: {
                        if manager.isTimerDetached {
                            showTimerPopover.toggle()
                        } else {
                            if manager.isTimerActive {
                                manager.pauseTimer()
                                manager.isTimerActive = false
                            } else {
                                manager.isTimerActive = true
                            }
                        }
                    }) {
                        Image(systemName: manager.isStopwatchMode ? "stopwatch" : "timer")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(manager.isTimerActive ? Color(red: 1.0, green: 0.27, blue: 0.23) : (isTimerHovering ? .primary : .secondary))
                            .scaleEffect(isTimerHovering ? 1.08 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTimerHovering)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .onHover { isTimerHovering = $0 }
                    .popover(isPresented: $showTimerPopover, arrowEdge: .top) {
                        TimerSettingsPopoverView(manager: manager, isPresented: $showTimerPopover)
                            .presentationBackground(.clear)
                    }
                    Image(systemName: manager.canvasColor != .none ? "inset.filled.square.dashed" : "square.dashed")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(manager.canvasColor != .none ? .primary : (isCanvasHovering ? .primary : .secondary))
                        .scaleEffect(isCanvasHovering ? 1.08 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isCanvasHovering)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if manager.canvasColor != .none { manager.canvasColor = .none }
                            else { manager.canvasColor = manager.lastActiveCanvasColor }
                        }
                        .onLongPressGesture(minimumDuration: 0.4) { showCanvasModePopover = true }
                        .onHover { isCanvasHovering = $0 }
                        .popover(isPresented: $showCanvasModePopover, arrowEdge: .top) {
                            CanvasModePickerView(manager: manager, isPresented: $showCanvasModePopover)
                                .presentationBackground(.clear)
                        }
                    Button(action: { manager.undo() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(manager.undoStack.isEmpty ? .secondary.opacity(0.3) : (isUndoHovering ? .primary : .secondary))
                            .scaleEffect(isUndoHovering ? 1.08 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isUndoHovering)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .disabled(manager.undoStack.isEmpty)
                    .onHover { isUndoHovering = $0 }
                    .overlay(alignment: .topTrailing) {
                        if !manager.undoStack.isEmpty && isUndoHovering {
                            Text("\(manager.undoStack.count)")
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .glassEffect(.regular, in: Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                                                startPoint: .top, endPoint: .bottom
                                            ),
                                            lineWidth: 0.8
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
                                .offset(x: 0, y: 2)
                                .allowsHitTesting(false)
                                .transition(.scale(scale: 0.7, anchor: .topTrailing).combined(with: .opacity))
                                .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isUndoHovering)
                        }
                    }
                    Button(action: { manager.redo() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(manager.redoStack.isEmpty ? .secondary.opacity(0.3) : (isRedoHovering ? .primary : .secondary))
                            .scaleEffect(isRedoHovering ? 1.08 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isRedoHovering)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .disabled(manager.redoStack.isEmpty)
                    .onHover { isRedoHovering = $0 }
                    .overlay(alignment: .topTrailing) {
                        if !manager.redoStack.isEmpty && isRedoHovering {
                            Text("\(manager.redoStack.count)")
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .glassEffect(.regular, in: Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                                                startPoint: .top, endPoint: .bottom
                                            ),
                                            lineWidth: 0.8
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
                                .offset(x: 0, y: 2)
                                .allowsHitTesting(false)
                                .transition(.scale(scale: 0.7, anchor: .topTrailing).combined(with: .opacity))
                                .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isRedoHovering)
                        }
                    }
                    CaptureToolButton(manager: manager)
                    Button(action: { manager.clearAll() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(isTrashHovering ? .red : .secondary)
                            .scaleEffect(isTrashHovering ? 1.08 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTrashHovering)
                            .frame(width: 30, height: 30)
                    }.buttonStyle(.plain).onHover { isTrashHovering = $0 }
                }
            }
            .padding(.horizontal, 6)
            .frame(height: 38)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule().stroke(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
// MARK: - Compact Toolbar

struct CompactToolbarView: View {
    @ObservedObject var manager: AppManager
    @State private var isExpandHovering = false
    @State private var showTimerPopover = false
    @State private var isTimerHovering = false
    @State private var timerPulse = false
    @State private var isTimerClockHovering = false
    @State private var isTimerPlayPauseHovering = false
    @State private var isTimerResetHovering = false
    // Remembers the last non-cursor tool so the active slot never shows cursor
    @State private var lastNonCursorTool: Tool = .pencil

    private var activeToolIcon: String {
        let tool = lastNonCursorTool
        return tool == .shape ? manager.selectedShape.iconName : tool.iconName
    }

    private var activeToolHelpText: String {
        switch lastNonCursorTool {
        case .pencil: return "Draw (Pencil)"
        case .highlighter: return "Highlight (Highlighter)"
        case .shape: return "Draw Shapes"
        case .text: return "Write Text"
        case .select: return "Select & Move"
        case .laser: return "Laser Pointer"
        default: return ""
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 3) {
                // 1. Expand chevron
                Button(action: {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                        manager.isCompact = false
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isExpandHovering ? .primary : .secondary)
                        .scaleEffect(isExpandHovering ? 1.04 : 1.0)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .onHover { isExpandHovering = $0 }
                .help("Expand Toolbar")

                // 2. Fixed cursor shortcut
                ToolButton(tool: .cursor, iconName: "pointer.arrow.ipad", activeTool: manager.selectedTool) {
                    manager.selectedTool = .cursor
                }
                .help("Interact with apps (Cursor)")

                // 3. Active tool icon — always shows last non-cursor, non-eraser tool
                if lastNonCursorTool == .pencil {
                    PencilToolButton(manager: manager)
                        .help(activeToolHelpText + " / Hold for settings")
                } else if lastNonCursorTool == .shape {
                    ShapeToolButton(manager: manager)
                        .help(activeToolHelpText + " / Hold for settings")
                } else {
                    ToolButton(tool: lastNonCursorTool, iconName: activeToolIcon, activeTool: manager.selectedTool) {
                        manager.selectedTool = lastNonCursorTool
                    }
                    .help(activeToolHelpText)
                }

                // 4. Fixed eraser shortcut
                ToolButton(tool: .eraser, iconName: "eraser", activeTool: manager.selectedTool) {
                    manager.selectedTool = .eraser
                }
                .help("Erase (Eraser)")

                // 5. Dedicated timer button or active digital clock (only visible when active)
                // 6. Capsule color picker
                CustomColorButton(manager: manager)
                    .help("Color Picker")

                // 5. Dedicated timer button or active digital clock (only visible when active)
                if manager.isTimerActive {
                    if manager.isTimerDetached {
                        Button(action: { showTimerPopover.toggle() }) {
                            Image(systemName: manager.isStopwatchMode ? "stopwatch" : "timer")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.23))
                                .scaleEffect(isTimerHovering ? 1.08 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTimerHovering)
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                isTimerHovering = hovering
                            }
                        }
                        .popover(isPresented: $showTimerPopover, arrowEdge: .top) {
                            TimerSettingsPopoverView(manager: manager, isPresented: $showTimerPopover)
                                .presentationBackground(.clear)
                        }
                        .help("Timer Settings")
                    } else {
                        HStack(spacing: 3) {
                            Button(action: { showTimerPopover.toggle() }) {
                                Text(timeString(from: manager.timerTimeLeft))
                                    .font(.system(size: 14, weight: .semibold))
                                    .monospacedDigit()
                                    .foregroundColor((manager.isTimerFinished || (!manager.isStopwatchMode && manager.timerTimeLeft <= 60)) ? Color(red: 1.0, green: 0.27, blue: 0.23) : .primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .scaleEffect(isTimerClockHovering ? 1.04 : 1.0)
                                    .opacity(manager.isTimerFinished ? (timerPulse ? 0.35 : 1.0) : (manager.isTimerRunning ? 1.0 : 0.7))
                            }
                            .buttonStyle(.plain)
                            .onHover { hovering in
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    isTimerClockHovering = hovering
                                }
                            }
                            
                            Button(action: {
                                if manager.isTimerRunning { manager.pauseTimer() } else { manager.startTimer() }
                            }) {
                                Image(systemName: manager.isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isTimerPlayPauseHovering ? .primary : .secondary)
                                    .scaleEffect(isTimerPlayPauseHovering ? 1.12 : 1.0)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTimerPlayPauseHovering)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            .onHover { isTimerPlayPauseHovering = $0 }
                            
                            Button(action: { manager.resetTimer() }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(isTimerResetHovering ? .primary : .secondary)
                                    .scaleEffect(isTimerResetHovering ? 1.12 : 1.0)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isTimerResetHovering)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            .onHover { isTimerResetHovering = $0 }
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                timerPulse = true
                            }
                        }
                        .popover(isPresented: $showTimerPopover, arrowEdge: .top) {
                            TimerSettingsPopoverView(manager: manager, isPresented: $showTimerPopover)
                                .presentationBackground(.clear)
                        }
                        .help("Timer Settings (\(timeString(from: manager.timerTimeLeft)) left)")
                    }
                }
            }
            .padding(.horizontal, 6)
            .frame(height: 38)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule().stroke(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
        }
        .onAppear {
            if manager.selectedTool != .cursor && manager.selectedTool != .eraser {
                lastNonCursorTool = manager.selectedTool
            }
        }
        .onChange(of: manager.selectedTool) { _, tool in
            if tool != .cursor && tool != .eraser {
                lastNonCursorTool = tool
            }
        }
    }

}

struct CollapseButton: View {
    @ObservedObject var manager: AppManager
    @State private var isHovering = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                manager.isCompact = true
            }
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isHovering ? .primary : .secondary)
                .scaleEffect(isHovering ? 1.12 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help("Collapse Toolbar")
    }
}

// MARK: - Components

struct ToolButton: View {
    let tool: Tool
    let iconName: String
    let activeTool: Tool
    let action: () -> Void
    @State private var isHovering = false
    
    var isSelected: Bool { tool == activeTool }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: iconName == "lasso" ? 20 : 18, weight: .regular))
                .offset(y: iconName == "lasso" ? 1.4 : 0)
                .foregroundColor(isSelected ? .primary : (isHovering ? .primary : .secondary))
                .scaleEffect(isHovering ? 1.08 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

struct ColorCircle: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.primary.opacity(0.25), lineWidth: isSelected ? 1.8 : (color == .white ? 0.8 : 0))
                )
                .frame(width: 20, height: 20)
                .opacity(isSelected ? 1.0 : (isHovering ? 1.0 : 0.80))
                .scaleEffect(isHovering ? 1.15 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

struct CustomColorButton: View {
    @ObservedObject var manager: AppManager
    @State private var showCustomColorPopover = false
    @State private var isHovering = false
    
    let standardColors: [Color] = [
        .black,
        .white,
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.19, green: 0.82, blue: 0.35),
        Color(red: 0.04, green: 0.52, blue: 1.0)
    ]
    
    var isCustomSelected: Bool { !standardColors.contains(manager.selectedColor) }
    
    var body: some View {
        Button(action: { showCustomColorPopover.toggle() }) {
            Capsule()
                .fill(manager.selectedColor)
                .frame(width: 50, height: 16)
                .overlay(
                    Capsule()
                        .strokeBorder(isCustomSelected ? Color.primary.opacity(0.8) : Color.primary.opacity(0.15), lineWidth: isCustomSelected ? 1.8 : 0.8)
                )
                .frame(width: 60, height: 22)
                .opacity(isCustomSelected ? 1.0 : (isHovering ? 1.0 : 0.80))
                .scaleEffect(isHovering ? 1.10 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .popover(isPresented: $showCustomColorPopover, arrowEdge: .top) {
            CustomColorPickerView(selectedColor: $manager.selectedColor)
                .presentationBackground(.clear)
        }
    }
}

struct ScrollerTool: View {
    @ObservedObject var manager: AppManager
    @State private var showThicknessPopover = false
    @State private var isHovering = false
    
    var body: some View {
        Button(action: { showThicknessPopover.toggle() }) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(showThicknessPopover ? .primary : (isHovering ? .primary : .secondary))
                .scaleEffect(isHovering ? 1.08 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .popover(isPresented: $showThicknessPopover, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 12) {
                // Dynamic Brush Preview Bubble
                BrushPreviewBubble(
                    size: manager.strokeWidth,
                    color: manager.selectedColor,
                    opacity: manager.selectedTool == .highlighter ? (manager.selectedOpacity * 0.45) : manager.selectedOpacity
                )
                
                Divider()
                    .opacity(0.5)
                
                // Stroke Size Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Size")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    HStack(spacing: 10) {
                        Slider(value: $manager.strokeWidth, in: 2...40)
                            .tint(manager.selectedColor)
                            .frame(width: 130)
                        Text("\(Int(manager.strokeWidth)) pt")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                    
                    // Quick brush size presets
                    HStack(spacing: 6) {
                        ForEach([("Fine", 3.0), ("Medium", 8.0), ("Thick", 20.0)], id: \.0) { name, size in
                            Button(action: {
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                    manager.strokeWidth = CGFloat(size)
                                }
                            }) {
                                Text(name)
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Int(manager.strokeWidth) == Int(size) ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Int(manager.strokeWidth) == Int(size) ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                                    )
                                    .foregroundColor(Int(manager.strokeWidth) == Int(size) ? .primary : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                    .opacity(0.5)
                
                // Opacity Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Opacity")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    HStack(spacing: 10) {
                        Slider(value: $manager.selectedOpacity, in: 0.1...1.0)
                            .tint(manager.selectedColor)
                            .frame(width: 130)
                        Text("\(Int(round(manager.selectedOpacity * 100)))%")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
                
                Divider()
                    .opacity(0.5)
                
                // Stabilization Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stabilization")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    HStack(spacing: 10) {
                        Slider(value: $manager.freehandStabilization, in: 0.0...1.0)
                            .tint(manager.selectedColor)
                            .frame(width: 130)
                        Text("\(Int(round(manager.freehandStabilization * 100)))%")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                    
                    // Quick stabilization presets
                    HStack(spacing: 6) {
                        ForEach([("Off", 0.0), ("Standard", 0.45), ("High", 0.85)], id: \.0) { name, val in
                            Button(action: {
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                    manager.freehandStabilization = val
                                }
                            }) {
                                let isSelected = abs(manager.freehandStabilization - val) < 0.01
                                Text(name)
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(isSelected ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(isSelected ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                                    )
                                    .foregroundColor(isSelected ? .primary : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                

                
                Divider()
                    .opacity(0.5)
                
                // Resize Behavior Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resize Behavior")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    HStack(spacing: 6) {
                        Button(action: {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                manager.scaleLineWidth = true
                            }
                        }) {
                            Text("Scale Width")
                                .font(.system(size: 9, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(manager.scaleLineWidth ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(manager.scaleLineWidth ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                                )
                                .foregroundColor(manager.scaleLineWidth ? .primary : .secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                manager.scaleLineWidth = false
                            }
                        }) {
                            Text("Fixed Width")
                                .font(.system(size: 9, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(!manager.scaleLineWidth ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(!manager.scaleLineWidth ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                                )
                                .foregroundColor(!manager.scaleLineWidth ? .primary : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .frame(width: 220)
            .glassEffect(.regular, in: ConcentricRectangle())
            .overlay(
                ConcentricRectangle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
        }
    }
}

struct LaserToolButton: View {
    @ObservedObject var manager: AppManager
    @State private var isHovering = false
    @State private var showLaserPopover = false
    var isSelected: Bool { manager.selectedTool == .laser }
    var body: some View {
        Image(systemName: "smallcircle.filled.circle")
            .font(.system(size: 18, weight: .regular))
            .foregroundColor((isSelected || showLaserPopover) ? .primary : (isHovering ? .primary : .secondary))
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .onTapGesture { manager.selectedTool = .laser }
            .onLongPressGesture(minimumDuration: 0.4) { manager.selectedTool = .laser; showLaserPopover = true }
            .popover(isPresented: $showLaserPopover, arrowEdge: .top) {
                LaserSettingsPopoverView(manager: manager)
                    .presentationBackground(.clear)
            }
    }
}

struct LaserSettingsPopoverView: View {
    @ObservedObject var manager: AppManager
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Laser Pointer Mode")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .kerning(0.5)
                
                HStack(spacing: 6) {
                    ForEach(LaserMode.allCases) { mode in
                        Button(action: {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                manager.laserMode = mode
                            }
                        }) {
                            let isSelected = manager.laserMode == mode
                            Text(mode.displayName)
                                .font(.system(size: 9, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(isSelected ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isSelected ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                                )
                                .foregroundColor(isSelected ? .primary : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 140)
            }
        }
        .padding(16)
        .glassEffect(.regular, in: ConcentricRectangle())
        .overlay(
            ConcentricRectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
        )
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
    }
}

struct PencilToolButton: View {
    @ObservedObject var manager: AppManager
    @State private var isHovering = false
    @State private var showPencilPopover = false
    var isSelected: Bool { manager.selectedTool == .pencil }
    var body: some View {
        Image(systemName: "pencil.tip")
            .font(.system(size: 18, weight: .regular))
            .foregroundColor((isSelected || showPencilPopover) ? .primary : (isHovering ? .primary : .secondary))
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .onTapGesture { manager.selectedTool = .pencil }
            .onLongPressGesture(minimumDuration: 0.4) { manager.selectedTool = .pencil; showPencilPopover = true }
            .popover(isPresented: $showPencilPopover, arrowEdge: .top) {
                PencilSettingsPopoverView(manager: manager)
                    .presentationBackground(.clear)
            }
    }
}

struct PencilSettingsPopoverView: View {
    @ObservedObject var manager: AppManager
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pencil Pressure")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .kerning(0.5)
                
                HStack(spacing: 6) {
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                            manager.enablePressureSensitivity = false
                        }
                    }) {
                        let isSelected = !manager.enablePressureSensitivity
                        Text("Off")
                            .font(.system(size: 9, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(isSelected ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isSelected ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                            )
                            .foregroundColor(isSelected ? .primary : .secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                            manager.enablePressureSensitivity = true
                        }
                    }) {
                        let isSelected = manager.enablePressureSensitivity
                        Text("Pressure")
                            .font(.system(size: 9, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(isSelected ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isSelected ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                            )
                            .foregroundColor(isSelected ? .primary : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if manager.enablePressureSensitivity {
                    // Gamma Sensitivity
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Sensitivity")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            let valText = manager.pressureSensitivityFactor < 0.85 ? "Soft" : (manager.pressureSensitivityFactor > 1.25 ? "Firm" : "Standard")
                            Text(valText)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: 10) {
                            Slider(value: $manager.pressureSensitivityFactor, in: 0.3...2.0)
                                .tint(manager.selectedColor)
                                .frame(width: 130)
                            Text(String(format: "%.1fx", manager.pressureSensitivityFactor))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 36, alignment: .trailing)
                        }
                    }
                    
                    // Minimum Width Ratio
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Minimum Width")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                        HStack(spacing: 10) {
                            Slider(value: $manager.minimumWidthRatio, in: 0.1...0.8)
                                .tint(manager.selectedColor)
                                .frame(width: 130)
                            Text("\(Int(round(manager.minimumWidthRatio * 100)))%")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 36, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 220)
        .glassEffect(.regular, in: ConcentricRectangle())
        .overlay(
            ConcentricRectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
        )
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
    }
}

struct ShapeToolButton: View {
    @ObservedObject var manager: AppManager
    @State private var isHovering = false
    @State private var showShapesPopover = false
    var isSelected: Bool { manager.selectedTool == .shape }
    var body: some View {
        Image(systemName: manager.selectedShape.iconName)
            .font(.system(size: 18, weight: .regular))
            .foregroundColor((isSelected || showShapesPopover) ? .primary : (isHovering ? .primary : .secondary))
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .onTapGesture { manager.selectedTool = .shape }
            .onLongPressGesture(minimumDuration: 0.4) { manager.selectedTool = .shape; showShapesPopover = true }
            .popover(isPresented: $showShapesPopover, arrowEdge: .top) {
                ShapeTypePickerView(manager: manager, isPresented: $showShapesPopover)
                    .presentationBackground(.clear)
            }
    }
}

struct ShapeTypePickerView: View {
    @ObservedObject var manager: AppManager
    @Binding var isPresented: Bool
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(ShapeType.allCases) { shape in
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                            manager.selectedShape = shape
                            manager.selectedTool = .shape
                        }
                    }) {
                        Image(systemName: shape.iconName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(manager.selectedShape == shape ? .primary : .secondary)
                            .frame(width: 28, height: 28)
                    }.buttonStyle(.plain)
                }
            }
            

        }
        .padding(8)
        .glassEffect(.regular, in: ConcentricRectangle())
        .overlay(
            ConcentricRectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
        )
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
    }
}

struct CanvasColorCard: View {
    let colorType: CanvasColor
    let currentPattern: CanvasPattern
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Base color fill
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorType.color)
                    .frame(width: 44, height: 28)
                
                // Pattern overlay
                if currentPattern != .none && colorType != .none {
                    PatternOverlayView(color: colorType, pattern: currentPattern, step: 6, lineWidth: 0.4, dotSize: 1.2)
                        .frame(width: 44, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                // "None" strikethrough
                if colorType == .none {
                    Rectangle()
                        .fill(Color.red.opacity(0.75))
                        .frame(width: 30, height: 1.2)
                        .rotationEffect(.degrees(-33))
                }
                
                // Selection / hover ring
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isSelected
                            ? Color.accentColor
                            : (isHovering ? Color.primary.opacity(0.18) : Color.clear),
                        lineWidth: isSelected ? 2 : 1.5
                    )
                    .frame(width: 48, height: 32)
                
                // Check mark for selected state
                if isSelected {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white, Color.accentColor)
                                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                                .padding(2)
                        }
                    }
                    .frame(width: 44, height: 28)
                }
            }
            .frame(width: 48, height: 32)
            .scaleEffect(isHovering && !isSelected ? 1.05 : (isSelected ? 1.02 : 1.0))
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isHovering)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
    private func backgroundColor(for mode: CanvasColor) -> Color {
        mode.color
    }
}

struct CanvasModePickerView: View {
    @ObservedObject var manager: AppManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // ── Color Section ───────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                // Section header
                HStack(alignment: .center, spacing: 6) {
                    Text("Color")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    // Active color badge
                    HStack(spacing: 5) {
                        if manager.canvasColor != .none {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(manager.canvasColor.color)
                                .frame(width: 12, height: 12)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
                        }
                        Text(manager.canvasColor.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .animation(.easeInOut(duration: 0.15), value: manager.canvasColor)
                }
                
                // 6-column grid of color cards
                Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                    GridRow {
                        CanvasColorCard(colorType: .none,       currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .none)       { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .none } }
                        CanvasColorCard(colorType: .white,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .white)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .white } }
                        CanvasColorCard(colorType: .dark,       currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .dark)       { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .dark } }
                        CanvasColorCard(colorType: .chalkboard, currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .chalkboard) { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .chalkboard } }
                        CanvasColorCard(colorType: .paper,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .paper)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .paper } }
                        CanvasColorCard(colorType: .amber,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .amber)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .amber } }
                    }
                    GridRow {
                        CanvasColorCard(colorType: .blueprint, currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .blueprint) { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .blueprint } }
                        CanvasColorCard(colorType: .sage,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .sage)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .sage } }
                        CanvasColorCard(colorType: .obsidian,  currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .obsidian)  { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .obsidian } }
                        CanvasColorCard(colorType: .sand,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .sand)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .sand } }
                        CanvasColorCard(colorType: .mint,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .mint)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .mint } }
                        CanvasColorCard(colorType: .ocean,     currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .ocean)     { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .ocean } }
                    }
                    GridRow {
                        CanvasColorCard(colorType: .lavender, currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .lavender) { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .lavender } }
                        CanvasColorCard(colorType: .clay,     currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .clay)     { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .clay } }
                        CanvasColorCard(colorType: .midnight, currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .midnight) { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .midnight } }
                        CanvasColorCard(colorType: .rose,     currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .rose)     { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .rose } }
                        CanvasColorCard(colorType: .stone,    currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .stone)    { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .stone } }
                        CanvasColorCard(colorType: .slate,    currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .slate)    { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .slate } }
                    }
                    GridRow {
                        CanvasColorCard(colorType: .charcoal,   currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .charcoal)   { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .charcoal } }
                        CanvasColorCard(colorType: .cream,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .cream)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .cream } }
                        CanvasColorCard(colorType: .forest,     currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .forest)     { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .forest } }
                        CanvasColorCard(colorType: .lilac,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .lilac)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .lilac } }
                        CanvasColorCard(colorType: .terracotta, currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .terracotta) { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .terracotta } }
                        CanvasColorCard(colorType: .ice,        currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .ice)        { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .ice } }
                    }
                    GridRow {
                        CanvasColorCard(colorType: .steel,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .steel)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .steel } }
                        CanvasColorCard(colorType: .mustard,    currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .mustard)    { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .mustard } }
                        CanvasColorCard(colorType: .coral,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .coral)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .coral } }
                        CanvasColorCard(colorType: .plum,       currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .plum)       { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .plum } }
                        CanvasColorCard(colorType: .olive,      currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .olive)      { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .olive } }
                        CanvasColorCard(colorType: .sky,        currentPattern: manager.canvasPattern, isSelected: manager.canvasColor == .sky)        { withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { manager.canvasColor = .sky } }
                    }
                }
            }
            
            // ── Divider ─────────────────────────────────────────────
            Divider()
                .opacity(0.5)
            
            // ── Pattern Section ──────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                // Section header
                HStack(alignment: .center, spacing: 6) {
                    Text("Pattern")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(manager.canvasPattern.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                        .animation(.easeInOut(duration: 0.15), value: manager.canvasPattern)
                }
                
                // Animated segmented picker
                HStack(spacing: 0) {
                    ForEach(CanvasPattern.allCases) { item in
                        Button(action: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                manager.canvasPattern = item
                            }
                        }) {
                            VStack(spacing: 3) {
                                Image(systemName: iconForPattern(item))
                                    .font(.system(size: 11))
                                Text(item.displayName)
                                    .font(.system(size: 9, weight: .medium))
                            }
                            .foregroundColor(manager.canvasPattern == item ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .contentShape(ConcentricRectangle())
                            .background {
                                if manager.canvasPattern == item {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.primary.opacity(0.09))
                                        .matchedGeometryEffect(id: "patternHighlight", in: patternNamespace)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background(RoundedRectangle(cornerRadius: 9).fill(Color.primary.opacity(0.04)))
                

            }
            
            // ── Canvas Controls ──────────────────────────────────────
            if manager.canvasColor != .none {
                Divider()
                    .opacity(0.5)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Canvas Controls")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Show Navigator Map")
                            .font(.system(size: 11, weight: .medium))
                        Spacer()
                        Toggle("", isOn: $manager.isMiniMapEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .scaleEffect(0.8)
                    }
                    .padding(.top, 2)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zoom")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("\(Int(round(manager.zoomScale * 100)))%")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                manager.zoomScale = 1.0
                                manager.panOffset = .zero
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("Reset View")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.primary.opacity(0.08))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
                    
                    // ── Pages Section ──────────────────────────────────────
                    Divider()
                        .opacity(0.5)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Pages")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Page \(manager.currentPageIndex + 1) of \(manager.pages.count)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                    manager.switchToPage(at: manager.currentPageIndex - 1)
                                }
                            }) {
                                Text("Prev")
                                    .font(.system(size: 11, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 24)
                                    .background(Color.primary.opacity(0.06))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .disabled(manager.currentPageIndex == 0)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                    manager.addPage()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 24)
                                .background(Color.primary.opacity(0.06))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                    manager.switchToPage(at: manager.currentPageIndex + 1)
                                }
                            }) {
                                Text("Next")
                                    .font(.system(size: 11, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 24)
                                    .background(Color.primary.opacity(0.06))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .disabled(manager.currentPageIndex >= manager.pages.count - 1)
                        }
                        
                        // Custom segmented picker for PDF Export Destination
                        HStack(spacing: 0) {
                            ForEach(PDFExportDestination.allCases) { item in
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                        manager.pdfExportDestination = item
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: item.iconName)
                                            .font(.system(size: 10))
                                        Text(item.label)
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundColor(manager.pdfExportDestination == item ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 22)
                                    .contentShape(Rectangle())
                                    .background {
                                        if manager.pdfExportDestination == item {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.primary.opacity(0.09))
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(2)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.04)))
                        .padding(.top, 4)
                        
                        Button(action: {
                            manager.exportToPDF()
                            isPresented = false
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export All Pages to PDF")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(Color.primary.opacity(0.09))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        .padding(16)
        .frame(width: 340)
        .glassEffect(.regular, in: ConcentricRectangle())
        .overlay(
            ConcentricRectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
        )
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
    }
    
    @Namespace private var patternNamespace
    
    private func iconForPattern(_ pattern: CanvasPattern) -> String {
        switch pattern {
        case .none: return "square.fill"
        case .grid: return "grid"
        case .dot: return "circle.grid.3x3.fill"
        case .ruled: return "line.horizontal.3"
        }
    }
    
    private func colorSwatch(for color: CanvasColor) -> Color {
        color.color
    }
}

struct TinyTimerProgressRing: View {
    @ObservedObject var manager: AppManager
    
    
    var body: some View {
        let isFinished = manager.isTimerFinished
        let isStopwatch = manager.isStopwatchMode
        
        let progress: CGFloat = {
            if isFinished {
                return 0.0
            } else if isStopwatch {
                return 1.0
            } else {
                return manager.timerDuration > 0 ? CGFloat(max(0, min(1.0, manager.timerTimeLeft / manager.timerDuration))) : 0.0
            }
        }()
        
        let ringColor: Color = {
            if isFinished {
                return Color(red: 1.0, green: 0.27, blue: 0.23)
            } else if isStopwatch {
                return Color(red: 0.20, green: 0.78, blue: 0.35)
            } else if !isStopwatch && manager.timerTimeLeft <= 60 {
                return Color(red: 1.0, green: 0.27, blue: 0.23)
            } else {
                return Color.blue
            }
        }()
        
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 1.5)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: progress)
        }
        .frame(width: 12, height: 12)
    }
}

struct TimerProgressRingView: View {
    @ObservedObject var manager: AppManager
    @State private var pulse = false
    
    var body: some View {
        let isFinished = manager.isTimerFinished
        let isStopwatch = manager.isStopwatchMode
        let isRunning = manager.isTimerRunning
        
        let progress: CGFloat = {
            if isFinished {
                return 0.0
            } else if isStopwatch {
                return 1.0
            } else {
                return manager.timerDuration > 0 ? CGFloat(max(0, min(1.0, manager.timerTimeLeft / manager.timerDuration))) : 0.0
            }
        }()
        
        let ringColor: Color = {
            if isFinished {
                return Color(red: 1.0, green: 0.27, blue: 0.23)
            } else if isStopwatch {
                return Color(red: 0.20, green: 0.78, blue: 0.35)
            } else {
                return Color.blue
            }
        }()
        
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.04), lineWidth: 6)
            
            // Background breathing glow when active and running
            if isRunning && !isFinished {
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(ringColor.opacity(0.15), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .blur(radius: pulse ? 6 : 3)
                    .scaleEffect(pulse ? 1.02 : 0.98)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
            }
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [ringColor, ringColor.opacity(0.7), ringColor]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: progress)
                .opacity(isFinished ? (pulse ? 0.35 : 1.0) : (isRunning ? 1.0 : 0.6))
            
            VStack(spacing: 2) {
                Text(isFinished ? "FINISHED" : (isStopwatch ? "STOPWATCH" : (isRunning ? "COUNTDOWN" : "PAUSED")))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isFinished ? Color(red: 1.0, green: 0.27, blue: 0.23) : .secondary)
                    .kerning(1.0)
                
                Text(timeString(from: manager.timerTimeLeft))
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(isFinished ? Color(red: 1.0, green: 0.27, blue: 0.23) : .primary)
                    .opacity(isFinished ? (pulse ? 0.35 : 1.0) : 1.0)
                
                if isRunning {
                    Circle()
                        .fill(ringColor)
                        .frame(width: 4, height: 4)
                        .scaleEffect(pulse ? 0.7 : 1.3)
                } else if isFinished {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.23))
                        .opacity(pulse ? 0.35 : 1.0)
                } else {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 110, height: 110)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerSettingsPopoverView: View {
    @ObservedObject var manager: AppManager
    @Binding var isPresented: Bool
    
    @State private var isHoveredPreset: Int? = nil
    @State private var resetRotation: Double = 0
    @Namespace private var modeNamespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Detach button
            HStack {
                Text(manager.isStopwatchMode ? "Stopwatch" : "Timer")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        manager.isTimerDetached.toggle()
                        if manager.isTimerDetached {
                            isPresented = false
                        }
                    }
                }) {
                    Image(systemName: "pip.enter")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Detach Floating Timer HUD")
            }
            
            Divider()
                .opacity(0.5)
            
            // Mode Selector
            HStack(spacing: 0) {
                // Countdown Segment
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        manager.setStopwatchMode(false)
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 13))
                        Text("Timer")
                            .font(.system(size: 8, weight: .semibold))
                            .kerning(0.3)
                    }
                    .foregroundColor(!manager.isStopwatchMode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .contentShape(ConcentricRectangle())
                    .background {
                        if !manager.isStopwatchMode {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.primary.opacity(0.09))
                                .matchedGeometryEffect(id: "modeHighlight", in: modeNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Stopwatch Segment
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        manager.setStopwatchMode(true)
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "stopwatch")
                            .font(.system(size: 13))
                        Text("Stopwatch")
                            .font(.system(size: 8, weight: .semibold))
                            .kerning(0.3)
                    }
                    .foregroundColor(manager.isStopwatchMode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .contentShape(ConcentricRectangle())
                    .background {
                        if manager.isStopwatchMode {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.primary.opacity(0.09))
                                .matchedGeometryEffect(id: "modeHighlight", in: modeNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(3)
            .background(RoundedRectangle(cornerRadius: 9).fill(Color.primary.opacity(0.04)))
            
            // Render stopwatch laps
            if manager.isStopwatchMode && !manager.stopwatchLaps.isEmpty {
                Divider()
                    .opacity(0.5)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Laps")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(manager.stopwatchLaps.reversed()) { lap in
                                HStack {
                                    Text("Lap \(lap.lapNumber)")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(timeString(from: lap.lapTime))
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    Text(timeString(from: lap.overallTime))
                                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .frame(width: 44, alignment: .trailing)
                                }
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.primary.opacity(0.02)))
                            }
                        }
                    }
                    .frame(height: 70)
                }
            }
            
            // Countdown/Pomodoro presets & Sliders
            if !manager.isStopwatchMode {
                Divider()
                    .opacity(0.5)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Presets")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .kerning(0.5)
                        
                        HStack(spacing: 5) {
                            let minsList = [1, 5, 10, 25, 30, 60]
                            ForEach(minsList, id: \.self) { mins in
                                Button(action: {
                                    manager.timerDuration = TimeInterval(mins * 60)
                                    if !manager.isTimerRunning {
                                        manager.timerTimeLeft = manager.timerDuration
                                    }
                                }) {
                                    Text("\(mins)m")
                                        .font(.system(size: 11, weight: .medium))
                                        .frame(width: 32, height: 26)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Int(manager.timerDuration / 60) == mins ? Color.primary.opacity(0.14) : Color.primary.opacity(isHoveredPreset == mins ? 0.08 : 0.04))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Int(manager.timerDuration / 60) == mins ? Color.primary.opacity(0.35) : Color.clear, lineWidth: 1)
                                        )
                                        .foregroundColor(Int(manager.timerDuration / 60) == mins ? .primary : .primary.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                                .onHover { hovering in
                                    isHoveredPreset = hovering ? mins : nil
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Duration")
                                .font(.system(size: 11, weight: .medium))
                            Spacer()
                            Text("\(Int(manager.timerDuration / 60)) min")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(manager.timerDuration / 60) },
                                set: {
                                    let rounded = max(1.0, round($0))
                                    manager.timerDuration = rounded * 60
                                    if !manager.isTimerRunning {
                                        manager.timerTimeLeft = manager.timerDuration
                                    }
                                }
                            ),
                            in: 1...60,
                            step: 1
                        )
                        .labelsHidden()
                        
                        // Quick Modifiers
                        HStack(spacing: 5) {
                            ForEach([-5, -1, 1, 5], id: \.self) { diff in
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                        manager.adjustTimerTime(by: TimeInterval(diff * 60))
                                    }
                                }) {
                                    Text(diff > 0 ? "+\(diff)m" : "\(diff)m")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 22)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.primary.opacity(0.04))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                
                Divider()
                    .opacity(0.5)
                
                // Sound Alerts Picker
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Alert sound")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .kerning(0.5)
                        Spacer()
                        Picker("", selection: $manager.alertSound) {
                            ForEach(TimerAlertSound.allCases) { sound in
                                Text(sound.rawValue).tag(sound)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .scaleEffect(0.9)
                        .frame(width: 140, alignment: .trailing)
                    }
                }
            }
            
            Divider()
                .opacity(0.5)
            
            // Bottom control actions
            HStack(spacing: 8) {
                if manager.isStopwatchMode {
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                            manager.recordStopwatchLap()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 10))
                            Text("Lap")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(manager.isTimerRunning ? .primary : .secondary.opacity(0.5))
                        .frame(width: 58, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(manager.isTimerRunning ? Color.primary.opacity(0.12) : Color.primary.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(manager.isTimerRunning ? Color.primary.opacity(0.25) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!manager.isTimerRunning)
                    .help("Record Lap Split")
                }
                
                Button(action: {
                    if manager.isTimerFinished {
                        manager.resetTimer()
                        manager.startTimer()
                    } else if manager.isTimerRunning {
                        manager.pauseTimer()
                    } else {
                        manager.startTimer()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: manager.isTimerFinished ? "arrow.clockwise" : (manager.isTimerRunning ? "pause.fill" : "play.fill"))
                            .font(.system(size: 10))
                        Text(manager.isTimerFinished ? "Restart" : (manager.isTimerRunning ? "Pause" : "Start"))
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(manager.isTimerRunning ? Color(red: 1.0, green: 0.27, blue: 0.23) : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(manager.isTimerRunning ? Color(red: 1.0, green: 0.27, blue: 0.23).opacity(0.12) : Color.primary.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(manager.isTimerRunning ? Color(red: 1.0, green: 0.27, blue: 0.23).opacity(0.25) : Color.primary.opacity(0.20), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                        resetRotation -= 360
                    }
                    manager.resetTimer()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(resetRotation))
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.primary.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
                .help("Reset Timer")
            }
        }
        .padding(16)
        .frame(width: 250)
        .glassEffect(.regular, in: ConcentricRectangle())
        .overlay(
            ConcentricRectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
        )
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum CaptureDestination: String, CaseIterable, Identifiable {
    case clipboard = "Clipboard", downloads = "Downloads", desktop = "Desktop"
    var id: String { self.rawValue }
    var label: String { self.rawValue }
}

struct CaptureToolButton: View {
    @ObservedObject var manager: AppManager
    @State private var showCapturePopover = false
    @State private var destination: CaptureDestination = .clipboard
    @State private var isHovering = false
    @State private var isHoveredFull = false
    @State private var isHoveredDrawings = false
    @State private var isHoveredRegion = false
    
    @Namespace private var destNamespace
    
    var body: some View {
        Button(action: { showCapturePopover.toggle() }) {
            Image(systemName: "camera")
                .font(.system(size: 18))
                .foregroundColor(showCapturePopover ? .primary : (isHovering ? .primary : .secondary))
                .scaleEffect(isHovering ? 1.04 : 1.0)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .popover(isPresented: $showCapturePopover, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Capture")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Divider()
                    .opacity(0.5)
                
                // Custom segmented picker
                HStack(spacing: 0) {
                    ForEach(CaptureDestination.allCases) { item in
                        Button(action: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                destination = item
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: iconForDestination(item))
                                    .font(.system(size: 13))
                                Text(item.label)
                                    .font(.system(size: 8, weight: .semibold))
                                    .kerning(0.3)
                            }
                            .foregroundColor(destination == item ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .contentShape(ConcentricRectangle())
                            .background {
                                if destination == item {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.primary.opacity(0.09))
                                        .matchedGeometryEffect(id: "destHighlight", in: destNamespace)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background(RoundedRectangle(cornerRadius: 9).fill(Color.primary.opacity(0.04)))
                
                Divider()
                    .opacity(0.5)
                
                // Capture Actions
                VStack(spacing: 8) {
                    Button(action: { 
                        let url: URL?
                        switch destination {
                        case .clipboard:
                            url = nil
                        case .desktop:
                            url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?
                                .appendingPathComponent("Gaze_Capture_\(Int(Date().timeIntervalSince1970)).png")
                        case .downloads:
                            url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
                                .appendingPathComponent("Gaze_Capture_\(Int(Date().timeIntervalSince1970)).png")
                        }
                        showCapturePopover = false
                        manager.captureScreen(targetScreen: nil, cropToDrawings: false, saveToURL: url) { success in 
                            Task { @MainActor in
                                if success {
                                    manager.triggerGlobalToast(url != nil ? "Saved!" : "Copied!")
                                } else {
                                    manager.triggerGlobalToast("Capture Failed!")
                                }
                            }
                        } 
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "display")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Full Screen")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isHoveredFull ? Color.primary.opacity(0.10) : Color.primary.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveredFull = $0 }
                    
                    Button(action: { 
                        let url: URL?
                        switch destination {
                        case .clipboard:
                            url = nil
                        case .desktop:
                            url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?
                                .appendingPathComponent("Gaze_Capture_\(Int(Date().timeIntervalSince1970)).png")
                        case .downloads:
                            url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
                                .appendingPathComponent("Gaze_Capture_\(Int(Date().timeIntervalSince1970)).png")
                        }
                        showCapturePopover = false
                        manager.captureInteractiveRegion(saveToURL: url) { success in 
                            Task { @MainActor in
                                if success {
                                    manager.triggerGlobalToast(url != nil ? "Saved!" : "Copied!")
                                } else {
                                    manager.triggerGlobalToast("Capture Cancelled")
                                }
                            }
                        } 
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "crop")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Selected Region")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isHoveredRegion ? Color.primary.opacity(0.10) : Color.primary.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveredRegion = $0 }
                    
                    Button(action: { 
                        showCapturePopover = false
                        if let img = manager.captureDrawingsOnly() {
                            let url: URL?
                            switch destination {
                            case .clipboard:
                                url = nil
                            case .desktop:
                                url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?
                                    .appendingPathComponent("Gaze_Drawing_\(Int(Date().timeIntervalSince1970)).png")
                            case .downloads:
                                url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
                                    .appendingPathComponent("Gaze_Drawing_\(Int(Date().timeIntervalSince1970)).png")
                            }
                            if let fileURL = url {
                                if manager.saveImage(img, to: fileURL) {
                                    manager.triggerGlobalToast("Saved!")
                                } else {
                                    manager.triggerGlobalToast("Save Failed!")
                                }
                            } else {
                                manager.copyToClipboard(image: img)
                                manager.triggerGlobalToast("Copied!")
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Drawings Only")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isHoveredDrawings ? Color.primary.opacity(0.10) : Color.primary.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveredDrawings = $0 }
                }
            }
            .padding(16)
            .frame(width: 220)
            .glassEffect(.regular, in: ConcentricRectangle())
            .overlay(
                ConcentricRectangle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
        }
    }
    
    private func iconForDestination(_ dest: CaptureDestination) -> String {
        switch dest {
        case .clipboard: return "doc.on.clipboard"
        case .downloads: return "arrow.down.circle"
        case .desktop: return "desktopcomputer"
        }
    }
}

struct GlobalToastView: View {
    let message: String
    
    var isError: Bool {
        message.contains("Failed") || message.contains("Cancelled")
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : .green)
                .font(.system(size: 14, weight: .semibold))
            Text(message)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .overlay(
            Capsule().stroke(
                LinearGradient(
                    colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

struct ShortcutToastHUD: View {
    let iconName: String
    let name: String
    let keys: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(0.06))
                )
            
            Text(name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .layoutPriority(1)
                .fixedSize(horizontal: true, vertical: false)
            
            Color.primary.opacity(0.12)
                .frame(width: 1, height: 16)
                .layoutPriority(1)
            
            // Keycaps representation
            HStack(spacing: 3) {
                ForEach(Array(keys), id: \.self) { char in
                    let charStr = String(char)
                    if charStr != " " {
                        Text(charStr)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.primary.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Color.primary.opacity(0.15), lineWidth: 0.8)
                            )
                            .layoutPriority(1)
                            .fixedSize(horizontal: true, vertical: false)
                    } else {
                        Spacer().frame(width: 4)
                    }
                }
            }
            .layoutPriority(1)
        }
        .padding(.horizontal, 14)
        .frame(height: 38)
        .glassEffect(.regular, in: .capsule)
        .overlay(
            Capsule().stroke(
                LinearGradient(
                    colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}



// MARK: - Keyboard Shortcuts Help

@MainActor
private struct ShortcutRow: Identifiable {
    let id = UUID()
    let name: KeyboardShortcuts.Name?
    let fallbackKeys: String
    let label: String
    
    var keysDisplay: String {
        if let name = name {
            if let shortcut = KeyboardShortcuts.getShortcut(for: name) {
                return shortcut.displayName
            } else if let initial = name.initialShortcut {
                return initial.displayName
            }
        }
        return fallbackKeys
    }
}

private struct ShortcutSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let rows: [ShortcutRow]
}

struct KeyboardShortcutsHelpView: View {
    var onClose: () -> Void

    private let sections: [ShortcutSection] = [
        ShortcutSection(title: "Tools", icon: "pencil.and.ruler", rows: [
            ShortcutRow(name: .selectCursor, fallbackKeys: "⌥1", label: "Cursor"),
            ShortcutRow(name: .selectPencil, fallbackKeys: "⌥2", label: "Pencil"),
            ShortcutRow(name: .selectHighlighter, fallbackKeys: "⌥3", label: "Highlighter"),
            ShortcutRow(name: .selectText, fallbackKeys: "⌥4", label: "Text"),
            ShortcutRow(name: .selectSelect, fallbackKeys: "⌥5", label: "Select"),
            ShortcutRow(name: .selectLaser, fallbackKeys: "⌥6", label: "Laser Pointer"),
            ShortcutRow(name: .selectEraser, fallbackKeys: "⌥7", label: "Eraser"),
        ]),
        ShortcutSection(title: "Shapes", icon: "square.on.circle", rows: [
            ShortcutRow(name: .shapeSquare, fallbackKeys: "⌘⌥1", label: "Square"),
            ShortcutRow(name: .shapeCircle, fallbackKeys: "⌘⌥2", label: "Circle"),
            ShortcutRow(name: .shapeTriangle, fallbackKeys: "⌘⌥3", label: "Triangle"),
            ShortcutRow(name: .shapeLine, fallbackKeys: "⌘⌥4", label: "Line"),
            ShortcutRow(name: .shapeArrow, fallbackKeys: "⌘⌥5", label: "Arrow"),
        ]),
        ShortcutSection(title: "Actions", icon: "bolt.fill", rows: [
            ShortcutRow(name: .undo, fallbackKeys: "⌥8",  label: "Undo"),
            ShortcutRow(name: .redo, fallbackKeys: "⌥9",  label: "Redo"),
            ShortcutRow(name: .deleteSelection, fallbackKeys: "⌘⇧K", label: "Delete Selected"),
            ShortcutRow(name: .clearScreen, fallbackKeys: "⌥-",  label: "Clear Screen"),
            ShortcutRow(name: .toggleCanvasMode, fallbackKeys: "⌥0",  label: "Canvas Mode"),
            ShortcutRow(name: .toggleTimer, fallbackKeys: "⌘⌥T", label: "Timer"),
            ShortcutRow(name: .triggerCapture, fallbackKeys: "⌘⌥C", label: "Capture"),
            ShortcutRow(name: .toggleMirroring, fallbackKeys: "⌘⌥M", label: "Mirror"),
            ShortcutRow(name: .toggleHUDDetached, fallbackKeys: "⌘⌥J", label: "Detach HUD"),
            ShortcutRow(name: nil, fallbackKeys: "⌥⇧",  label: "Interact with Apps"),
            ShortcutRow(name: .toggleToolbarVisibility, fallbackKeys: "⌥Q",  label: "Toggle Toolbar"),
        ]),
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Glass background using ConcentricRectangle (no shadow)
            ConcentricRectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    ConcentricRectangle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                )

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 10) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("Keyboard Shortcuts")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Divider
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)

                // Shortcut columns
                HStack(alignment: .top, spacing: 0) {
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 0) {
                            // Section header
                            HStack(spacing: 6) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Text(section.title.uppercased())
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.8)
                            }
                            .padding(.bottom, 10)
                            .padding(.top, 18)

                            // Rows
                            ForEach(section.rows) { row in
                                HStack(spacing: 10) {
                                    // Keycap badge
                                    Text(row.keysDisplay)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(Color.primary.opacity(0.07))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                        .stroke(Color.primary.opacity(0.14), lineWidth: 0.7)
                                                )
                                        )
                                        .frame(minWidth: 48, alignment: .center)

                                    Text(row.label)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(.primary.opacity(0.85))

                                    Spacer()
                                }
                                .padding(.bottom, 8)
                            }
                        }
                        .padding(.horizontal, 18)

                        if section.id != sections.last?.id {
                            Rectangle()
                                .fill(Color.primary.opacity(0.07))
                                .frame(width: 0.5)
                                .padding(.vertical, 16)
                        }
                    }
                }
                .padding(.bottom, 20)
            }

            // Close button
            Button(action: onClose) {
                ZStack {
                    Circle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 26, height: 26)
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(14)
            .keyboardShortcut(.escape, modifiers: [])
        }
        .frame(width: 680)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct CanvasFlashAlertView: View {

    @State private var pulse: CGFloat = 0.15
    
    var body: some View {
        let gradient = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.22, blue: 0.30).opacity(pulse),
                Color(red: 1.0, green: 0.40, blue: 0.20).opacity(pulse)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        GeometryReader { geometry in
            ZStack {
                // Top vignette
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.22, blue: 0.30).opacity(pulse * 0.4), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 16)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Bottom vignette
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.22, blue: 0.30).opacity(pulse * 0.4), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 16)
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                // Left vignette
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.22, blue: 0.30).opacity(pulse * 0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right vignette
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.22, blue: 0.30).opacity(pulse * 0.4), .clear],
                    startPoint: .trailing,
                    endPoint: .leading
                )
                .frame(width: 16)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Thick glowing blur backdrop (light bloom)
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(gradient, lineWidth: 6)
                    .blur(radius: 4)
                
                // Thin sharp core glow outline
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(gradient, lineWidth: 2)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulse = 0.6
            }
        }
    }
}

// MARK: - Canvas View
struct CanvasView: View {
    @ObservedObject var manager: AppManager
    let screen: NSScreen
    var isCleanCapture: Bool = false
    var forceIncludeBackground: Bool = false
    
    var screenID: String {
        "\(screen.frame.origin.x),\(screen.frame.origin.y),\(screen.frame.size.width),\(screen.frame.size.height)"
    }
    
    nonisolated private func strokeStyle(width: CGFloat) -> StrokeStyle {
        StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
    }
    
    var body: some View {
        let localManager = manager
        let elements = localManager.elements
        let currentElement = localManager.currentElement
        let isMirroringEnabled = localManager.isMirroringEnabled
        let mirroringScaleMode = localManager.mirroringScaleMode
        let scaleLineWidth = localManager.scaleLineWidth
        let activeSelectionScreenID = localManager.activeSelectionScreenID
        let activeSelectionLasso = localManager.activeSelectionLasso
        
        ZStack {
            if isCleanCapture || localManager.isToolbarVisible {
                if forceIncludeBackground {
                    CanvasBackgroundView(manager: localManager, color: localManager.canvasColor, pattern: localManager.canvasPattern)
                }
                
                if !isCleanCapture {
                    CanvasBackgroundView(manager: localManager, color: localManager.canvasColor, pattern: localManager.canvasPattern)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { localManager.selectedTool == .select ? localManager.handleSelectDragChanged($0, screenID: screenID) : localManager.handleDragChanged($0, screenID: screenID) }
                        .onEnded { localManager.selectedTool == .select ? localManager.handleSelectDragEnded($0, screenID: screenID) : localManager.handleDragEnded($0, screenID: screenID) })
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            localManager.updateCursorForCurrentTool()
                            if localManager.selectedTool == .laser {
                                localManager.handleLaserHover(location, screenID: screenID)
                            } else if localManager.selectedTool == .pencil || localManager.selectedTool == .highlighter {
                                localManager.handlePencilHover(location)
                            }
                        case .ended:
                            if localManager.selectedTool == .laser {
                                localManager.handleLaserHoverEnded()
                            } else if localManager.selectedTool == .pencil || localManager.selectedTool == .highlighter {
                                localManager.handlePencilHoverEnded()
                            }
                        }
                    }
                    .disabled(localManager.selectedTool == .cursor || localManager.selectedTool == .text || localManager.isOverrideActive)
                }
                
                // Text tool scrim: handles click-to-write and click-outside-to-commit
                if !isCleanCapture && (localManager.selectedTool == .text || localManager.elements.contains(where: { $0.isEditing })) && !localManager.isOverrideActive {
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    // Verify it was a quick click/tap and not a long drag gesture
                                    let translation = value.translation
                                    let distance = sqrt(translation.width * translation.width + translation.height * translation.height)
                                    if distance < 5 {
                                        if localManager.elements.contains(where: { $0.tool == .text && $0.isEditing }) {
                                            // Do nothing when clicking elsewhere while editing, forcing user to press Esc key to commit
                                        } else if localManager.selectedTool == .text {
                                            localManager.addTextElement(at: value.location, screenID: screenID)
                                        }
                                    }
                                }
                        )
                }
                
                // UNIFIED VECTOR CANVAS
                // High-performance single-pass rendering.
                Canvas { context, size in
                    var context = context
                    if localManager.isCanvasModeEnabled && localManager.canvasColor != .none {
                        context.translateBy(x: localManager.panOffset.x, y: localManager.panOffset.y)
                        context.scaleBy(x: localManager.zoomScale, y: localManager.zoomScale)
                    }
                    // Helper to draw an element locally with native coordinates
                    func drawNativeElement(_ element: DrawingElement, in ctx: inout GraphicsContext) {
                        if element.rotationAngle != 0 {
                            let center = localManager.elementCenter(element)
                            ctx.drawLayer { subContext in
                                subContext.translateBy(x: center.x, y: center.y)
                                subContext.rotate(by: .radians(element.rotationAngle))
                                subContext.translateBy(x: -center.x, y: -center.y)
                                if let cachedPath = element.cachedPath {
                                    subContext.stroke(cachedPath, with: .color(element.color.opacity(element.opacity)), style: strokeStyle(width: element.lineWidth))
                                } else {
                                    drawElement(element, in: &subContext)
                                }
                            }
                        } else {
                            if let cachedPath = element.cachedPath {
                                ctx.stroke(cachedPath, with: .color(element.color.opacity(element.opacity)), style: strokeStyle(width: element.lineWidth))
                            } else {
                                drawElement(element, in: &ctx)
                            }
                        }
                    }
                    
                    // Helper to draw an element mirrored with dynamic coordinate transform
                    func drawMirroredElement(_ element: DrawingElement, from srcScreenID: String, to destScreen: NSScreen, in ctx: inout GraphicsContext) {
                        guard let srcSize = localManager.size(from: srcScreenID) else {
                            drawNativeElement(element, in: &ctx)
                            return
                        }
                        let destSize = destScreen.frame.size
                        let transform = localManager.getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
                        let lwScale = localManager.lineWidthScale(from: srcSize, to: destSize, mode: mirroringScaleMode)
                        let strokeWidth = element.lineWidth * (scaleLineWidth ? lwScale : 1.0)
                        
                        let center = localManager.elementCenter(element)
                        let mappedCenter = center.applying(transform)
                        
                        if element.rotationAngle != 0 {
                            ctx.drawLayer { subContext in
                                subContext.translateBy(x: mappedCenter.x, y: mappedCenter.y)
                                subContext.rotate(by: .radians(element.rotationAngle))
                                subContext.translateBy(x: -mappedCenter.x, y: -mappedCenter.y)
                                
                                if let cachedPath = element.cachedPath {
                                    let transformedPath = cachedPath.applying(transform)
                                    subContext.stroke(transformedPath, with: .color(element.color.opacity(element.opacity)), style: strokeStyle(width: strokeWidth))
                                } else {
                                    var mappedElement = mapPoints(of: element, using: transform)
                                    mappedElement.lineWidth = strokeWidth
                                    drawElement(mappedElement, in: &subContext)
                                }
                            }
                        } else {
                            if let cachedPath = element.cachedPath {
                                let transformedPath = cachedPath.applying(transform)
                                ctx.stroke(transformedPath, with: .color(element.color.opacity(element.opacity)), style: strokeStyle(width: strokeWidth))
                            } else {
                                var mappedElement = mapPoints(of: element, using: transform)
                                mappedElement.lineWidth = strokeWidth
                                drawElement(mappedElement, in: &ctx)
                            }
                        }
                    }
                    
                    // Render Finished Strokes
                    for element in elements {
                        guard element.tool != .text else { continue }
                        let isCurrentScreen = element.screenID == screenID || element.screenID == nil
                        if isCurrentScreen {
                            drawNativeElement(element, in: &context)
                        } else if isMirroringEnabled, let elementScreenID = element.screenID {
                            drawMirroredElement(element, from: elementScreenID, to: screen, in: &context)
                        }
                    }
                    
                    // Render Active Stroke (Real-time)
                    if let current = currentElement, current.tool != .text {
                        let isCurrentScreen = current.screenID == screenID || current.screenID == nil
                        if isCurrentScreen {
                            drawNativeElement(current, in: &context)
                        } else if isMirroringEnabled, let elementScreenID = current.screenID {
                            drawMirroredElement(current, from: elementScreenID, to: screen, in: &context)
                        }
                    }
                    
                    // Render Fading Laser Pointer Trail / Dot
                    if !localManager.laserPoints.isEmpty {
                        let laserColor = localManager.selectedColor
                        
                        let laserPointsOnScreen: [LaserPoint] = localManager.laserPoints.compactMap { pt in
                            if pt.screenID == screenID {
                                return pt
                            } else if isMirroringEnabled {
                                if let srcSize = localManager.size(from: pt.screenID),
                                   let destSize = localManager.size(from: screenID) {
                                    let transform = localManager.getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
                                    return LaserPoint(location: pt.location.applying(transform), creationTime: pt.creationTime, screenID: screenID)
                                }
                            }
                            return nil
                        }
                        
                        let pts = laserPointsOnScreen
                        let active = localManager.isCanvasModeEnabled && localManager.canvasColor != .none
                        let zoom = active ? localManager.zoomScale : 1.0
                        
                        // 1. Draw Trail (only if in .trail mode)
                        if localManager.laserMode == .trail && pts.count >= 2 {
                            let originalOpacity = context.opacity
                            
                            struct LaserSegment {
                                let path: Path
                                let glowWidth: CGFloat
                                let coreWidth: CGFloat
                            }
                            var laserSegments: [LaserSegment] = []
                            laserSegments.reserveCapacity(pts.count)
                            for i in 0..<(pts.count - 1) {
                                let p0 = pts[max(0, i-1)].location
                                let p1 = pts[i].location
                                let p2 = pts[i+1].location
                                let p3 = pts[min(pts.count-1, i+2)].location
                                let cp = AppManager.getCatmullRomControlPoints(p0, p1, p2, p3)
                                
                                var segmentPath = Path()
                                segmentPath.move(to: p1)
                                segmentPath.addCurve(to: p2, control1: cp.0, control2: cp.1)
                                
                                let factor = Double(i + 1) / Double(pts.count - 1)
                                laserSegments.append(LaserSegment(
                                    path: segmentPath,
                                    glowWidth: (14.0 * factor) / zoom,
                                    coreWidth: (5.0 * factor) / zoom
                                ))
                            }
                            
                            // Draw outer neon glow layer
                            context.opacity = 0.35
                            context.drawLayer { layerContext in
                                for seg in laserSegments {
                                    layerContext.stroke(
                                        seg.path,
                                        with: .color(laserColor),
                                        style: StrokeStyle(lineWidth: seg.glowWidth, lineCap: .round, lineJoin: .round)
                                    )
                                }
                            }
                            
                            // Draw inner core layer
                            context.opacity = 0.95
                            context.drawLayer { layerContext in
                                for seg in laserSegments {
                                    layerContext.stroke(
                                        seg.path,
                                        with: .color(.white),
                                        style: StrokeStyle(lineWidth: seg.coreWidth, lineCap: .round, lineJoin: .round)
                                    )
                                }
                            }
                            context.opacity = originalOpacity
                        }
                        
                        // 2. Draw glowing pointer tip dot (rendered in both modes)
                        if let tip = pts.last {
                            // Outer neon glow
                            let glowRadius: CGFloat = 10 / zoom
                            let glowRect = CGRect(x: tip.location.x - glowRadius, y: tip.location.y - glowRadius, width: glowRadius * 2, height: glowRadius * 2)
                            context.fill(Path(ellipseIn: glowRect), with: .color(laserColor.opacity(0.35)))
                            
                            // Mid glow
                            let midRadius: CGFloat = 7 / zoom
                            let midRect = CGRect(x: tip.location.x - midRadius, y: tip.location.y - midRadius, width: midRadius * 2, height: midRadius * 2)
                            context.fill(Path(ellipseIn: midRect), with: .color(laserColor))
                            
                            // Inner white core
                            let innerRadius: CGFloat = 3.5 / zoom
                            let innerRect = CGRect(x: tip.location.x - innerRadius, y: tip.location.y - innerRadius, width: innerRadius * 2, height: innerRadius * 2)
                            context.fill(Path(ellipseIn: innerRect), with: .color(Color.white.opacity(0.95)))
                        }
                    }
                    
                }
                .allowsHitTesting(false)
                
                if !isCleanCapture && activeSelectionLasso != nil, let lassoPoints = activeSelectionLasso, lassoPoints.count >= 2 {
                    let activeLassoPoints: [CGPoint] = {
                        if isMirroringEnabled,
                           let activeLassoScreenID = activeSelectionScreenID,
                           activeLassoScreenID != screenID {
                            if let srcSize = localManager.size(from: activeLassoScreenID),
                               let destSize = localManager.size(from: screenID) {
                                let transform = localManager.getTransform(from: srcSize, to: destSize, mode: mirroringScaleMode)
                                return lassoPoints.map { $0.applying(transform) }
                            }
                        }
                        return lassoPoints
                    }()
                    
                    Path { path in
                        path.addLines(activeLassoPoints)
                        path.closeSubpath()
                    }
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        Path { path in
                            path.addLines(activeLassoPoints)
                            path.closeSubpath()
                        }
                        .stroke(Color.white.opacity(0.75), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    )
                    .allowsHitTesting(false)
                }
                
                // Text Elements Rendering Layer
                ForEach(localManager.elements.filter { element in
                    guard element.tool == .text else { return false }
                    let isCurrentScreen = element.screenID == screenID || element.screenID == nil
                    if isCurrentScreen { return true }
                    return isMirroringEnabled && element.screenID != nil
                }) { element in
                    if element.isEditing && !isCleanCapture && (element.screenID == screenID || element.screenID == nil) {
                        TextEditorWrapper(element: element, manager: localManager)
                    } else {
                        StaticTextView(element: element, manager: localManager, targetScreenID: screenID)
                    }
                }
                
                if !isCleanCapture {
                    SelectionOverlayView(manager: localManager, screenID: screenID).allowsHitTesting(localManager.selectedTool == .select)
                }
            }
            
            if !isCleanCapture && localManager.showCanvasFlash {
                CanvasFlashAlertView()
                    .transition(.opacity)
            }
            
            if !isCleanCapture {
                VStack(spacing: 8) {
                    if localManager.showGlobalToast {
                        GlobalToastView(message: localManager.globalToastMessage)
                            .padding(.top, 40)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if !localManager.isToolbarInTopHalf {
                        // Toolbar is at bottom → toast goes at top
                        if localManager.showShortcutToast {
                            ShortcutToastHUD(
                                iconName: localManager.shortcutToastIcon,
                                name: localManager.shortcutToastName,
                                keys: localManager.shortcutToastKeys
                            )
                            .padding(.top, localManager.showGlobalToast ? 0 : 40)
                            .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95)))
                        }
                        Spacer()
                    } else {
                        // Toolbar is at top → toast goes at bottom
                        Spacer()
                        if localManager.showShortcutToast {
                            ShortcutToastHUD(
                                iconName: localManager.shortcutToastIcon,
                                name: localManager.shortcutToastName,
                                keys: localManager.shortcutToastKeys
                            )
                            .padding(.bottom, 40)
                            .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)))
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            
            if !isCleanCapture && localManager.isCanvasModeEnabled && localManager.canvasColor != .none {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        PageControlView(manager: localManager)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                        
                        Spacer()
                        
                        if localManager.isMiniMapEnabled {
                            MiniMapView(manager: localManager, screen: screen) { element, ctx in
                                self.drawElement(element, in: &ctx)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    nonisolated private func mapPoints(of element: DrawingElement, using transform: CGAffineTransform) -> DrawingElement {
        var mapped = element
        mapped.points = element.points.map { pt in
            var mappedPt = pt
            mappedPt.location = pt.location.applying(transform)
            return mappedPt
        }
        return mapped
    }

    nonisolated private func drawElement(_ element: DrawingElement, in context: inout GraphicsContext) {
        guard !element.points.isEmpty else { return }
        if element.tool == .shape, let shapeType = element.shapeType {
            if element.points.count >= 2 {
                let p1 = element.points[0].location
                let p2 = element.points[1].location
                var path = Path()
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
                        path.move(to: p2); path.addLine(to: CGPoint(x: p2.x - arrowLength * cos(angle - arrowAngle), y: p2.y - arrowLength * sin(angle - arrowAngle)))
                        path.move(to: p2); path.addLine(to: CGPoint(x: p2.x - arrowLength * cos(angle + arrowAngle), y: p2.y - arrowLength * sin(angle + arrowAngle)))

                    }
                }
                context.stroke(path, with: .color(element.color.opacity(element.opacity)), style: strokeStyle(width: element.lineWidth))
            }
        } else {
            let pts = element.points
            if pts.count == 1 {
                let pt = pts[0], radius = pt.width / 2
                context.fill(Path(ellipseIn: CGRect(x: pt.location.x - radius, y: pt.location.y - radius, width: pt.width, height: pt.width)), with: .color(element.color.opacity(element.opacity)))
            } else if let cachedPath = element.cachedPath {
                context.stroke(cachedPath, with: .color(element.color.opacity(element.opacity)), style: strokeStyle(width: element.lineWidth))
            } else if let cachedSegments = element.cachedSegments {
                let originalOpacity = context.opacity
                context.opacity = element.opacity
                if element.opacity < 1.0 {
                    context.drawLayer { layerContext in
                        for segment in cachedSegments {
                             layerContext.stroke(segment.path, with: .color(element.color), style: strokeStyle(width: segment.width))
                        }
                    }
                } else {
                    for segment in cachedSegments {
                         context.stroke(segment.path, with: .color(element.color), style: strokeStyle(width: segment.width))
                    }
                }
                context.opacity = originalOpacity
            } else if pts.count > 1 {
                let originalOpacity = context.opacity
                context.opacity = element.opacity
                if element.opacity < 1.0 {
                    context.drawLayer { layerContext in
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
                            
                            layerContext.stroke(segmentPath, with: .color(element.color), style: strokeStyle(width: segmentWidth))
                        }
                    }
                } else {
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
                        
                        context.stroke(segmentPath, with: .color(element.color), style: strokeStyle(width: segmentWidth))
                    }
                }
                context.opacity = originalOpacity
            }
        }
    }
}

enum ShapeHUDTab: String, CaseIterable, Identifiable {
    case style = "paintpalette"
    case actions = "ellipsis.circle"
    
    var id: String { rawValue }
    var iconName: String { rawValue }
    var displayName: String {
        switch self {
        case .style: return "Style & Color"
        case .actions: return "Actions"
        }
    }
}

enum TextHUDTab: String, CaseIterable, Identifiable {
    case format = "textformat"
    case style = "paintpalette"
    case actions = "ellipsis.circle"
    
    var id: String { rawValue }
    var iconName: String { rawValue }
    var displayName: String {
        switch self {
        case .format: return "Typography"
        case .style: return "Color & Background"
        case .actions: return "Actions"
        }
    }
}

struct SelectionQuickActionHUD: View {
    @ObservedObject var manager: AppManager
    let elementId: UUID
    
    @State private var activeTab: ShapeHUDTab = .style
    @State private var showSlidersPopover = false
    
    private let presetColors: [Color] = [
        .black,
        .white,
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.19, green: 0.82, blue: 0.35),
        Color(red: 0.04, green: 0.52, blue: 1.0)
    ]
    
    var body: some View {
        if manager.elements.contains(where: { $0.id == elementId }) {
            HStack(spacing: 8) {
                // Tab switcher
                HStack(spacing: 4) {
                    ForEach(ShapeHUDTab.allCases) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.78)) {
                                activeTab = tab
                            }
                        }) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(activeTab == tab ? .primary : .secondary)
                                .frame(width: 22, height: 22)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(activeTab == tab ? 0.08 : 0.0))
                                )
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .focusEffectDisabled()
                        .noFocusRing()
                        .help(tab.displayName)
                    }
                }
                
                Color.primary.opacity(0.12)
                    .frame(width: 1, height: 16)
                
                // Active Tab Content
                HStack(spacing: 8) {
                    switch activeTab {
                    case .style:
                        HStack(spacing: 4) {
                            ForEach(presetColors, id: \.self) { color in
                                HUDColorCircle(
                                    color: color,
                                    isSelected: manager.selectedColorShared() == color
                                ) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        manager.recolorSelectedElement(to: color)
                                    }
                                }
                            }
                            HUDCustomColorButton(manager: manager, elementId: elementId)
                        }
                        
                        Color.primary.opacity(0.08)
                            .frame(width: 1, height: 16)
                        
                        HUDButton(
                            iconName: "slider.horizontal.3",
                            tooltip: "Brush Settings",
                            isSelected: showSlidersPopover
                        ) {
                            showSlidersPopover.toggle()
                        }
                        .popover(isPresented: $showSlidersPopover, arrowEdge: .top) {
                            SelectionSlidersPopoverView(manager: manager, elementId: elementId, isPresented: $showSlidersPopover)
                                .presentationBackground(.clear)
                        }
                        
                    case .actions:
                        HStack(spacing: 4) {
                            HUDButton(
                                iconName: "square.2.layers.3d.bottom.filled",
                                tooltip: "Send to Back"
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    manager.sendSelectedElementToBack()
                                }
                            }
                            
                            HUDButton(
                                iconName: "square.2.layers.3d.top.filled",
                                tooltip: "Bring to Front"
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    manager.bringSelectedElementToFront()
                                }
                            }
                        }
                        
                        Color.primary.opacity(0.08)
                            .frame(width: 1, height: 16)
                        
                        HStack(spacing: 4) {
                            HUDButton(
                                iconName: "plus.square.on.square",
                                tooltip: "Duplicate"
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    manager.duplicateSelectedElement()
                                }
                            }
                        }
                    }
                }
                .transition(.opacity)
                
                Color.primary.opacity(0.12)
                    .frame(width: 1, height: 16)
                
                HUDButton(
                    iconName: "trash",
                    tooltip: "Delete Selection",
                    isDestructive: true
                ) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        manager.deleteSelectedElement()
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule().stroke(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: activeTab)
        }
    }
}

// MARK: - Multi-Element Selection HUD

struct MultiSelectionHUD: View {
    @ObservedObject var manager: AppManager
    
    private let presetColors: [Color] = [
        .white,
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.19, green: 0.82, blue: 0.35),
        Color(red: 1.0, green: 0.62, blue: 0.04),
        Color(red: 0.04, green: 0.52, blue: 1.0),
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            // Count badge
            Text("\(manager.selectedElementIds.count) selected")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            Color.primary.opacity(0.12)
                .frame(width: 1, height: 16)
            
            // Recolor all swatches
            HStack(spacing: 4) {
                ForEach(presetColors, id: \.self) { color in
                    HUDColorCircle(color: color, isSelected: manager.selectedColorShared() == color) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            manager.recolorSelectedElement(to: color)
                        }
                    }
                }
            }
            
            Color.primary.opacity(0.12)
                .frame(width: 1, height: 16)
            
            // Layer order
            HStack(spacing: 4) {
                HUDButton(iconName: "square.2.layers.3d.bottom.filled", tooltip: "Send Group to Back") {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        manager.sendSelectedElementToBack()
                    }
                }
                HUDButton(iconName: "square.2.layers.3d.top.filled", tooltip: "Bring Group to Front") {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        manager.bringSelectedElementToFront()
                    }
                }
            }
            
            Color.primary.opacity(0.12)
                .frame(width: 1, height: 16)
            
            // Duplicate
            HUDButton(iconName: "plus.square.on.square", tooltip: "Duplicate All") {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    manager.duplicateSelectedElement()
                }
            }
            
            Color.primary.opacity(0.12)
                .frame(width: 1, height: 16)
            
            // Delete
            HUDButton(iconName: "trash", tooltip: "Delete All Selected", isDestructive: true) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    manager.deleteSelectedElement()
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .glassEffect(.regular, in: .capsule)
        .overlay(
            Capsule().stroke(
                LinearGradient(
                    colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
        )
    }
}

// MARK: - AppKit Focus Ring Suppressor
// Walks up the NSView hierarchy to find the NSButton SwiftUI created
// and sets focusRingType = .none, eliminating the flash when a Button
// inside a key window is clicked while a TextEditor holds firstResponder.
private class _FocusRingRemoverView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        removeFocusRingFromAncestors()
    }
    
    func removeFocusRingFromAncestors() {
        var v: NSView? = superview
        while let view = v {
            let className = String(describing: type(of: view))
            if className.contains("HostingView") {
                break
            }
            view.focusRingType = .none
            if let control = view as? NSControl {
                control.refusesFirstResponder = true
            }
            v = view.superview
        }
    }
}

private struct FocusRingRemover: NSViewRepresentable {
    func makeNSView(context: Context) -> _FocusRingRemoverView { _FocusRingRemoverView() }
    func updateNSView(_ nsView: _FocusRingRemoverView, context: Context) {
        nsView.removeFocusRingFromAncestors()
    }
}

extension View {
    /// Suppresses the AppKit focus ring on the underlying NSButton without
    /// removing it from the responder chain or affecting accessibility.
    func noFocusRing() -> some View {
        background(FocusRingRemover())
    }
}

// MARK: - HUD Component Helpers

struct HUDButton: View {
    let iconName: String
    let tooltip: String
    let isSelected: Bool
    let isDestructive: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    init(
        iconName: String,
        tooltip: String,
        isSelected: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.tooltip = tooltip
        self.isSelected = isSelected
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(isSelected ? Color.blue : (isHovering ? (isDestructive ? .red : .primary) : .secondary))
                .scaleEffect(isHovering ? 1.08 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusable(false)
        .focusEffectDisabled()
        .noFocusRing()
        .onHover { isHovering = $0 }
        .help(tooltip)
    }
}

struct HUDColorCircle: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1.0)
                )
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(Color.blue, lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                    }
                }
                .opacity(isSelected ? 1.0 : (isHovering ? 1.0 : 0.80))
                .scaleEffect(isHovering ? 1.15 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
        }
        .buttonStyle(.plain)
        .focusable(false)
        .focusEffectDisabled()
        .noFocusRing()
        .onHover { isHovering = $0 }
    }
}

struct HUDCustomColorButton: View {
    @ObservedObject var manager: AppManager
    let elementId: UUID
    @State private var showCustomColorPopover = false
    @State private var isHovering = false
    
    private let presetColors: [Color] = [
        .black,
        .white,
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.19, green: 0.82, blue: 0.35),
        Color(red: 0.04, green: 0.52, blue: 1.0)
    ]
    
    var isCustomSelected: Bool {
        if let shared = manager.selectedColorShared() {
            return !presetColors.contains(shared)
        }
        return false
    }
    
    var body: some View {
        Button(action: { showCustomColorPopover.toggle() }) {
            Capsule()
                .fill(manager.selectedColorShared() ?? manager.selectedColor)
                .frame(width: 24, height: 10)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.primary.opacity(0.25), lineWidth: 1.0)
                )
                .overlay {
                    if isCustomSelected {
                        Capsule()
                            .stroke(Color.blue, lineWidth: 1.5)
                            .frame(width: 28, height: 14)
                    }
                }
                .frame(width: 32, height: 18)
                .opacity(isCustomSelected ? 1.0 : (isHovering ? 1.0 : 0.80))
                .scaleEffect(isHovering ? 1.10 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isHovering)
        }
        .buttonStyle(.plain)
        .focusable(false)
        .focusEffectDisabled()
        .noFocusRing()
        .onHover { isHovering = $0 }
        .popover(isPresented: $showCustomColorPopover, arrowEdge: .top) {
            CustomColorPickerView(selectedColor: Binding<Color>(
                get: { manager.selectedColorShared() ?? manager.selectedColor },
                set: { newColor in
                    manager.selectedColor = newColor
                    manager.recolorSelectedElement(to: newColor)
                }
            ))
            .presentationBackground(.clear)
        }
        .help("Custom Color Picker")
    }
}

// MARK: - Selection Sliders Popover
struct SelectionSlidersPopoverView: View {
    @ObservedObject var manager: AppManager
    let elementId: UUID
    @Binding var isPresented: Bool
    
    var body: some View {
        if let element = manager.elements.first(where: { $0.id == elementId }) {
            let lineWidthBinding = Binding<Double>(
                get: { Double(element.lineWidth) },
                set: { manager.adjustSelectedElementLineWidth(to: CGFloat($0)) }
            )
            let opacityBinding = Binding<Double>(
                get: { Double(element.opacity) },
                set: { manager.adjustSelectedElementOpacity(to: CGFloat($0)) }
            )

            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Selection Settings")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Divider()
                    .opacity(0.5)
                
                // Dynamic Brush Preview Bubble
                BrushPreviewBubble(
                    size: element.lineWidth,
                    color: element.color,
                    opacity: element.opacity
                )
                
                Divider()
                    .opacity(0.5)
                
                // Stroke Size Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Size")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    HStack(spacing: 10) {
                        Slider(value: lineWidthBinding, in: 1.0...80.0, onEditingChanged: { isEditing in
                            if isEditing {
                                manager.recordState()
                            }
                        })
                        .tint(element.color)
                        .frame(width: 130)
                        
                        Text("\(Int(element.lineWidth)) pt")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                    
                    // Quick brush size presets
                    HStack(spacing: 6) {
                        ForEach([("Fine", 3.0), ("Medium", 8.0), ("Thick", 20.0)], id: \.0) { name, size in
                            Button(action: {
                                manager.recordState()
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                                    manager.adjustSelectedElementLineWidth(to: CGFloat(size))
                                }
                            }) {
                                Text(name)
                                    .font(.system(size: 9, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Int(element.lineWidth) == Int(size) ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Int(element.lineWidth) == Int(size) ? Color.primary.opacity(0.15) : Color.clear, lineWidth: 1)
                                    )
                                    .foregroundColor(Int(element.lineWidth) == Int(size) ? .primary : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                    .opacity(0.5)
                
                // Opacity Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Opacity")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.5)
                    
                    HStack(spacing: 10) {
                        Slider(value: opacityBinding, in: 0.05...1.0, onEditingChanged: { isEditing in
                            if isEditing {
                                manager.recordState()
                            }
                        })
                        .tint(element.color)
                        .frame(width: 130)
                        
                        Text("\(Int(round(element.opacity * 100)))%")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
                

            }
            .padding(16)
            .frame(width: 220)
            .glassEffect(.regular, in: ConcentricRectangle())
            .overlay(
                ConcentricRectangle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
        }
    }
}

struct HandleInfo: Identifiable {
    let id: String
    let point: CGPoint
    let anchor: CGPoint
    let axis: ScaleAxis
}

struct SelectionOverlayView: View {
    @ObservedObject var manager: AppManager
    let screenID: String
    
    @Environment(\.colorScheme) var colorScheme
    
    // Handle size and hit area
    private let handleSize: CGFloat = 8
    private let handleHit: CGFloat = 18
    
    private var isDarkBackground: Bool {
        if manager.canvasColor != .none {
            return manager.canvasColor.isDark
        } else {
            let systemDark = NSApp.effectiveAppearance.name.rawValue.lowercased().contains("dark")
            return colorScheme == .dark || systemDark
        }
    }
    
    struct SelectionInfo {
        let isMulti: Bool
        let angle: Double
        let box: CGRect
        let center: CGPoint
        let isMirroredScreen: Bool
        let rTL: CGPoint
        let rTR: CGPoint
        let rBL: CGPoint
        let rBR: CGPoint
        let rotTC: CGPoint
        let rotHandlePos: CGPoint
        let isTextSelected: Bool
        let singleElementId: UUID?
        let mBox: CGRect
        let mCenter: CGPoint
        let mCornerRadius: CGFloat
    }
    
    private func getSelectionInfo() -> SelectionInfo? {
        guard !manager.selectedElementIds.isEmpty else { return nil }
        
        let isMulti = manager.selectedElementIds.count > 1
        
        let angle: Double = {
            if isMulti {
                return manager.activeRotationAngle
            } else if let firstId = manager.selectedElementIds.first,
                      let element = manager.elements.first(where: { $0.id == firstId }) {
                return element.rotationAngle
            }
            return 0.0
        }()
        
        let box: CGRect = {
            if isMulti {
                if manager.activeRotationAngle != 0.0 {
                    if let firstId = manager.selectedElementIds.first,
                       let element = manager.elements.first(where: { $0.id == firstId }),
                       let elementScreenID = element.screenID,
                       elementScreenID != screenID {
                        if let srcSize = manager.size(from: elementScreenID),
                           let destSize = manager.size(from: screenID) {
                            let transform = manager.getTransform(from: srcSize, to: destSize, mode: manager.mirroringScaleMode)
                            return manager.originalSelectionBounds.applying(transform)
                        }
                    }
                    return manager.originalSelectionBounds
                } else {
                    return manager.selectionBoundingBox(projectedTo: screenID)
                }
            } else if let firstId = manager.selectedElementIds.first,
                      let element = manager.elements.first(where: { $0.id == firstId }) {
                return manager.boundingBox(of: element, mappedTo: screenID)
            }
            return .zero
        }()
        
        let center: CGPoint = {
            if isMulti {
                if manager.activeRotationAngle != 0.0 {
                    if let firstId = manager.selectedElementIds.first,
                       let element = manager.elements.first(where: { $0.id == firstId }),
                       let elementScreenID = element.screenID,
                       elementScreenID != screenID {
                        if let srcSize = manager.size(from: elementScreenID),
                           let destSize = manager.size(from: screenID) {
                            let transform = manager.getTransform(from: srcSize, to: destSize, mode: manager.mirroringScaleMode)
                            return manager.originalSelectionCenter.applying(transform)
                        }
                    }
                    return manager.originalSelectionCenter
                } else {
                    let b = manager.selectionBoundingBox(projectedTo: screenID)
                    return CGPoint(x: b.midX, y: b.midY)
                }
            } else if let firstId = manager.selectedElementIds.first,
                      let element = manager.elements.first(where: { $0.id == firstId }) {
                let nativeCenter = manager.elementCenter(element)
                if let elementScreenID = element.screenID, elementScreenID != screenID {
                    if let srcSize = manager.size(from: elementScreenID),
                       let destSize = manager.size(from: screenID) {
                        let transform = manager.getTransform(from: srcSize, to: destSize, mode: manager.mirroringScaleMode)
                        return nativeCenter.applying(transform)
                    }
                }
                return nativeCenter
            }
            return .zero
        }()
        
        let isMirroredScreen: Bool = {
            if let firstId = manager.selectedElementIds.first,
               let element = manager.elements.first(where: { $0.id == firstId }) {
                return element.screenID != screenID
            }
            return false
        }()
        
        let isTextSelected: Bool = {
            if !isMulti,
               let firstId = manager.selectedElementIds.first,
               let element = manager.elements.first(where: { $0.id == firstId }) {
                return element.tool == .text
            }
            return false
        }()
        
        let screenBox: CGRect = {
            if manager.isCanvasModeEnabled && manager.canvasColor != .none {
                return CGRect(
                    x: box.origin.x * manager.zoomScale + manager.panOffset.x,
                    y: box.origin.y * manager.zoomScale + manager.panOffset.y,
                    width: box.width * manager.zoomScale,
                    height: box.height * manager.zoomScale
                )
            }
            return box
        }()
        
        let screenCenter = manager.isCanvasModeEnabled && manager.canvasColor != .none ? manager.toScreenSpace(center) : center
        
        let rawCorners = corners(of: screenBox, center: screenCenter, angle: angle)
        let tl = rawCorners[0].point
        let tr = rawCorners[1].point
        let bl = rawCorners[2].point
        let br = rawCorners[3].point
        
        let tc = CGPoint(x: screenBox.midX, y: screenBox.minY)
        let rotTC = manager.rotatePoint(tc, around: screenCenter, by: angle)
        let rot = CGPoint(x: screenBox.midX, y: screenBox.minY - 24)
        let rotHandlePos = manager.rotatePoint(rot, around: screenCenter, by: angle)
        
        let singleElementId: UUID? = {
            if !isMulti {
                return manager.selectedElementIds.first
            }
            return nil
        }()
        
        let singleElement: DrawingElement? = {
            if !isMulti,
               let firstId = manager.selectedElementIds.first {
                return manager.elements.first(where: { $0.id == firstId })
            }
            return nil
        }()
        
        let mBox = screenBox
        let mCenter = screenCenter
        var mCornerRadius: CGFloat = (singleElement?.cornerRadius ?? 0) * (manager.isCanvasModeEnabled && manager.canvasColor != .none ? manager.zoomScale : 1.0)
        
        if isMirroredScreen,
           let element = singleElement,
           let elementScreenID = element.screenID {
            if let srcSize = manager.size(from: elementScreenID),
               let destSize = manager.size(from: screenID) {
                let transform = manager.getTransform(from: srcSize, to: destSize, mode: manager.mirroringScaleMode)
                mCornerRadius = (singleElement?.cornerRadius ?? 0) * transform.a * (manager.isCanvasModeEnabled && manager.canvasColor != .none ? manager.zoomScale : 1.0)
            }
        }
        
        return SelectionInfo(
            isMulti: isMulti,
            angle: angle,
            box: screenBox,
            center: screenCenter,
            isMirroredScreen: isMirroredScreen,
            rTL: tl,
            rTR: tr,
            rBL: bl,
            rBR: br,
            rotTC: rotTC,
            rotHandlePos: rotHandlePos,
            isTextSelected: isTextSelected,
            singleElementId: singleElementId,
            mBox: mBox,
            mCenter: mCenter,
            mCornerRadius: mCornerRadius
        )
    }
    
    var body: some View {
        Group {
            if let info = getSelectionInfo() {
                ZStack {
                    let selectionBounds = manager.selectionBoundingBox(projectedTo: screenID)
                    Color.clear
                        .frame(width: selectionBounds.width, height: selectionBounds.height)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        manager.updateSelectionWindowFrame(geo.frame(in: .global), screenID: screenID)
                                    }
                                    .onChange(of: geo.frame(in: .global)) { _, newFrame in
                                        manager.updateSelectionWindowFrame(newFrame, screenID: screenID)
                                    }
                            }
                        )
                        .position(CGPoint(x: selectionBounds.midX, y: selectionBounds.midY))
                    
                    let selectionColor: Color = {
                        if manager.selectedElementIds.count == 1,
                           let firstId = manager.selectedElementIds.first,
                           let element = manager.elements.first(where: { $0.id == firstId }) {
                            return element.color
                        }
                        // For multi-element selection use neutral white (no blue)
                        return Color.white.opacity(0.85)
                    }()
                    
                    let isSingleSquare = !info.isMulti && info.singleElementId != nil && {
                        if let singleId = info.singleElementId,
                           let element = manager.elements.first(where: { $0.id == singleId }),
                           element.tool == .shape,
                           element.shapeType == .square {
                            return true
                        }
                        return false
                    }()
                    
                    // Rotated dashed bounding box border
                    if isSingleSquare {
                        RoundedRectangle(cornerRadius: info.mCornerRadius)
                            .stroke(selectionColor, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .frame(width: info.mBox.width, height: info.mBox.height)
                            .rotationEffect(.radians(info.angle))
                            .position(info.mCenter)
                    } else {
                        Path { path in
                            path.move(to: info.rTL)
                            path.addLine(to: info.rTR)
                            path.addLine(to: info.rBR)
                            path.addLine(to: info.rBL)
                            path.closeSubpath()
                        }
                        .stroke(selectionColor, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    }
                    
                    if !info.isMirroredScreen {
                        if !info.isTextSelected {
                            // Rotation stem
                            Path { path in
                                path.move(to: info.rotTC)
                                path.addLine(to: info.rotHandlePos)
                            }
                            .stroke(selectionColor.opacity(0.7), style: StrokeStyle(lineWidth: 1.5))
                        }
                        
                        // Corner & Edge resize handles (Visible as static dots for text, interactive for others)
                        ForEach(handles(of: info.box, center: info.center, angle: info.angle, isMirroredScreen: info.isMirroredScreen, screenID: screenID)) { handle in
                            ResizeHandle(
                                position: handle.point,
                                anchor: handle.anchor,
                                axis: handle.axis,
                                manager: manager,
                                handleSize: handleSize,
                                handleHit: handleHit,
                                isDisabled: info.isTextSelected,
                                screenID: screenID
                            )
                        }
                        
                        if !info.isTextSelected {
                            // Rotation handle
                            RotationHandle(
                                position: info.rotHandlePos,
                                center: info.center,
                                currentAngle: info.angle,
                                manager: manager
                            )
                        }
                        
                        // Orange Corner Radius Handle (only if single square shape is selected)
                        if isSingleSquare,
                           let singleId = info.singleElementId {
                            let radiusHandlePos = manager.rotatePoint(
                                CGPoint(x: info.mBox.minX + info.mCornerRadius + 12, y: info.mBox.minY + info.mCornerRadius + 12),
                                around: info.mCenter,
                                by: info.angle
                            )
                            
                            CornerRadiusHandle(
                                position: radiusHandlePos,
                                center: info.mCenter,
                                angle: info.angle,
                                box: info.mBox,
                                manager: manager,
                                elementId: singleId
                            )
                        }
                    }
                    
                    // Live tooltip metric overlay during active transformation
                    if manager.activeTransformType != .none {
                        let tooltipPos: CGPoint = {
                            let rawPos = CGPoint(x: info.mBox.midX, y: info.mBox.maxY + 25)
                            return manager.rotatePoint(rawPos, around: info.mCenter, by: info.angle)
                        }()
                        
                        let text: String = {
                            switch manager.activeTransformType {
                            case .moving, .scaling:
                                return "\(Int(round(info.mBox.width))) × \(Int(round(info.mBox.height))) pt"
                            case .rotating:
                                let degrees = Int(round(info.angle * 180 / .pi)) % 360
                                let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
                                return "\(normalizedDegrees)°"
                            case .adjustingCornerRadius:
                                return "Radius: \(Int(round(info.mCornerRadius))) pt"
                            case .none:
                                return ""
                            }
                        }()
                        
                        if !text.isEmpty {
                            Text(text)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .glassEffect(.regular, in: .capsule)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                                                startPoint: .top, endPoint: .bottom
                                            ),
                                            lineWidth: 0.8
                                        )
                                )
                                .position(tooltipPos)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.96)),
                    removal: .opacity.combined(with: .scale(scale: 0.96))
                ))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: manager.selectedElementIds)
        .preferredColorScheme(isDarkBackground ? .dark : .light)
    }
    
    struct CornerInfo: Identifiable {
        let id: String
        let point: CGPoint
        let anchor: CGPoint  // opposite corner — fixed during resize
    }
    
    private func corners(of box: CGRect, center: CGPoint, angle: Double) -> [CornerInfo] {
        let tl = CGPoint(x: box.minX, y: box.minY)
        let tr = CGPoint(x: box.maxX, y: box.minY)
        let bl = CGPoint(x: box.minX, y: box.maxY)
        let br = CGPoint(x: box.maxX, y: box.maxY)
        
        let rTL = manager.rotatePoint(tl, around: center, by: angle)
        let rTR = manager.rotatePoint(tr, around: center, by: angle)
        let rBL = manager.rotatePoint(bl, around: center, by: angle)
        let rBR = manager.rotatePoint(br, around: center, by: angle)
        
        return [
            CornerInfo(id: "tl", point: rTL, anchor: rBR),
            CornerInfo(id: "tr", point: rTR, anchor: rBL),
            CornerInfo(id: "bl", point: rBL, anchor: rTR),
            CornerInfo(id: "br", point: rBR, anchor: rTL),
        ]
    }
    
    private func handles(of box: CGRect, center: CGPoint, angle: Double, isMirroredScreen: Bool, screenID: String) -> [HandleInfo] {
        let tl = CGPoint(x: box.minX, y: box.minY)
        let tr = CGPoint(x: box.maxX, y: box.minY)
        let bl = CGPoint(x: box.minX, y: box.maxY)
        let br = CGPoint(x: box.maxX, y: box.maxY)
        
        let tm = CGPoint(x: box.midX, y: box.minY)
        let bm = CGPoint(x: box.midX, y: box.maxY)
        let lm = CGPoint(x: box.minX, y: box.midY)
        let rm = CGPoint(x: box.maxX, y: box.midY)
        
        let rTL = manager.rotatePoint(tl, around: center, by: angle)
        let rTR = manager.rotatePoint(tr, around: center, by: angle)
        let rBL = manager.rotatePoint(bl, around: center, by: angle)
        let rBR = manager.rotatePoint(br, around: center, by: angle)
        
        let rTM = manager.rotatePoint(tm, around: center, by: angle)
        let rBM = manager.rotatePoint(bm, around: center, by: angle)
        let rLM = manager.rotatePoint(lm, around: center, by: angle)
        let rRM = manager.rotatePoint(rm, around: center, by: angle)
        
        return [
            HandleInfo(id: "tl", point: rTL, anchor: rBR, axis: .both),
            HandleInfo(id: "tr", point: rTR, anchor: rBL, axis: .both),
            HandleInfo(id: "bl", point: rBL, anchor: rTR, axis: .both),
            HandleInfo(id: "br", point: rBR, anchor: rTL, axis: .both),
            HandleInfo(id: "tm", point: rTM, anchor: rBM, axis: .vertical),
            HandleInfo(id: "bm", point: rBM, anchor: rTM, axis: .vertical),
            HandleInfo(id: "lm", point: rLM, anchor: rRM, axis: .horizontal),
            HandleInfo(id: "rm", point: rRM, anchor: rLM, axis: .horizontal),
        ]
    }
}

// MARK: - Rotation Handle
struct RotationHandle: View {
    let position: CGPoint
    let center: CGPoint
    let currentAngle: Double
    @ObservedObject var manager: AppManager
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isDragging = false
    @State private var dragAngle: Double = 0.0
    @State private var startHandlePos: CGPoint = .zero
    @State private var isHovering = false
    @State private var iconRotation: Double = 0.0
    
    private var isDarkBackground: Bool {
        if manager.canvasColor != .none {
            return manager.canvasColor.isDark
        } else {
            let systemDark = NSApp.effectiveAppearance.name.rawValue.lowercased().contains("dark")
            return colorScheme == .dark || systemDark
        }
    }
    
    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(isHovering || isDragging ? .primary : .secondary)
            .rotationEffect(.degrees(iconRotation))
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                        iconRotation += 360
                    }
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isHovering)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isDragging)
            .contentShape(Capsule())
            .position(position)
            .onDisappear {
                if isHovering {
                    NSCursor.pop()
                }
                if isDragging {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        if !isDragging {
                            manager.recordState()
                            manager.startSelectionTransform()
                            isDragging = true
                            manager.activeTransformType = .rotating
                            dragAngle = currentAngle
                            startHandlePos = position
                            NSCursor.closedHand.push()
                        }
                        let currentDragPos = CGPoint(
                            x: startHandlePos.x + value.translation.width,
                            y: startHandlePos.y + value.translation.height
                        )
                        let dx = currentDragPos.x - center.x
                        let dy = currentDragPos.y - center.y
                        let angle = atan2(dy, dx) + CGFloat.pi / 2
                        
                        let snapInterval = Double.pi / 4
                        let nearestSnap = round(angle / snapInterval) * snapInterval
                        let isCloseToSnap = abs(angle - nearestSnap) < (5.0 * Double.pi / 180.0)
                        let finalAngle = isCloseToSnap ? nearestSnap : angle
                        
                        dragAngle = finalAngle
                        manager.rotateSelectedElements(to: finalAngle)
                    }
                    .onEnded { _ in
                        isDragging = false
                        manager.activeRotationAngle = 0.0
                        manager.activeTransformType = .none
                        NSCursor.pop()
                    }
            )
            .help("Rotate Selection")
    }
}

// MARK: - Resize Handle
struct ResizeHandle: View {
    let position: CGPoint
    let anchor: CGPoint
    let axis: ScaleAxis
    @ObservedObject var manager: AppManager
    let handleSize: CGFloat
    let handleHit: CGFloat
    var isDisabled: Bool = false
    let screenID: String
    
    @State private var dragStart: CGPoint? = nil
    @State private var startHandlePos: CGPoint? = nil
    @State private var startAnchor: CGPoint? = nil
    
    var body: some View {
        let baseCircle = Circle()
            .fill(Color.white)
            .overlay(Circle().stroke(Color.blue.opacity(0.8), lineWidth: 1.5))
            .frame(width: handleSize, height: handleSize)
            .position(position)
            
        if isDisabled {
            baseCircle
        } else {
            baseCircle
                .contentShape(Circle().size(CGSize(width: handleHit, height: handleHit))
                    .offset(x: position.x - handleHit/2, y: position.y - handleHit/2))
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            if dragStart == nil {
                                manager.recordState()
                                manager.startSelectionTransform()
                                manager.activeTransformType = .scaling
                                dragStart = value.startLocation
                                startHandlePos = position
                                startAnchor = anchor
                            }
                            guard let start = startHandlePos, let currentAnchor = startAnchor else { return }
                            let newHandle = CGPoint(
                                x: start.x + value.translation.width,
                                y: start.y + value.translation.height
                            )
                            let lockAspect = NSEvent.modifierFlags.contains(.shift)
                            manager.scaleSelectedElements(anchor: currentAnchor, newHandle: newHandle, lockAspectRatio: lockAspect, axis: axis, gestureScreenID: screenID)
                        }
                        .onEnded { _ in
                            dragStart = nil
                            startHandlePos = nil
                            startAnchor = nil
                            manager.activeTransformType = .none
                        }
                )
        }
    }
}

struct CornerRadiusHandle: View {
    let position: CGPoint
    let center: CGPoint
    let angle: Double
    let box: CGRect
    @ObservedObject var manager: AppManager
    let elementId: UUID
    
    @State private var dragStart: CGPoint? = nil
    @State private var startRadius: CGFloat = 0
    @State private var startHandlePos: CGPoint = .zero
    
    var body: some View {
        let size: CGFloat = 10
        Circle()
            .fill(Color.orange)
            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            .frame(width: size, height: size)
            .position(position)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        guard let elementIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                        let element = manager.elements[elementIdx]
                        
                        if dragStart == nil {
                            manager.recordState()
                            manager.startSelectionTransform()
                            manager.activeTransformType = .adjustingCornerRadius
                            dragStart = value.startLocation
                            startRadius = element.cornerRadius
                            startHandlePos = position
                        }
                        
                        let currentDragScreen = CGPoint(
                            x: startHandlePos.x + value.translation.width,
                            y: startHandlePos.y + value.translation.height
                        )
                        let unrotatedDrag = manager.rotatePoint(currentDragScreen, around: center, by: -angle)
                        
                        let dx = unrotatedDrag.x - box.minX - 12
                        let dy = unrotatedDrag.y - box.minY - 12
                        let calculatedRadius = (dx + dy) / 2
                        let maxRadius = min(box.width, box.height) / 2
                        let newRadius = max(0, min(maxRadius, calculatedRadius))
                        
                        if manager.isCanvasModeEnabled && manager.canvasColor != .none {
                            manager.elements[elementIdx].cornerRadius = newRadius / manager.zoomScale
                        } else {
                            manager.elements[elementIdx].cornerRadius = newRadius
                        }
                        manager.updateCachedFields(idx: elementIdx)
                    }
                    .onEnded { _ in
                        dragStart = nil
                        manager.activeTransformType = .none
                    }
            )
            .help("Adjust Corner Radius")
    }
}



struct AppMenuView: View {
    @ObservedObject var manager: AppManager
    var body: some View {
        Button("Clear Screen") { manager.clearAll() }.keyboardShortcut("-", modifiers: [.option])
        
        Divider()
        
        Group {
            Button("Undo") { manager.undo() }.keyboardShortcut("8", modifiers: [.option])
            Button("Redo") { manager.redo() }.keyboardShortcut("9", modifiers: [.option])
        }
        
        Divider()
        
        Menu("Select Tool") {
            Button("Cursor") { manager.selectedTool = .cursor }.keyboardShortcut("1", modifiers: [.option])
            Button("Pencil") { manager.selectedTool = .pencil }.keyboardShortcut("2", modifiers: [.option])
            Button("Highlighter") { manager.selectedTool = .highlighter }.keyboardShortcut("3", modifiers: [.option])
            Button("Text") { manager.selectedTool = .text }.keyboardShortcut("4", modifiers: [.option])
            Button("Select") { manager.selectedTool = .select }.keyboardShortcut("5", modifiers: [.option])
            Button("Laser Pointer") { manager.selectedTool = .laser }.keyboardShortcut("6", modifiers: [.option])
            Button("Eraser") { manager.selectedTool = .eraser }.keyboardShortcut("7", modifiers: [.option])
        }
        
        Menu("Select Shape") {
            Button("Square") { manager.selectedShape = .square; manager.selectedTool = .shape }.keyboardShortcut("1", modifiers: [.command, .option])
            Button("Circle") { manager.selectedShape = .circle; manager.selectedTool = .shape }.keyboardShortcut("2", modifiers: [.command, .option])
            Button("Triangle") { manager.selectedShape = .triangle; manager.selectedTool = .shape }.keyboardShortcut("3", modifiers: [.command, .option])
            Button("Line") { manager.selectedShape = .line; manager.selectedTool = .shape }.keyboardShortcut("4", modifiers: [.command, .option])
            Button("Arrow") { manager.selectedShape = .arrow; manager.selectedTool = .shape }.keyboardShortcut("5", modifiers: [.command, .option])
        }
        
        Divider()
        
        Button(manager.isToolbarVisible ? "Hide Toolbar" : "Show Toolbar") {
            manager.isToolbarVisible.toggle()
        }
        .keyboardShortcut("q", modifiers: [.option])
        
        Divider()
        
        Menu("Canvas Mirroring") {
            Toggle("Mirror to All Screens", isOn: Binding<Bool>(
                get: { manager.isMirroringEnabled },
                set: { val in
                    manager.isMirroringEnabled = val
                }
            ))
            
            Divider()
            
            ForEach(MirroringScaleMode.allCases) { mode in
                Toggle(mode.displayName, isOn: Binding<Bool>(
                    get: { manager.mirroringScaleMode == mode },
                    set: { val in
                        if val {
                            manager.mirroringScaleMode = mode
                        }
                    }
                ))
                .disabled(!manager.isMirroringEnabled)
            }
        }
        
        Divider()
        Button("Keyboard Shortcuts…") { manager.showShortcutsHelp() }
        Divider()
        Button("Quit Gaze") { NSApplication.shared.terminate(nil) }.keyboardShortcut("Q", modifiers: [.command])
    }
}

struct GlassEffectContainer<Content: View>: View {
    var content: () -> Content
    var body: some View { content().padding(4) }
}

struct ConcentricRectangle: Shape {
    func path(in rect: CGRect) -> Path { RoundedRectangle(cornerRadius: 12).path(in: rect) }
}

extension View {
    func glassEffect<S: Shape>(_ material: NSVisualEffectView.Material, in shape: S) -> some View {
        self.background(VisualEffectView(material: material, blendingMode: .withinWindow, cornerRadius: 12)).clipShape(shape)
    }
}

struct PatternOverlayView: View {
    let color: CanvasColor
    let pattern: CanvasPattern
    let step: CGFloat
    let lineWidth: CGFloat
    let dotSize: CGFloat
    
    var isCanvasModeEnabled: Bool = false
    var zoomScale: CGFloat = 1.0
    var panOffset: CGPoint = .zero
    
    var body: some View {
        Canvas { context, size in
            let isDark = color.isDark
            let pColor: Color
            if color == .blueprint {
                pColor = Color(red: 0.3, green: 0.6, blue: 1).opacity(0.68)
            } else if isDark {
                pColor = Color.white.opacity(0.40)
            } else {
                pColor = Color.black.opacity(0.30)
            }
            
            let active = isCanvasModeEnabled && color != .none
            let zoom = active ? zoomScale : 1.0
            let pan = active ? panOffset : .zero
            
            var localContext = context
            if active {
                localContext.translateBy(x: pan.x, y: pan.y)
                localContext.scaleBy(x: zoom, y: zoom)
            }
            
            let minX = active ? (0 - pan.x) / zoom : 0
            let maxX = active ? (size.width - pan.x) / zoom : size.width
            let minY = active ? (0 - pan.y) / zoom : 0
            let maxY = active ? (size.height - pan.y) / zoom : size.height
            
            let drawLineWidth = active ? (lineWidth / zoom) : lineWidth
            let drawDotSize = active ? (dotSize / zoom) : dotSize
            
            switch pattern {
            case .none: break
            case .grid:
                let startX = floor(minX / step) * step
                let endX = ceil(maxX / step) * step
                for x in stride(from: startX, through: endX, by: step) {
                    var p = Path()
                    p.move(to: CGPoint(x: x, y: minY))
                    p.addLine(to: CGPoint(x: x, y: maxY))
                    localContext.stroke(p, with: .color(pColor), lineWidth: drawLineWidth)
                }
                let startY = floor(minY / step) * step
                let endY = ceil(maxY / step) * step
                for y in stride(from: startY, through: endY, by: step) {
                    var p = Path()
                    p.move(to: CGPoint(x: minX, y: y))
                    p.addLine(to: CGPoint(x: maxX, y: y))
                    localContext.stroke(p, with: .color(pColor), lineWidth: drawLineWidth)
                }
            case .dot:
                let startX = floor((minX - step / 2) / step) * step + step / 2
                let endX = ceil((maxX - step / 2) / step) * step + step / 2
                let startY = floor((minY - step / 2) / step) * step + step / 2
                let endY = ceil((maxY - step / 2) / step) * step + step / 2
                for x in stride(from: startX, through: endX, by: step) {
                    for y in stride(from: startY, through: endY, by: step) {
                        localContext.fill(Path(ellipseIn: CGRect(x: x - drawDotSize / 2, y: y - drawDotSize / 2, width: drawDotSize, height: drawDotSize)), with: .color(pColor))
                    }
                }
            case .ruled:
                let startY = floor((minY - step / 2) / step) * step + step / 2
                let endY = ceil((maxY - step / 2) / step) * step + step / 2
                for y in stride(from: startY, through: endY, by: step) {
                    var p = Path()
                    p.move(to: CGPoint(x: minX, y: y))
                    p.addLine(to: CGPoint(x: maxX, y: y))
                    localContext.stroke(p, with: .color(pColor), lineWidth: drawLineWidth)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct CanvasBackgroundView: View {
    @ObservedObject var manager: AppManager
    let color: CanvasColor
    let pattern: CanvasPattern
    var body: some View {
        ZStack {
            backgroundColor
            if pattern != .none && color != .none {
                PatternOverlayView(
                    color: color,
                    pattern: pattern,
                    step: 28.0,
                    lineWidth: 0.75,
                    dotSize: 2.2,
                    isCanvasModeEnabled: manager.isCanvasModeEnabled,
                    zoomScale: manager.zoomScale,
                    panOffset: manager.panOffset
                )
            }
        }
    }
    private var backgroundColor: Color {
        // .none uses a nearly-invisible color so the canvas still receives hit-testing,
        // while all other cases use the canonical CanvasColor.color mapping.
        color == .none ? Color.black.opacity(0.001) : color.color
    }
}

// MARK: - Checkerboard Pattern View
struct CheckerboardPatternView: View {
    var body: some View {
        Canvas { context, size in
            let squareSize: CGFloat = 6
            let rows = Int(size.height / squareSize) + 1
            let cols = Int(size.width / squareSize) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    if (row + col) % 2 == 0 {
                        context.fill(
                            Path(CGRect(x: CGFloat(col) * squareSize, y: CGFloat(row) * squareSize, width: squareSize, height: squareSize)),
                            with: .color(Color.primary.opacity(0.08))
                        )
                    }
                }
            }
        }
        .background(Color.clear)
    }
}

// MARK: - Dynamic Brush Preview Bubble
struct LineSegment: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct BrushPreviewBubble: View {
    let size: CGFloat
    let color: Color
    let opacity: CGFloat
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                // Checkerboard background
                CheckerboardPatternView()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.12), lineWidth: 1.0))
                
                // Actual brush preview
                Circle()
                    .fill(color)
                    .opacity(opacity)
                    .frame(width: min(56.0, max(2.0, size)), height: min(56.0, max(2.0, size)))
                    .animation(.spring(response: 0.22, dampingFraction: 0.75), value: size)
                    .animation(.spring(response: 0.22, dampingFraction: 0.75), value: opacity)
            }
            .frame(width: 60, height: 60)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1.5)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Floating Selection HUD Components

class SelectionHUDPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Gaze Selection HUD"
        self.isFloatingPanel = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 2)
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.sharingType = .readOnly
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}

struct SelectionHUDWindowView: View {
    @ObservedObject var manager: AppManager
    
    var body: some View {
        Group {
            let count = manager.selectedElementIds.count
            if count > 1 {
                // Multi-element HUD
                MultiSelectionHUD(manager: manager)
            } else if let firstId = manager.selectedElementIds.first {
                if let element = manager.elements.first(where: { $0.id == firstId }), element.tool == .text {
                    TextSelectionHUD(manager: manager, elementId: firstId)
                } else {
                    SelectionQuickActionHUD(manager: manager, elementId: firstId)
                }
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HUDSizePreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(HUDSizePreferenceKey.self) { newSize in
            guard newSize != .zero else { return }
            DispatchQueue.main.async {
                manager.selectionHUDSize = newSize
                manager.positionSelectionHUD()
            }
        }
    }
}

struct HUDSizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Floating Timer HUD Components

class FloatingTimerHUDPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Gaze Timer HUD"
        self.isFloatingPanel = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 2)
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = true
        self.sharingType = .readOnly
        self.animationBehavior = .utilityWindow
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}


struct FloatingTimerHUDView: View {
    @ObservedObject var manager: AppManager
    @State private var isHoverPlay = false
    @State private var isHoverReset = false
    @State private var isHoverAttach = false
    
    var body: some View {
        let isFinished = manager.isTimerFinished
        let isStopwatch = manager.isStopwatchMode
        let isRunning = manager.isTimerRunning
        
        let ringColor: Color = {
            if isFinished {
                return Color(red: 1.0, green: 0.27, blue: 0.23)
            } else if isStopwatch {
                return Color(red: 0.20, green: 0.78, blue: 0.35)
            } else {
                return Color.blue
            }
        }()
        
        HStack(spacing: 10) {
            // Close / Attach HUD button
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    manager.isTimerDetached = false
                }
            }) {
                Image(systemName: "pip.exit")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isHoverAttach ? .primary : .secondary)
                    .scaleEffect(isHoverAttach ? 1.10 : 1.0)
                    .frame(width: 22, height: 22)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(isHoverAttach ? 0.08 : 0.03)))
            }
            .buttonStyle(.plain)
            .focusable(false)
            .focusEffectDisabled()
            .noFocusRing()
            .onHover { isHoverAttach = $0 }
            .help("Attach Timer to Toolbar")
            
            // Readout & Subtext
            VStack(alignment: .leading, spacing: 0) {
                Text(timeString(from: manager.timerTimeLeft))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .lineLimit(1)
                    .foregroundColor(isFinished ? Color(red: 1.0, green: 0.27, blue: 0.23) : .primary)
                
                Text(isFinished ? "FINISHED" : (isStopwatch ? "STOPWATCH" : (isRunning ? "RUNNING" : "PAUSED")))
                    .font(.system(size: 7, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(isFinished ? Color(red: 1.0, green: 0.27, blue: 0.23) : .secondary)
                    .kerning(0.5)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                // Play/Pause button
                Button(action: {
                    if isFinished {
                        manager.resetTimer()
                        manager.startTimer()
                    } else if isRunning {
                        manager.pauseTimer()
                    } else {
                        manager.startTimer()
                    }
                }) {
                    Image(systemName: isFinished ? "arrow.clockwise" : (isRunning ? "pause.fill" : "play.fill"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ringColor)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(ringColor.opacity(isHoverPlay ? 0.15 : 0.06)))
                        .scaleEffect(isHoverPlay ? 1.10 : 1.0)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .focusEffectDisabled()
                .noFocusRing()
                .onHover { isHoverPlay = $0 }
                .help(isFinished ? "Replay Timer" : (isRunning ? "Pause Timer" : "Start Timer"))
                
                // Reset/Replay button
                Button(action: {
                    manager.resetTimer()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.primary.opacity(isHoverReset ? 0.08 : 0.03)))
                        .scaleEffect(isHoverReset ? 1.10 : 1.0)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .focusEffectDisabled()
                .noFocusRing()
                .onHover { isHoverReset = $0 }
                .help("Reset Timer")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(width: 210, height: 42) // Fixed dimensions for the HUD container box
        .glassEffect(.regular, in: .capsule)
        .overlay(
            Capsule().stroke(
                LinearGradient(
                    colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
        .padding(12) // Outer transparent padding allowing shadow to render fully
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Text Rendering Components

struct StaticTextView: View {
    let element: DrawingElement
    @ObservedObject var manager: AppManager
    let targetScreenID: String
    
    private var transformedPosition: CGPoint {
        let originalPos = element.points.first?.location ?? .zero
        let centerOffset = CGPoint(x: element.textSize.width / 2, y: element.textSize.height / 2)
        let originalCenter = CGPoint(x: originalPos.x + centerOffset.x, y: originalPos.y + centerOffset.y)
        
        var pos = originalCenter
        if let elementScreenID = element.screenID, elementScreenID != targetScreenID {
            if let srcSize = manager.size(from: elementScreenID),
               let destSize = manager.size(from: targetScreenID) {
                let transform = manager.getTransform(from: srcSize, to: destSize, mode: manager.mirroringScaleMode)
                pos = originalCenter.applying(transform)
            }
        }
        if manager.isCanvasModeEnabled && manager.canvasColor != .none {
            pos = manager.toScreenSpace(pos)
        }
        return pos
    }
    
    private var transformedScale: CGFloat {
        var scale = 1.0
        if let elementScreenID = element.screenID, elementScreenID != targetScreenID {
            if let srcSize = manager.size(from: elementScreenID),
               let destSize = manager.size(from: targetScreenID) {
                scale = manager.lineWidthScale(from: srcSize, to: destSize, mode: manager.mirroringScaleMode)
            }
        }
        if manager.isCanvasModeEnabled && manager.canvasColor != .none {
            scale *= manager.zoomScale
        }
        return scale
    }
    
    private var actualTextSize: CGSize {
        guard let text = element.text else { return .zero }
        let maxW = manager.getMaxTextWidth(for: element) * transformedScale
        return measureText(
            text,
            fontSize: element.fontSize * transformedScale,
            isBold: element.isBold,
            isItalic: element.isItalic,
            fontFamily: element.fontFamily,
            maxWidth: maxW
        )
    }

    var body: some View {
        Text(element.text ?? "")
            .font(element.fontFamily.toFont(size: element.fontSize * transformedScale, isBold: element.isBold, isItalic: element.isItalic))
            .foregroundColor(element.color)
            .opacity(element.opacity)
            .multilineTextAlignment(element.textAlignment)
            .frame(width: actualTextSize.width, height: actualTextSize.height, alignment: .topLeading)
            .padding(6 * transformedScale)
            .background(
                Group {
                    switch element.textBackgroundStyle {
                    case .none:
                        Color.clear
                    case .solid:
                        RoundedRectangle(cornerRadius: 6 * transformedScale)
                            .fill(element.color.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6 * transformedScale)
                                    .stroke(element.color.opacity(0.25), lineWidth: 1 * transformedScale)
                            )
                    case .glass:
                        RoundedRectangle(cornerRadius: 6 * transformedScale)
                            .fill(Color.clear)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 6 * transformedScale))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6 * transformedScale)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1 * transformedScale)
                            )
                    case .border:
                        RoundedRectangle(cornerRadius: 6 * transformedScale)
                            .stroke(element.color.opacity(0.4), lineWidth: 1 * transformedScale)
                    }
                }
            )
            .position(transformedPosition)
            .allowsHitTesting(manager.selectedTool == .text && (element.screenID == targetScreenID || element.screenID == nil))
            .onTapGesture(count: 2) {
                if element.screenID == targetScreenID || element.screenID == nil {
                    manager.commitAllActiveTextElements()
                    if let idx = manager.elements.firstIndex(where: { $0.id == element.id }) {
                        manager.elements[idx].isEditing = true
                        manager.updateWindowsKeyFocus()
                    }
                }
            }
    }
}

struct TextEditorWrapper: View {
    let element: DrawingElement
    @ObservedObject var manager: AppManager
    @FocusState private var isFocused: Bool
    
    private var transformedScale: CGFloat {
        if manager.isCanvasModeEnabled && manager.canvasColor != .none {
            return manager.zoomScale
        }
        return 1.0
    }
    
    private var transformedPosition: CGPoint {
        let originalPos = element.points.first?.location ?? .zero
        let centerOffset = CGPoint(x: element.textSize.width / 2, y: element.textSize.height / 2)
        let originalCenter = CGPoint(x: originalPos.x + centerOffset.x, y: originalPos.y + centerOffset.y)
        
        if manager.isCanvasModeEnabled && manager.canvasColor != .none {
            return manager.toScreenSpace(originalCenter)
        }
        return originalCenter
    }
    
    private var actualTextSize: CGSize {
        return CGSize(
            width: element.textSize.width * transformedScale,
            height: element.textSize.height * transformedScale
        )
    }
    
    var body: some View {
        TextEditor(text: Binding(
            get: { element.text ?? "" },
            set: { newText in
                let maxW = manager.getMaxTextWidth(for: element)
                let newSize = measureText(newText, fontSize: element.fontSize, isBold: element.isBold, isItalic: element.isItalic, fontFamily: element.fontFamily, maxWidth: maxW)
                manager.updateTextElement(id: element.id, text: newText, size: newSize)
            }
        ))
        .font(element.fontFamily.toFont(size: element.fontSize * transformedScale, isBold: element.isBold, isItalic: element.isItalic))
        .foregroundColor(element.color)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .background(Color.clear)
        .multilineTextAlignment(element.textAlignment)
        .focused($isFocused)
        .focusEffectDisabled()
        .frame(width: actualTextSize.width, height: actualTextSize.height)
        .padding(6 * transformedScale)
        .background(
            Group {
                switch element.textBackgroundStyle {
                case .none:
                    Color.clear
                case .solid:
                    RoundedRectangle(cornerRadius: 6 * transformedScale)
                        .fill(element.color.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6 * transformedScale)
                                .stroke(element.color.opacity(0.25), lineWidth: 1 * transformedScale)
                        )
                case .glass:
                    RoundedRectangle(cornerRadius: 6 * transformedScale)
                        .fill(Color.clear)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 6 * transformedScale))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6 * transformedScale)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1 * transformedScale)
                        )
                case .border:
                    RoundedRectangle(cornerRadius: 6 * transformedScale)
                        .stroke(element.color.opacity(0.4), lineWidth: 1 * transformedScale)
                }
            }
        )
        .position(transformedPosition)
        .onAppear {
            isFocused = true
        }
        .onKeyPress { keyPress in
            if keyPress.key == .escape {
                manager.commitTextElement(id: element.id)
                return .handled
            }
            return .ignored
        }
    }
}

struct TextFontFamilyPopoverView: View {
    @ObservedObject var manager: AppManager
    let elementId: UUID
    @Binding var isPresented: Bool
    
    var body: some View {
        if let idx = manager.elements.firstIndex(where: { $0.id == elementId }) {
            let element = manager.elements[idx]
            VStack(alignment: .leading, spacing: 10) {
                Text("Font Family")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Divider()
                    .opacity(0.5)
                
                VStack(spacing: 4) {
                    ForEach(GazeFontFamily.allCases) { family in
                        Button(action: {
                            manager.recordState()
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                                guard let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                                let currentElement = manager.elements[currentIdx]
                                manager.elements[currentIdx].fontFamily = family
                                let text = currentElement.text ?? ""
                                let maxW = manager.getMaxTextWidth(for: currentElement)
                                manager.elements[currentIdx].textSize = measureText(text, fontSize: currentElement.fontSize, isBold: currentElement.isBold, isItalic: currentElement.isItalic, fontFamily: family, maxWidth: maxW)
                                manager.defaultFontFamily = family
                                isPresented = false
                            }
                        }) {
                            HStack {
                                Text(family.displayName)
                                    .font(family.toFont(size: 13, isBold: false, isItalic: false))
                                Spacer()
                                if element.fontFamily == family {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(element.fontFamily == family ? Color.primary.opacity(0.06) : Color.clear)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)
            .frame(width: 160)
            .glassEffect(.regular, in: ConcentricRectangle())
            .overlay(
                ConcentricRectangle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
        }
    }
}

struct TextBackgroundStylePopoverView: View {
    @ObservedObject var manager: AppManager
    let elementId: UUID
    @Binding var isPresented: Bool
    
    var body: some View {
        if let idx = manager.elements.firstIndex(where: { $0.id == elementId }) {
            let element = manager.elements[idx]
            VStack(alignment: .leading, spacing: 10) {
                Text("Background Style")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Divider()
                    .opacity(0.5)
                
                VStack(spacing: 4) {
                    ForEach(TextBackgroundStyle.allCases) { style in
                        Button(action: {
                            manager.recordState()
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                                guard let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                                manager.elements[currentIdx].textBackgroundStyle = style
                                isPresented = false
                            }
                        }) {
                            HStack {
                                Image(systemName: iconForStyle(style))
                                    .font(.system(size: 11))
                                    .frame(width: 16)
                                Text(style.displayName)
                                    .font(.system(size: 11, weight: .medium))
                                Spacer()
                                if element.textBackgroundStyle == style {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(element.textBackgroundStyle == style ? Color.primary.opacity(0.06) : Color.clear)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)
            .frame(width: 160)
            .glassEffect(.regular, in: ConcentricRectangle())
            .overlay(
                ConcentricRectangle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .presentationBackground(.clear)
            .preferredColorScheme(.dark)
        }
    }
    
    private func iconForStyle(_ style: TextBackgroundStyle) -> String {
        switch style {
        case .none: return "square.dashed"
        case .solid: return "square.fill"
        case .glass: return "square.stack.3d.up"
        case .border: return "square"
        }
    }
}

struct TextSelectionHUD: View {
    @ObservedObject var manager: AppManager
    let elementId: UUID
    @State private var activeTab: TextHUDTab = .format
    @State private var showFontPopover = false
    @State private var showBackgroundPopover = false
    
    private let presetColors: [Color] = [
        .black,
        .white,
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.19, green: 0.82, blue: 0.35),
        Color(red: 0.04, green: 0.52, blue: 1.0)
    ]
    
    var body: some View {
        if let idx = manager.elements.firstIndex(where: { $0.id == elementId }),
           manager.elements[idx].tool == .text {
            let element = manager.elements[idx]
            HStack(spacing: 8) {
                // Tab switcher
                HStack(spacing: 4) {
                    ForEach(TextHUDTab.allCases) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.78)) {
                                activeTab = tab
                            }
                        }) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(activeTab == tab ? .primary : .secondary)
                                .frame(width: 22, height: 22)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(activeTab == tab ? 0.08 : 0.0))
                                )
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .focusEffectDisabled()
                        .noFocusRing()
                        .help(tab.displayName)
                    }
                }
                
                Color.primary.opacity(0.12)
                    .frame(width: 1, height: 16)
                
                // Active Tab Content
                HStack(spacing: 8) {
                    switch activeTab {
                    case .format:
                        HStack(spacing: 4) {
                            // Edit Text Button
                            HUDButton(
                                iconName: "character.cursor.ibeam",
                                tooltip: "Edit Text"
                            ) {
                                manager.commitAllActiveTextElements()
                                if let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) {
                                    manager.elements[currentIdx].isEditing = true
                                    manager.updateWindowsKeyFocus()
                                }
                            }
                            
                            Color.primary.opacity(0.08)
                                .frame(width: 1, height: 16)
                            
                            // Bold Toggle
                            HUDButton(
                                iconName: "bold",
                                tooltip: "Bold",
                                isSelected: element.isBold
                            ) {
                                manager.recordState()
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                                    guard let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                                    let currentElement = manager.elements[currentIdx]
                                    let text = currentElement.text ?? ""
                                    let nextBold = !currentElement.isBold
                                    manager.elements[currentIdx].isBold = nextBold
                                    let maxW = manager.getMaxTextWidth(for: currentElement)
                                    manager.elements[currentIdx].textSize = measureText(text, fontSize: currentElement.fontSize, isBold: nextBold, isItalic: currentElement.isItalic, fontFamily: currentElement.fontFamily, maxWidth: maxW)
                                }
                            }
                            
                            // Italic Toggle
                            HUDButton(
                                iconName: "italic",
                                tooltip: "Italic",
                                isSelected: element.isItalic
                            ) {
                                manager.recordState()
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                                    guard let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                                    let currentElement = manager.elements[currentIdx]
                                    let text = currentElement.text ?? ""
                                    let nextItalic = !currentElement.isItalic
                                    manager.elements[currentIdx].isItalic = nextItalic
                                    let maxW = manager.getMaxTextWidth(for: currentElement)
                                    manager.elements[currentIdx].textSize = measureText(text, fontSize: currentElement.fontSize, isBold: currentElement.isBold, isItalic: nextItalic, fontFamily: currentElement.fontFamily, maxWidth: maxW)
                                }
                            }
                            
                            // Font Family
                            HUDButton(
                                iconName: "textformat",
                                tooltip: "Font Family",
                                isSelected: showFontPopover
                            ) {
                                showFontPopover = true
                            }
                            .popover(isPresented: $showFontPopover, arrowEdge: .top) {
                                TextFontFamilyPopoverView(manager: manager, elementId: elementId, isPresented: $showFontPopover)
                                    .presentationBackground(.clear)
                            }
                        }
                        
                        Color.primary.opacity(0.08)
                            .frame(width: 1, height: 16)
                        
                        // Font Size (+ / -) controls
                        HStack(spacing: 4) {
                            HUDButton(
                                iconName: "minus.circle",
                                tooltip: "Decrease Font Size"
                            ) {
                                manager.recordState()
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                                    guard let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                                    let currentElement = manager.elements[currentIdx]
                                    let currentSize = currentElement.fontSize
                                    let newSize = max(8, currentSize - 2)
                                    manager.elements[currentIdx].fontSize = newSize
                                    let text = currentElement.text ?? ""
                                    let maxW = manager.getMaxTextWidth(for: currentElement)
                                    manager.elements[currentIdx].textSize = measureText(text, fontSize: newSize, isBold: currentElement.isBold, isItalic: currentElement.isItalic, fontFamily: currentElement.fontFamily, maxWidth: maxW)
                                    manager.defaultFontSize = newSize
                                }
                            }
                            
                            Text("\(Int(element.fontSize))")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 20, alignment: .center)
                            
                            HUDButton(
                                iconName: "plus.circle",
                                tooltip: "Increase Font Size"
                            ) {
                                manager.recordState()
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                                    guard let currentIdx = manager.elements.firstIndex(where: { $0.id == elementId }) else { return }
                                    let currentElement = manager.elements[currentIdx]
                                    let currentSize = currentElement.fontSize
                                    let newSize = min(120, currentSize + 2)
                                    manager.elements[currentIdx].fontSize = newSize
                                    let text = currentElement.text ?? ""
                                    let maxW = manager.getMaxTextWidth(for: currentElement)
                                    manager.elements[currentIdx].textSize = measureText(text, fontSize: newSize, isBold: currentElement.isBold, isItalic: currentElement.isItalic, fontFamily: currentElement.fontFamily, maxWidth: maxW)
                                    manager.defaultFontSize = newSize
                                }
                            }
                        }
                        
                    case .style:
                        HStack(spacing: 4) {
                            ForEach(presetColors, id: \.self) { color in
                                HUDColorCircle(
                                    color: color,
                                    isSelected: element.color == color
                                ) {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        manager.recolorSelectedElement(to: color)
                                    }
                                }
                            }
                            HUDCustomColorButton(manager: manager, elementId: elementId)
                        }
                        
                        Color.primary.opacity(0.08)
                            .frame(width: 1, height: 16)
                        
                        // Background Style Popover Trigger
                        let bgIcon: String = {
                            switch element.textBackgroundStyle {
                            case .none: return "square.dashed"
                            case .solid: return "square.fill"
                            case .glass: return "square.stack.3d.up"
                            case .border: return "square"
                            }
                        }()
                        
                        HUDButton(
                            iconName: bgIcon,
                            tooltip: "Background Style: \(element.textBackgroundStyle.displayName)",
                            isSelected: showBackgroundPopover
                        ) {
                            showBackgroundPopover = true
                        }
                        .popover(isPresented: $showBackgroundPopover, arrowEdge: .top) {
                            TextBackgroundStylePopoverView(manager: manager, elementId: elementId, isPresented: $showBackgroundPopover)
                                .presentationBackground(.clear)
                        }
                        
                    case .actions:
                        // Z-indexing
                        HStack(spacing: 4) {
                            HUDButton(
                                iconName: "square.2.layers.3d.bottom.filled",
                                tooltip: "Send to Back"
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    manager.sendSelectedElementToBack()
                                }
                            }
                            
                            HUDButton(
                                iconName: "square.2.layers.3d.top.filled",
                                tooltip: "Bring to Front"
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    manager.bringSelectedElementToFront()
                                }
                            }
                        }
                        
                        Color.primary.opacity(0.08)
                            .frame(width: 1, height: 16)
                        
                        // Utilities: Duplicate
                        HStack(spacing: 4) {
                            HUDButton(
                                iconName: "plus.square.on.square",
                                tooltip: "Duplicate"
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    manager.duplicateSelectedElement()
                                }
                            }
                        }
                    }
                }
                .transition(.opacity)
                
                Color.primary.opacity(0.12)
                    .frame(width: 1, height: 16)
                
                HUDButton(
                    iconName: "trash",
                    tooltip: "Delete Selection",
                    isDestructive: true
                ) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        manager.deleteSelectedElement()
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .glassEffect(.regular, in: .capsule)
            .overlay(
                Capsule().stroke(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: activeTab)
        }
    }
}



func measureText(_ text: String, fontSize: CGFloat, isBold: Bool = false, isItalic: Bool = false, fontFamily: GazeFontFamily = .system, maxWidth: CGFloat = 800.0) -> CGSize {
    let string = text.isEmpty ? " " : text
    let font = fontFamily.toNSFont(size: fontSize, isBold: isBold, isItalic: isItalic)
    
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let attributedString = NSAttributedString(string: string, attributes: attributes)
    
    let constraintSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
    
    let rect = attributedString.boundingRect(
        with: constraintSize,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    )
    
    return CGSize(
        width: max(120.0, ceil(rect.width) + 40),
        height: max(36.0, ceil(rect.height) + 16)
    )
}

extension NSCursor {
    @MainActor static let invisible: NSCursor = {
        let image = NSImage(size: NSSize(width: 1, height: 1))
        return NSCursor(image: image, hotSpot: NSPoint.zero)
    }()
    
    @MainActor static func customCursor(symbolName: String, pointSize: CGFloat = 16, weight: NSFont.Weight = .regular, color: NSColor = .labelColor, hotSpot: NSPoint? = nil) -> NSCursor {
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            .applying(.init(paletteColors: [color]))
        
        guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config) else {
            return .arrow
        }
        
        // Render to a new image to ensure exact size and representation
        let size = image.size
        let paddedSize = NSSize(width: size.width + 4, height: size.height + 4)
        let finalImage = NSImage(size: paddedSize)
        finalImage.lockFocus()
        
        // Add a contrasting shadow so the cursor remains visible on same-colored backgrounds
        let shadow = NSShadow()
        let brightness = color.usingColorSpace(.deviceRGB)?.brightnessComponent ?? 0.0
        let isDark = brightness < 0.5
        shadow.shadowColor = isDark ? NSColor.white.withAlphaComponent(0.8) : NSColor.black.withAlphaComponent(0.5)
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = 1.5
        shadow.set()
        
        image.draw(at: NSPoint(x: 2, y: 2), from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        finalImage.unlockFocus()
        
        let center = NSPoint(x: paddedSize.width / 2, y: paddedSize.height / 2)
        // Adjust default hotspot per tool
        var defaultHotSpot = center
        if symbolName == "pencil.and.outline" || symbolName == "highlighter" || symbolName == "eraser" || symbolName == "eraser.fill" {
            // Bottom left tip
            defaultHotSpot = NSPoint(x: 4, y: paddedSize.height - 4)
        } else if symbolName == "smallcircle.filled.circle" {
            // Center
            defaultHotSpot = center
        } else if symbolName == "arrow.up.left" || symbolName == "hand.point.up.left.fill" {
             // Top left tip
             defaultHotSpot = NSPoint(x: 4, y: 4)
        }
        
        return NSCursor(image: finalImage, hotSpot: hotSpot ?? defaultHotSpot)
    }
    
    @MainActor static func dynamicDotCursor(diameter: CGFloat, color: NSColor) -> NSCursor {
        // Ensure minimum visibility
        let renderSize = max(diameter, 4.0)
        let imageSize = renderSize + 4.0 // Add padding for shadow/border
        
        let image = NSImage(size: NSSize(width: imageSize, height: imageSize))
        image.lockFocus()
        
        let rect = NSRect(x: 2.0, y: 2.0, width: renderSize, height: renderSize)
        let path = NSBezierPath(ovalIn: rect)
        
        // Fill
        color.setFill()
        path.fill()
        
        // Border for contrast against similar backgrounds
        NSColor.white.withAlphaComponent(0.8).setStroke()
        path.lineWidth = 1.5
        path.stroke()
        
        NSColor.black.withAlphaComponent(0.5).setStroke()
        path.lineWidth = 0.5
        path.stroke()
        
        image.unlockFocus()
        
        return NSCursor(image: image, hotSpot: NSPoint(x: imageSize / 2.0, y: imageSize / 2.0))
    }
}

struct MiniMapView: View {
    @ObservedObject var manager: AppManager
    let screen: NSScreen
    let drawElement: (DrawingElement, inout GraphicsContext) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered: Bool = false
    @State private var isDraggingViewport: Bool = false
    
    private var screenID: String {
        "\(screen.frame.origin.x),\(screen.frame.origin.y),\(screen.frame.size.width),\(screen.frame.size.height)"
    }
    
    private let miniMapWidth: CGFloat = 190
    private let miniMapHeight: CGFloat = 115
    
    private var canvasBounds: CGRect {
        let selectedScreenElements = manager.elements.filter {
            $0.screenID == screenID || $0.screenID == nil || (manager.isCanvasModeEnabled && manager.isMirroringEnabled)
        }
        let screenW = screen.frame.width
        let screenH = screen.frame.height
        
        let viewport = CGRect(
            x: -manager.panOffset.x / manager.zoomScale,
            y: -manager.panOffset.y / manager.zoomScale,
            width: screenW / manager.zoomScale,
            height: screenH / manager.zoomScale
        )
        
        var unionBox = viewport
        for el in selectedScreenElements {
            let elBox = manager.boundingBox(of: el)
            unionBox = unionBox.union(elBox)
        }
        
        let paddingX = max(50, unionBox.width * 0.1)
        let paddingY = max(50, unionBox.height * 0.1)
        return unionBox.insetBy(dx: -paddingX, dy: -paddingY)
    }
    
    private var isDark: Bool {
        if manager.canvasColor != .none {
            return manager.canvasColor.isDark
        }
        return colorScheme == .dark
    }
    
    var body: some View {
        Group {
            if manager.isMiniMapCollapsed {
                // Collapsed view: tiny bubble button with liquid glass effect
                Button(action: {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                        manager.isMiniMapCollapsed = false
                    }
                }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isDark ? .white : .black.opacity(0.85))
                        .frame(width: 38, height: 38)
                        .glassEffect(.regular, in: ConcentricRectangle())
                        .overlay(
                            ConcentricRectangle().stroke(
                                LinearGradient(
                                    colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 0.8
                            )
                        )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isHovered = hovering
                    }
                }
            } else {
                // Expanded card view with liquid glass effect
                VStack(spacing: 0) {
                    // Header title bar
                    HStack(spacing: 6) {
                        Image(systemName: "map")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Navigator")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Zoom Badge
                        Text("\(Int(round(manager.zoomScale * 100)))%")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.primary.opacity(0.05))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                        
                        // Reset Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                manager.zoomScale = 1.0
                                manager.panOffset = .zero
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help("Reset Canvas View")
                        
                        Color.primary.opacity(0.08).frame(width: 1, height: 10)
                        
                        // Collapse Button
                        Button(action: {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                manager.isMiniMapCollapsed = true
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.secondary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Color.white.opacity(isDark ? 0.02 : 0.06)
                    )
                    .overlay(
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.primary.opacity(isDark ? 0.08 : 0.04))
                                .frame(height: 0.5)
                        }
                    )
                    
                    // Live mini-map viewport drawing
                    Canvas { context, size in
                        let bounds = canvasBounds
                        let scaleX = size.width / bounds.width
                        let scaleY = size.height / bounds.height
                        let scale = min(scaleX, scaleY)
                        
                        let dx = (size.width - bounds.width * scale) / 2 - bounds.minX * scale
                        let dy = (size.height - bounds.height * scale) / 2 - bounds.minY * scale
                        
                        var miniContext = context
                        miniContext.translateBy(x: dx, y: dy)
                        miniContext.scaleBy(x: scale, y: scale)
                        
                        // Render all drawing elements scaled down
                        for element in manager.elements {
                            guard element.tool != .text else { continue }
                            if element.screenID == screenID || element.screenID == nil || (manager.isCanvasModeEnabled && manager.isMirroringEnabled) {
                                drawElement(element, &miniContext)
                            }
                        }
                        
                        // Render current viewport rectangle
                        let screenW = screen.frame.width
                        let screenH = screen.frame.height
                        let viewport = CGRect(
                            x: -manager.panOffset.x / manager.zoomScale,
                            y: -manager.panOffset.y / manager.zoomScale,
                            width: screenW / manager.zoomScale,
                            height: screenH / manager.zoomScale
                        )
                        
                        var path = Path()
                        path.addRect(viewport)
                        
                        let strokeColor = isDraggingViewport ? Color.blue : Color.blue.opacity(0.85)
                        let fillColor = isDraggingViewport ? Color.blue.opacity(0.18) : Color.blue.opacity(0.10)
                        
                        miniContext.fill(
                            path,
                            with: .color(fillColor)
                        )
                        
                        miniContext.stroke(
                            path,
                            with: .color(strokeColor.opacity(0.5)),
                            style: StrokeStyle(lineWidth: 1.0 / scale)
                        )
                        
                        // Corner brackets for liquid glass HUD feel
                        let bracketLength = min(viewport.width, viewport.height) * 0.12
                        let bracketWidth = 2.5 / scale
                        let bracketColor = isDraggingViewport ? Color.cyan : Color.blue
                        
                        var bracketPath = Path()
                        // Top-left
                        bracketPath.move(to: CGPoint(x: viewport.minX, y: viewport.minY + bracketLength))
                        bracketPath.addLine(to: CGPoint(x: viewport.minX, y: viewport.minY))
                        bracketPath.addLine(to: CGPoint(x: viewport.minX + bracketLength, y: viewport.minY))
                        
                        // Top-right
                        bracketPath.move(to: CGPoint(x: viewport.maxX - bracketLength, y: viewport.minY))
                        bracketPath.addLine(to: CGPoint(x: viewport.maxX, y: viewport.minY))
                        bracketPath.addLine(to: CGPoint(x: viewport.maxX, y: viewport.minY + bracketLength))
                        
                        // Bottom-left
                        bracketPath.move(to: CGPoint(x: viewport.minX, y: viewport.maxY - bracketLength))
                        bracketPath.addLine(to: CGPoint(x: viewport.minX, y: viewport.maxY))
                        bracketPath.addLine(to: CGPoint(x: viewport.minX + bracketLength, y: viewport.maxY))
                        
                        // Bottom-right
                        bracketPath.move(to: CGPoint(x: viewport.maxX - bracketLength, y: viewport.maxY))
                        bracketPath.addLine(to: CGPoint(x: viewport.maxX, y: viewport.maxY))
                        bracketPath.addLine(to: CGPoint(x: viewport.maxX, y: viewport.maxY - bracketLength))
                        
                        miniContext.stroke(
                            bracketPath,
                            with: .color(bracketColor),
                            style: StrokeStyle(lineWidth: bracketWidth, lineCap: .round, lineJoin: .round)
                        )
                    }
                    .frame(width: miniMapWidth, height: miniMapHeight)
                    .clipped()
                    .background(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard manager.selectedTool != .cursor && !manager.isOverrideActive else { return }
                                isDraggingViewport = true
                                updatePanFromMiniMapDrag(at: value.location, viewSize: CGSize(width: miniMapWidth, height: miniMapHeight))
                            }
                            .onEnded { _ in
                                isDraggingViewport = false
                            }
                    )
                }
                .frame(width: miniMapWidth)
                .clipShape(ConcentricRectangle())
                .glassEffect(.regular, in: ConcentricRectangle())
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isHovered = hovering
                    }
                }
                .overlay(
                    ConcentricRectangle().stroke(
                        LinearGradient(
                            colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
                )
            }
        }
    }
    
    private func updatePanFromMiniMapDrag(at location: CGPoint, viewSize: CGSize) {
        let bounds = canvasBounds
        let scaleX = viewSize.width / bounds.width
        let scaleY = viewSize.height / bounds.height
        let scale = min(scaleX, scaleY)
        
        let dx = (viewSize.width - bounds.width * scale) / 2 - bounds.minX * scale
        let dy = (viewSize.height - bounds.height * scale) / 2 - bounds.minY * scale
        
        let canvasX = (location.x - dx) / scale
        let canvasY = (location.y - dy) / scale
        
        let screenW = screen.frame.width
        let screenH = screen.frame.height
        
        let newPanX = (screenW / 2.0) - canvasX * manager.zoomScale
        let newPanY = (screenH / 2.0) - canvasY * manager.zoomScale
        
        manager.panOffset = CGPoint(x: newPanX, y: newPanY)
    }
}

// MARK: - Page Control floating View

struct PageControlView: View {
    @ObservedObject var manager: AppManager
    @State private var isHovered = false
    @State private var showPageListPopover = false
    @State private var isPrevHovering = false
    @State private var isNextHovering = false
    @State private var isAddHovering = false
    @State private var isExportHovering = false
    @State private var isListHovering = false
    
    var body: some View {
        HStack(spacing: 6) {
            // Previous Page Button
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    manager.switchToPage(at: manager.currentPageIndex - 1)
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(manager.currentPageIndex > 0 ? (isPrevHovering ? .primary : .secondary) : .secondary.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 6).fill(isPrevHovering ? Color.primary.opacity(0.08) : Color.clear))
            }
            .buttonStyle(.plain)
            .disabled(manager.currentPageIndex == 0)
            .onHover { isPrevHovering = $0 }
            .help("Previous Page")
            
            // Current Page Display / Popover Trigger
            Button(action: { showPageListPopover.toggle() }) {
                HStack(spacing: 4) {
                    Text(manager.currentPageIndex < manager.pages.count ? manager.pages[manager.currentPageIndex].name : "Page \(manager.currentPageIndex + 1)")
                        .font(.system(size: 11, weight: .bold))
                    Image(systemName: "chevron.up")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundColor(isListHovering ? .primary : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 6).fill(isListHovering ? Color.primary.opacity(0.08) : Color.clear))
            }
            .buttonStyle(.plain)
            .onHover { isListHovering = $0 }
            .popover(isPresented: $showPageListPopover, arrowEdge: .top) {
                PageListPopoverView(manager: manager, isPresented: $showPageListPopover)
                    .presentationBackground(.clear)
            }
            .help("Page List & Manager")
            
            // Next Page Button
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    manager.switchToPage(at: manager.currentPageIndex + 1)
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(manager.currentPageIndex < manager.pages.count - 1 ? (isNextHovering ? .primary : .secondary) : .secondary.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 6).fill(isNextHovering ? Color.primary.opacity(0.08) : Color.clear))
            }
            .buttonStyle(.plain)
            .disabled(manager.currentPageIndex == manager.pages.count - 1)
            .onHover { isNextHovering = $0 }
            .help("Next Page")
            
            Divider()
                .frame(height: 16)
                .opacity(0.3)
            
            // Add Page Button
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    manager.addPage()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isAddHovering ? .primary : .secondary)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 6).fill(isAddHovering ? Color.primary.opacity(0.08) : Color.clear))
            }
            .buttonStyle(.plain)
            .onHover { isAddHovering = $0 }
            .help("Add New Page")
            
            // PDF Export Button
            Button(action: {
                manager.exportToPDF()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isExportHovering ? .primary : .secondary)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 6).fill(isExportHovering ? Color.primary.opacity(0.08) : Color.clear))
            }
            .buttonStyle(.plain)
            .onHover { isExportHovering = $0 }
            .help("Export All Pages to PDF")
        }
        .padding(.horizontal, 6)
        .frame(height: 38)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                LinearGradient(
                    colors: [Color.primary.opacity(0.18), Color.primary.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Page List popover View

struct PageRowView: View {
    @ObservedObject var manager: AppManager
    let idx: Int
    let page: CanvasPage
    @Binding var renamingIndex: Int?
    @Binding var renameText: String
    var onSelect: () -> Void
    
    @FocusState private var renameFieldIsFocused: Bool
    
    var body: some View {
        let isSelected = idx == manager.currentPageIndex
        HStack {
            if renamingIndex == idx {
                TextField("Page Name", text: $renameText, onCommit: {
                    if !renameText.trimmingCharacters(in: .whitespaces).isEmpty {
                        manager.renamePage(at: idx, to: renameText)
                    }
                    renamingIndex = nil
                })
                .font(.system(size: 12, weight: .medium))
                .textFieldStyle(.plain)
                .focused($renameFieldIsFocused)
                .onAppear {
                    renameFieldIsFocused = true
                }
            } else {
                Text(page.name)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .primary : .primary.opacity(0.8))
                    .onTapGesture(count: 2) {
                        renameText = page.name
                        renamingIndex = idx
                    }
            }
            
            Spacer()
            
            // Rename Button
            if renamingIndex != idx {
                Button(action: {
                    renameText = page.name
                    renamingIndex = idx
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Rename Page (or double-click name)")
            }
            
            // Delete Button
            Button(action: {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                    manager.deletePage(at: idx)
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 9))
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .disabled(manager.pages.count <= 1)
            .help("Delete Page")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.primary.opacity(0.08) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if renamingIndex == nil {
                onSelect()
            }
        }
    }
}

struct PageListPopoverView: View {
    @ObservedObject var manager: AppManager
    @Binding var isPresented: Bool
    @State private var renamingIndex: Int? = nil
    @State private var renameText: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Canvas Pages")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(manager.pages.enumerated()), id: \.element.id) { idx, page in
                        PageRowView(
                            manager: manager,
                            idx: idx,
                            page: page,
                            renamingIndex: $renamingIndex,
                            renameText: $renameText,
                            onSelect: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                    manager.switchToPage(at: idx)
                                }
                                isPresented = false
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: 180)
            
            Divider()
                .opacity(0.4)
            
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    manager.addPage()
                }
                isPresented = false
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 12))
                    Text("Add Page")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 220)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                LinearGradient(
                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
        )
        .preferredColorScheme(.dark)
    }
}
