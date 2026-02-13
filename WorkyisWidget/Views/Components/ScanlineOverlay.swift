import SwiftUI

/// 掃描線疊加層 - 純 SwiftUI 實作，作為 Metal shader 的備用方案
struct ScanlineOverlay: View {
    var lineSpacing: CGFloat = 3
    var opacity: Double = 0.12

    var body: some View {
        Canvas { context, size in
            for y in stride(from: CGFloat(0), to: size.height, by: lineSpacing) {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(opacity)))
            }
        }
        .allowsHitTesting(false)
    }
}

/// CRT 開機動畫文字
struct BootText: View {
    let lines: [String]
    @State private var visibleLines = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<min(visibleLines, lines.count), id: \.self) { index in
                Text(lines[index])
                    .font(CRTTheme.smallFont)
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 2)
            }
        }
        .onAppear {
            animateLines()
        }
    }

    private func animateLines() {
        for i in 0..<lines.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeIn(duration: 0.1)) {
                    visibleLines = i + 1
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ScanlineOverlay()
    }
    .frame(width: 400, height: 300)
}
