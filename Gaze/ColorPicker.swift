import SwiftUI
import AppKit

// MARK: - Comparable+Clamped (from Solid)
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Color ↔ HSB Helpers
extension Color {
    /// Extract HSB components from a SwiftUI Color
    func hsbComponents() -> (h: CGFloat, s: CGFloat, b: CGFloat) {
        let nsColor = NSColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        nsColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b)
    }
    
    /// Create a SwiftUI Color from HSB
    static func fromHSB(h: CGFloat, s: CGFloat, b: CGFloat) -> Color {
        Color(nsColor: NSColor(
            calibratedHue: h,
            saturation: s,
            brightness: b,
            alpha: 1.0
        ))
    }
}

// MARK: - 1D Color Picker Slider (inspired by Solid's Slider)
struct ColorPickerSlider<Track: View, Thumb: View>: View {
    @Binding var value: Double
    @ViewBuilder var track: () -> Track
    @ViewBuilder var thumb: () -> Thumb
    
    @State private var isHovering = false
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            let thumbDiameter = geometry.size.height
            let maxTravel = geometry.size.width - thumbDiameter
            
            track()
                .clipShape(RoundedRectangle(cornerRadius: .infinity, style: .continuous))
                .overlay(alignment: .leading) {
                    thumb()
                        .aspectRatio(1, contentMode: .fit)
                        .scaleEffect(isDragging ? 1.2 : (isHovering ? 1.1 : 1.0))
                        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isHovering || isDragging)
                        .offset(x: value * maxTravel)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { dragValue in
                            isDragging = true
                            guard maxTravel > 0 else { return }
                            let start = thumbDiameter / 2
                            let location = dragValue.location.x - start
                            value = (location / maxTravel).clamped(to: 0...1)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                isDragging = false
                            }
                        }
                )
                .onHover { hovering in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        isHovering = hovering
                    }
                }
        }
    }
}

// MARK: - 2D Dual Axis Slider (inspired by Solid's DualAxisSlider)
struct ColorPickerDualAxisSlider<Background: View, Cursor: View>: View {
    @Binding var horizontal: Double
    @Binding var vertical: Double
    @ViewBuilder var background: () -> Background
    @ViewBuilder var cursor: () -> Cursor
    
    @State private var isHovering = false
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            background()
                .overlay(alignment: .bottomLeading) {
                    cursor()
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.35), radius: 2.0, x: 0, y: 0.5)
                        .scaleEffect(isDragging ? 1.25 : (isHovering ? 1.12 : 1.0))
                        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHovering || isDragging)
                        .offset(x: -7, y: 7)
                        .offset(
                            x: horizontal * geometry.size.width,
                            y: -vertical * geometry.size.height
                        )
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            guard geometry.size.width > 0 && geometry.size.height > 0 else { return }
                            horizontal = (value.location.x / geometry.size.width).clamped(to: 0...1)
                            vertical = 1 - (value.location.y / geometry.size.height).clamped(to: 0...1)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                isDragging = false
                            }
                        }
                )
                .onHover { hovering in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        isHovering = hovering
                    }
                }
        }
    }
}

// MARK: - Saturation/Brightness Grid (inspired by Solid's SaturationBrightnessSlider)
struct SatBrightnessGrid: View {
    var hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double
    
    var body: some View {
        ColorPickerDualAxisSlider(horizontal: $saturation, vertical: $brightness) {
            ZStack {
                // Base: fully saturated hue
                Color(nsColor: NSColor(
                    calibratedHue: CGFloat(hue),
                    saturation: 1,
                    brightness: 1,
                    alpha: 1
                ))
                
                // White gradient: left → right (desaturates)
                LinearGradient(
                    colors: [.white, .white.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                // Black gradient: bottom → top (darkens)
                LinearGradient(
                    colors: [.black, .black.opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
        } cursor: {
            Circle()
                .strokeBorder(.white, lineWidth: 2.0)
                .shadow(color: .black.opacity(0.4), radius: 2.0, x: 0, y: 1.0)
        }
    }
}

// MARK: - Hue Slider Bar (inspired by Solid's HueSlider)
struct HueBar: View {
    @Binding var hue: Double
    
    var body: some View {
        ColorPickerSlider(value: $hue) {
            ZStack {
                LinearGradient(
                    colors: hueColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 10)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.0)
                )
            }
        } thumb: {
            Circle()
                .strokeBorder(.white, lineWidth: 1.5)
                .shadow(color: .black.opacity(0.4), radius: 1.5, x: 0, y: 0.5)
                .padding(1)
        }
        .frame(height: 14)
    }
    
    private var hueColors: [Color] {
        stride(from: 0.0, through: 360.0, by: 30.0).map { deg in
            Color(nsColor: NSColor(
                calibratedHue: deg / 360.0,
                saturation: 1,
                brightness: 1,
                alpha: 1
            ))
        }
    }
}

// MARK: - Complete Custom Color Picker View
struct CustomColorPickerView: View {
    @Binding var selectedColor: Color
    
    @State private var hue: Double
    @State private var saturation: Double
    @State private var brightness: Double
    
    init(selectedColor: Binding<Color>) {
        _selectedColor = selectedColor
        let hsb = selectedColor.wrappedValue.hsbComponents()
        _hue = State(initialValue: Double(hsb.h))
        _saturation = State(initialValue: Double(hsb.s))
        _brightness = State(initialValue: Double(hsb.b))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Saturation/Brightness 2D pad
            SatBrightnessGrid(
                hue: hue,
                saturation: $saturation,
                brightness: $brightness
            )
            .aspectRatio(1.2, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.0)
            )
            
            // Hue slider
            HueBar(hue: $hue)
        }
        .padding(12)
        .frame(width: 200)
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
        .onChange(of: hue) { _, _ in syncColor() }
        .onChange(of: saturation) { _, _ in syncColor() }
        .onChange(of: brightness) { _, _ in syncColor() }
        .onChange(of: selectedColor) { _, newValue in
            let hsb = newValue.hsbComponents()
            if abs(hue - Double(hsb.h)) > 0.001 ||
               abs(saturation - Double(hsb.s)) > 0.001 ||
               abs(brightness - Double(hsb.b)) > 0.001 {
                hue = Double(hsb.h)
                saturation = Double(hsb.s)
                brightness = Double(hsb.b)
            }
        }
    }
    
    private func syncColor() {
        let newColor = Color.fromHSB(h: CGFloat(hue), s: CGFloat(saturation), b: CGFloat(brightness))
        if selectedColor != newColor {
            DispatchQueue.main.async {
                self.selectedColor = newColor
            }
        }
    }
}

