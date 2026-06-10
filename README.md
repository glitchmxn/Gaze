# Gaze Screen Annotation Utility

<p align="center">
  <img src="Resources/gaze.png" width="800" alt="Gaze Interface Preview">
</p>

A high-performance macOS screen annotation utility built with SwiftUI and AppKit. Specially engineered for teachers, presenters, and developers, Gaze is optimized for pen tablets with professional ink smoothing, stabilization, and multi-display setups.

## 📥 Direct Download

For a quick setup, you can download the pre-compiled version of the app directly:

👉 **[Download Gaze.zip](https://github.com/glitchmxn/Gaze/raw/main/Gaze.zip)** (Extract the ZIP file and drag `Gaze.app` into your Applications folder).

> [!NOTE]
> As the app is not signed with an official Apple Developer certificate, the first time you open it, you may need to right-click `Gaze.app` and choose **Open**, or navigate to **System Settings > Privacy & Security** and select **Open Anyway**.

---

## 🚀 Core Features

### 🎛️ Glassmorphic Floating Toolbar & Edge Snapping
* **Adaptive Edge Docking**: Drag the toolbar near any edge of your screen, and it will snap cleanly to the left, right, top, or bottom.
* **Compact Layout Switch**: The layout dynamically adjusts (switching between horizontal and vertical) depending on where it is docked, conserving valuable screen real estate.
* **Micro-Animations & Hover Effects**: Adaptive light/dark mode toolbar with clean hover interactions and haptic feedback profiles.

### ⏱️ Detachable Floating Timer & Stopwatch
* **Detachable HUD**: Drag the timer panel away from the toolbar to position it anywhere on your desktop.
* **Stopwatch with Laps**: Switch modes to record lap split intervals on the fly.
* **Interactive Alert Profiles**: Set timers with customizable warning behaviors, audible alarm cues, and canvas-edge flash overlays when time runs out.

### 🖋️ Professional Vector Ink Engine
* **Spline Interpolation**: Real-time Catmull-Rom spline math renders drawing strokes with beautiful, natural curves.
* **Weighted Moving Average (WMA) Stabilization**: Smooths out hand jitters for clean lines when using pen tablets or mouse inputs.
* **Proportional Stroke Width Scaling**: Resizing vector shapes automatically scales stroke widths to keep layouts proportional.

### 📐 Selection, Lasso & Smart Text Inputs
* **Lasso & Vector Selection**: Select, drag, resize, rotate, or re-order (Bring to Front / Send to Back) any annotation on the canvas.
* **Direct Text Editor**: Click anywhere or double-click an existing text selection to type notes directly on screen.
* **Intelligent Focus Detection**: Automatically pauses global hotkeys while you type to support natural keyboard symbols, and resumes instantly when editing completes.

### 📸 Smart Screenshots & Clipboard Exports
* **Precision Region Capture**: Capture full screen or select custom crop-regions.
* **Whiteboard-Only Export**: Save drawings against transparent backgrounds (ignoring background desktop apps) for clean documentation.
* **Zero-Spills Pipe Redirection**: Background screenshot processing runs asynchronously without blocking the main drawing threads.

---

## ⌨️ Keyboard Shortcuts & Global Hotkeys

Gaze registers global hotkeys to switch tools and perform actions instantly from any application:

| Action | Shortcut |
| :--- | :--- |
| **Cursor / Selection Interaction** | `⌥ + 1` |
| **Pencil Drawing Tool** | `⌥ + 2` |
| **Highlighter Tool** | `⌥ + 3` |
| **Text Box Tool** | `⌥ + 4` |
| **Lasso / Selection Mode** | `⌥ + 5` |
| **Laser Pointer Tool** | `⌥ + 6` |
| **Eraser Brush** | `⌥ + 7` |
| **Undo Stroke** | `⌥ + 8` |
| **Redo Stroke** | `⌥ + 9` |
| **Toggle Canvas Visibility** | `⌥ + 0` |

---

## ⚡ Performance Engineering (Zero CPU Spikes)

Gaze runs at a solid **60/120fps (ProMotion)** with sub-millisecond CPU overhead through several key optimizations:

1. **Pre-compiled Path Caching**: Flat uniform-pressure strokes are cached as a single `Path`, bypassing the expensive segment-by-segment spline calculation on redraw cycles.
2. **Conditional Compositing Layers**: Offscreen transparency layers (`context.drawLayer`) are only created when rendering transparent elements (like highlighters). Opaque elements are rendered directly on the main context.
3. **Single-Pass Laser Trail**: Trail spline control points are computed exactly once per frame and shared across both the neon glow and core overlay layers.
4. **Batched Mutations**: Drawing and selection updates are processed as single-pass mutated arrays, minimizing Swift UI publisher (`@Published`) updates.

---

## 🛠️ Getting Started

### Open in Xcode
1. Double-click **`Gaze.xcodeproj`**.
2. Select the **Gaze** target and **My Mac** in the scheme selector.
3. Press **Cmd + R** to build and run.

### Running Unit & Performance Tests
To run the automated test suite:
```bash
xcodebuild test -scheme Gaze -destination 'platform=macOS,arch=arm64'
```
