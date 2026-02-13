import SwiftUI

struct WeatherPanel: View {
    var symbolName: String
    var temperature: String
    var lastError: String?
    var isLoading: Bool

    var body: some View {
        VStack(spacing: 8) {
            if isLoading {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 64))
                    .foregroundColor(CRTTheme.dimGreen)
                    .symbolEffect(.pulse)
            } else if lastError != nil && temperature == "--" {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 64))
                    .foregroundColor(CRTTheme.phosphorAmber)
                    .phosphorGlow(CRTTheme.phosphorAmber, radius: 5)
            } else {
                // 天氣圖示
                Image(systemName: symbolName)
                    .font(.system(size: 64))
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 6)
                    .symbolRenderingMode(.hierarchical)

                // 溫度
                Text(temperature)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 4)
            }
        }
    }
}

#Preview {
    HStack(spacing: 40) {
        WeatherPanel(symbolName: "sun.max.fill", temperature: "24°", isLoading: false)
        WeatherPanel(symbolName: "cloud.rain.fill", temperature: "18°", isLoading: false)
    }
    .padding()
    .background(CRTTheme.screenBackground)
}
