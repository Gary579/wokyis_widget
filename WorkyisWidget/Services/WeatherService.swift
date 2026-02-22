import Foundation

@Observable
@MainActor
final class WeatherService {
    var temperature: String = "--"
    var symbolName: String = "cloud.fill"     // SF Symbol 名稱
    var rainProbability: String = "--%"       // 降雨機率
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

        let weatherURL = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric&lang=zh_tw"
        let forecastURL = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric&cnt=1"

        guard let wURL = URL(string: weatherURL),
              let fURL = URL(string: forecastURL) else {
            lastError = "無效的 URL"
            isLoading = false
            return
        }

        do {
            // 同時抓 current weather + forecast
            async let weatherTask = URLSession.shared.data(from: wURL)
            async let forecastTask = URLSession.shared.data(from: fURL)

            let (weatherData, weatherResponse) = try await weatherTask
            let (forecastData, _) = try await forecastTask

            guard let httpResponse = weatherResponse as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                lastError = "API 回應錯誤"
                isLoading = false
                return
            }

            let owmResponse = try JSONDecoder().decode(OWMResponse.self, from: weatherData)

            // 溫度
            temperature = String(format: "%.0f°", owmResponse.main.temp)

            // 將 OWM icon code 轉為 SF Symbol
            symbolName = owmIconToSFSymbol(owmResponse.weather.first?.icon ?? "")

            // 降雨機率（從 forecast 取）
            if let forecast = try? JSONDecoder().decode(OWMForecastResponse.self, from: forecastData),
               let firstItem = forecast.list.first {
                rainProbability = String(format: "%.0f%%", firstItem.pop * 100)
            }

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
