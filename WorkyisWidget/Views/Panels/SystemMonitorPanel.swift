import SwiftUI

struct SystemMonitorPanel: View {
    var stats: SystemStats

    var body: some View {
        PanelFrame(title: "SYSTEM") {
            VStack(spacing: 6) {
                // 第一行: CPU + MEM
                HStack(spacing: 24) {
                    RetroGauge(
                        label: "CPU",
                        value: stats.cpuUsage,
                        valueText: String(format: "%2.0f%%", stats.cpuUsage * 100),
                        color: gaugeColor(for: stats.cpuUsage)
                    )

                    RetroGauge(
                        label: "MEM",
                        value: stats.memoryUsageRatio,
                        valueText: String(format: "%2.0f%%", stats.memoryUsageRatio * 100),
                        color: gaugeColor(for: stats.memoryUsageRatio)
                    )
                }

                // 第二行: DSK + NET
                HStack(spacing: 24) {
                    RetroGauge(
                        label: "DSK",
                        value: stats.diskUsageRatio,
                        valueText: String(format: "%2.0f%%", stats.diskUsageRatio * 100),
                        color: gaugeColor(for: stats.diskUsageRatio)
                    )

                    // 網路顯示為文字（不是百分比所以不用 gauge）
                    HStack(spacing: 8) {
                        Text("NET")
                            .font(CRTTheme.dataFont)
                            .foregroundColor(CRTTheme.dimGreen)
                            .frame(width: 55, alignment: .trailing)

                        HStack(spacing: 12) {
                            // 下載
                            HStack(spacing: 2) {
                                Text("↓")
                                    .font(CRTTheme.dataFont)
                                    .foregroundColor(CRTTheme.phosphorGreen)
                                Text(SystemStats.formatSpeed(stats.networkBytesIn))
                                    .font(CRTTheme.dataFont)
                                    .foregroundColor(CRTTheme.phosphorGreen)
                                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 2)
                            }

                            // 上傳
                            HStack(spacing: 2) {
                                Text("↑")
                                    .font(CRTTheme.dataFont)
                                    .foregroundColor(CRTTheme.phosphorAmber)
                                Text(SystemStats.formatSpeed(stats.networkBytesOut))
                                    .font(CRTTheme.dataFont)
                                    .foregroundColor(CRTTheme.phosphorAmber)
                                    .phosphorGlow(CRTTheme.phosphorAmber, radius: 2)
                            }
                        }
                    }
                }

                // 記憶體詳細資訊
                HStack(spacing: 16) {
                    Text("MEM: \(SystemStats.formatBytes(stats.memoryUsed)) / \(SystemStats.formatBytes(stats.memoryTotal))")
                        .font(CRTTheme.smallFont)
                        .foregroundColor(CRTTheme.dimGreen)

                    Text("DSK: \(SystemStats.formatBytes(stats.diskUsed)) / \(SystemStats.formatBytes(stats.diskTotal))")
                        .font(CRTTheme.smallFont)
                        .foregroundColor(CRTTheme.dimGreen)
                }
            }
        }
    }

    /// 根據使用量決定顏色（低=綠色, 高=琥珀色）
    private func gaugeColor(for value: Double) -> Color {
        if value > 0.85 {
            return Color(red: 1.0, green: 0.3, blue: 0.2) // 紅色警告
        } else if value > 0.7 {
            return CRTTheme.phosphorAmber
        } else {
            return CRTTheme.phosphorGreen
        }
    }
}

#Preview {
    SystemMonitorPanel(stats: SystemStats(
        cpuUsage: 0.42,
        memoryUsed: 12_884_901_888,
        memoryTotal: 17_179_869_184,
        diskUsed: 412_316_860_416,
        diskTotal: 499_963_174_912,
        networkBytesIn: 125_400,
        networkBytesOut: 42_100
    ))
    .frame(width: 800)
    .background(CRTTheme.screenBackground)
}
