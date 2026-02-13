import Foundation

struct WeatherData {
    var temperature: Double = 0.0       // 攝氏
    var condition: String = ""          // 天氣狀態描述
    var icon: String = ""               // OpenWeatherMap icon code
    var humidity: Int = 0               // 百分比
    var windSpeed: Double = 0.0         // m/s
    var windDirection: String = ""      // 風向
    var cityName: String = ""

    var temperatureString: String {
        String(format: "%.0f°C", temperature)
    }

    var windSpeedString: String {
        String(format: "%.1f m/s %@", windSpeed, windDirection)
    }

    // 將角度轉換為方位
    static func windDirectionFromDegrees(_ degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                         "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return directions[index]
    }

    // ASCII 天氣圖示
    var asciiIcon: String {
        switch icon.prefix(2) {
        case "01": // 晴天
            return """
                \\   |   /
                 .---.
              --- (   ) ---
                 `---'
                /   |   \\
            """
        case "02", "03": // 少雲 / 多雲
            return """
                 \\  /
              .---(  ).
             (        ).
              `------'
            """
        case "04": // 陰天
            return """
              .---------.
             (           ).
              `---------.
               (          ).
                `---------'
            """
        case "09", "10": // 雨
            return """
              .---------.
             (           ).
              `---------'
               / / / / /
              / / / / /
            """
        case "11": // 雷暴
            return """
              .---------.
             (           ).
              `---------'
                /_/ /_/
               ⚡  ⚡
            """
        case "13": // 雪
            return """
              .---------.
             (           ).
              `---------'
               * * * * *
              * * * * *
            """
        case "50": // 霧
            return """
              ═══════════
              ― ― ― ― ―
              ═══════════
              ― ― ― ― ―
            """
        default:
            return """
                  ?
                 ???
                  ?
            """
        }
    }
}

// MARK: - OpenWeatherMap API 回應模型
struct OWMResponse: Codable {
    let main: OWMMain
    let weather: [OWMWeather]
    let wind: OWMWind
    let name: String
}

struct OWMMain: Codable {
    let temp: Double
    let humidity: Int
}

struct OWMWeather: Codable {
    let description: String
    let icon: String
}

struct OWMWind: Codable {
    let speed: Double
    let deg: Double?
}
