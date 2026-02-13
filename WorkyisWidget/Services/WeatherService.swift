import Foundation

@Observable
@MainActor
final class WeatherService {
    var temperature: String = "--"
    var symbolName: String = "cloud.fill"     // SF Symbol 名稱
    var isLoading: Bool = true
    var lastError: String?

    private let apiKey: String
    private let latitude: Double
    private let longitude: Double
    private var refreshTimer: Timer?

    init(apiKey: String = "", latitude: Double = 25.033, longitude: Double = 121.565) {
        self.apiKey = apiKey
        self.latitude = latitude
        self.longitude = longitude
    }

    /// 啟動天氣更新（每 15 分鐘刷新一次）
    func startUpdating() {
        Task { await fetchWeather() }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchWeather()
            }
        }
    }

    func stopUpdating() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    /// 從 OpenWeatherMap 取得天氣資料
    func fetchWeather() async {
        guard !apiKey.isEmpty else {
            temperature = "--"
            symbolName = "exclamationmark.triangle.fill"
            isLoading = false
            return
        }

        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric&lang=zh_tw"

        guard let url = URL(string: urlString) else {
            lastError = "無效的 URL"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                lastError = "API 回應錯誤"
                isLoading = false
                return
            }

            let owmResponse = try JSONDecoder().decode(OWMResponse.self, from: data)

            // 溫度
            temperature = String(format: "%.0f°", owmResponse.main.temp)

            // 將 OWM icon code 轉為 SF Symbol
            symbolName = owmIconToSFSymbol(owmResponse.weather.first?.icon ?? "")

            isLoading = false
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            isLoading = false
        }
    }

    /// OWM icon code → SF Symbol 名稱
    private func owmIconToSFSymbol(_ icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "cloud.snow.fill"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }

    nonisolated deinit {
        // Timer 會在被釋放時自動 invalidate
    }
}
