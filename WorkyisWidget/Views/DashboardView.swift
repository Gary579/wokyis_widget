import SwiftUI

struct DashboardView: View {
    @State private var weatherService = WeatherService(
        apiKey: Configuration.openWeatherMapAPIKey,
        latitude: Configuration.latitude,
        longitude: Configuration.longitude
    )

    var body: some View {
        ZStack {
            // 底色
            CRTTheme.screenBackground
                .ignoresSafeArea()

            // 方案 C：時鐘巨大置中 + 底部分隔線（左日期、右天氣）
            VStack(spacing: 0) {
                Spacer()

                // 時鐘 — 佔畫面主體
                ClockPanel()
                    .padding(.top, 40)

                Spacer()

                // 底部分隔線
                Rectangle()
                    .fill(CRTTheme.borderGreen.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal, 40)

                // 底部資訊列：左邊日期、右邊天氣
                BottomBar(
                    symbolName: weatherService.symbolName,
                    temperature: weatherService.temperature,
                    lastError: weatherService.lastError,
                    isLoading: weatherService.isLoading
                )
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
            }

            // CRT 外框
            CRTBezel()
                .allowsHitTesting(false)

            // 掃描線疊加
            ScanlineOverlay(lineSpacing: 3, opacity: 0.1)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .onAppear {
            weatherService.startUpdating()
        }
        .onDisappear {
            weatherService.stopUpdating()
        }
    }
}

// MARK: - 底部資訊列

struct BottomBar: View {
    var symbolName: String
    var temperature: String
    var lastError: String?
    var isLoading: Bool

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_TW")
        f.dateFormat = "yyyy年MM月dd日  EEEE"
        return f
    }()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60.0)) { context in
            HStack {
                // 左邊：日期
                Text(dateFormatter.string(from: context.date))
                    .font(.system(size: 28, weight: .regular, design: .monospaced))
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 3)

                Spacer()

                // 右邊：天氣圖示 + 溫度
                if isLoading {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 28))
                        .foregroundColor(CRTTheme.dimGreen)
                        .symbolEffect(.pulse)
                } else if lastError != nil && temperature == "--" {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 28))
                        .foregroundColor(CRTTheme.phosphorAmber)
                } else {
                    HStack(spacing: 12) {
                        Image(systemName: symbolName)
                            .font(.system(size: 28))
                            .foregroundColor(CRTTheme.phosphorGreen)
                            .phosphorGlow(CRTTheme.phosphorGreen, radius: 3)
                            .symbolRenderingMode(.hierarchical)

                        Text(temperature)
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(CRTTheme.phosphorGreen)
                            .phosphorGlow(CRTTheme.phosphorGreen, radius: 3)
                    }
                }
            }
        }
    }
}

// MARK: - 設定

enum Configuration {
    static let openWeatherMapAPIKey = Secrets.openWeatherMapAPIKey

    // 預設座標：台北（可自行修改）
    static let latitude: Double = 25.033
    static let longitude: Double = 121.565
}

#Preview {
    DashboardView()
        .frame(width: 1280, height: 720)
}
