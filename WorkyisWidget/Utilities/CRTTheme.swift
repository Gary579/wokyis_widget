import SwiftUI

enum CRTTheme {
    // MARK: - Phosphor Colors
    static let phosphorGreen = Color(red: 0.2, green: 1.0, blue: 0.2)
    static let phosphorAmber = Color(red: 1.0, green: 0.75, blue: 0.0)
    static let dimGreen = Color(red: 0.05, green: 0.3, blue: 0.05)
    static let dimAmber = Color(red: 0.3, green: 0.2, blue: 0.0)
    static let screenBackground = Color(red: 0.02, green: 0.04, blue: 0.02)
    static let panelBackground = Color(red: 0.03, green: 0.06, blue: 0.03)
    static let bezelColor = Color(red: 0.12, green: 0.12, blue: 0.1)
    static let borderGreen = Color(red: 0.1, green: 0.4, blue: 0.1)

    // MARK: - Typography
    static let clockFont = Font.system(size: 140, weight: .bold, design: .monospaced)
    static let dateFont = Font.system(size: 36, weight: .regular, design: .monospaced)
    static let headerFont = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let dataFont = Font.system(size: 24, weight: .medium, design: .monospaced)
    static let labelFont = Font.system(size: 20, weight: .regular, design: .monospaced)
    static let smallFont = Font.system(size: 16, weight: .regular, design: .monospaced)

    // MARK: - Animation
    static let scanlineSpeed: Double = 3.5
    static let flickerIntensity: Double = 0.01
    static let glowRadius: CGFloat = 4.0

    // MARK: - Layout
    static let panelCornerRadius: CGFloat = 8.0
    static let panelPadding: CGFloat = 16.0
    static let panelSpacing: CGFloat = 12.0
    static let bezelWidth: CGFloat = 16.0
    static let screenWidth: CGFloat = 1280.0
    static let screenHeight: CGFloat = 720.0
}

// MARK: - Phosphor Glow Text Modifier
struct PhosphorGlow: ViewModifier {
    var color: Color = CRTTheme.phosphorGreen
    var radius: CGFloat = CRTTheme.glowRadius

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius * 0.5)
            .shadow(color: color.opacity(0.4), radius: radius)
            .shadow(color: color.opacity(0.2), radius: radius * 2)
    }
}

extension View {
    func phosphorGlow(_ color: Color = CRTTheme.phosphorGreen, radius: CGFloat = CRTTheme.glowRadius) -> some View {
        modifier(PhosphorGlow(color: color, radius: radius))
    }
}
