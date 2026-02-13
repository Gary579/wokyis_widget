import SwiftUI

/// CRT 螢幕外框 - 模擬 CRT 顯示器的邊框和陰影
struct CRTBezel: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color(white: 0.2),
                        Color(white: 0.06),
                        Color(white: 0.15),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: CRTTheme.bezelWidth
            )
            .shadow(color: .black.opacity(0.7), radius: 15, x: 0, y: 0)
    }
}

/// 面板外框 - 用於各個功能面板
struct PanelFrame<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 面板標題
            HStack(spacing: 6) {
                Text("▸")
                    .font(CRTTheme.labelFont)
                    .foregroundColor(CRTTheme.phosphorGreen)
                Text(title)
                    .font(CRTTheme.headerFont)
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 3)

                // 標題後的虛線
                GeometryReader { geo in
                    let dashCount = Int(geo.size.width / 10)
                    Text(String(repeating: "─", count: max(0, dashCount)))
                        .font(CRTTheme.smallFont)
                        .foregroundColor(CRTTheme.dimGreen)
                        .lineLimit(1)
                }
                .frame(height: 20)
            }

            // 面板內容
            content()
        }
        .padding(CRTTheme.panelPadding)
        .background(
            RoundedRectangle(cornerRadius: CRTTheme.panelCornerRadius)
                .fill(CRTTheme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: CRTTheme.panelCornerRadius)
                        .strokeBorder(CRTTheme.borderGreen.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PanelFrame(title: "SYSTEM") {
        Text("Test Content")
            .font(CRTTheme.dataFont)
            .foregroundColor(CRTTheme.phosphorGreen)
    }
    .padding()
    .background(CRTTheme.screenBackground)
}
