import SwiftUI

/// CRT 風格的進度條
struct RetroGauge: View {
    let label: String
    let value: Double          // 0.0 ~ 1.0
    let valueText: String
    var color: Color = CRTTheme.phosphorGreen
    var width: CGFloat = 200

    private let totalBlocks = 20

    var body: some View {
        HStack(spacing: 8) {
            // 標籤
            Text(label)
                .font(CRTTheme.dataFont)
                .foregroundColor(CRTTheme.dimGreen)
                .frame(width: 55, alignment: .trailing)

            // 進度條 [████░░░░]
            Text(gaugeString)
                .font(CRTTheme.dataFont)
                .foregroundColor(color)
                .phosphorGlow(color, radius: 3)

            // 數值
            Text(valueText)
                .font(CRTTheme.dataFont)
                .foregroundColor(color)
                .phosphorGlow(color, radius: 2)
                .frame(width: 70, alignment: .trailing)
        }
    }

    private var gaugeString: String {
        let filled = Int(value * Double(totalBlocks))
        let empty = totalBlocks - filled
        let bar = String(repeating: "█", count: max(0, filled))
            + String(repeating: "░", count: max(0, empty))
        return "[\(bar)]"
    }
}

/// CRT 風格的圖標文字
struct RetroLabel: View {
    let icon: String
    let text: String
    var color: Color = CRTTheme.phosphorGreen

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(CRTTheme.labelFont)
                .foregroundColor(CRTTheme.dimGreen)
            Text(text)
                .font(CRTTheme.dataFont)
                .foregroundColor(color)
                .phosphorGlow(color, radius: 2)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        RetroGauge(label: "CPU", value: 0.42, valueText: "42%")
        RetroGauge(label: "MEM", value: 0.68, valueText: "68%")
        RetroGauge(label: "DSK", value: 0.82, valueText: "82%", color: CRTTheme.phosphorAmber)
    }
    .padding()
    .background(CRTTheme.screenBackground)
}
