# Wokyis Widget

一個為 [Wokyis Retro Docking Station for Mac mini M4](https://www.wokyis.com) 設計的桌面時鐘 Widget。原生 macOS app，復古 CRT 終端機風格。

![macOS](https://img.shields.io/badge/macOS-15.0+-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![License](https://img.shields.io/badge/License-MIT-green)

## 特色

- 🖥️ **CRT 復古風格** — 磷光綠文字、掃描線效果、CRT 外框邊框
- ⏰ **巨大時鐘** — Futura Condensed ExtraBold 字體，含秒數顯示
- 🌤️ **即時天氣** — 透過 OpenWeatherMap API 顯示天氣圖示、溫度與降雨機率
- 📺 **全螢幕覆蓋** — 啟動即全螢幕，隱藏 menu bar 與 Dock
- 🔌 **自動偵測螢幕** — 偵測 Wokyis 外接螢幕，自動定位顯示
- 🚫 **零外部依賴** — 純 Swift / SwiftUI，不需任何第三方套件

## 螢幕截圖

```
┌──────────────────────────────────────┐
│                                      │
│              22:30:45                │
│                                      │
│──────────────────────────────────────│
│ 2025年02月13日 星期四  💧12%  ☀️ 18° │
└──────────────────────────────────────┘
```

## 系統需求

- macOS 15.0 (Sequoia) 或以上
- Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（用於生成 .xcodeproj）
- [OpenWeatherMap API Key](https://openweathermap.org/api)（免費方案即可）

## 安裝與設定

### 1. Clone 專案

```bash
git clone https://github.com/Gary579/wokyis_widget.git
cd wokyis_widget
```

### 2. 設定 API Key

```bash
cp WorkyisWidget/Config/Secrets.example.swift WorkyisWidget/Config/Secrets.swift
```

編輯 `WorkyisWidget/Config/Secrets.swift`，填入你的 OpenWeatherMap API Key：

```swift
enum Secrets {
    static let openWeatherMapAPIKey = "你的_API_KEY"
}
```

### 3. 設定座標（選用）

在 `WorkyisWidget/Views/DashboardView.swift` 中修改 `Configuration`：

```swift
enum Configuration {
    // ...
    static let latitude: Double = 25.033    // 你的緯度
    static let longitude: Double = 121.565  // 你的經度
}
```

### 4. 生成 Xcode 專案並編譯

```bash
# 安裝 XcodeGen（如果還沒有）
brew install xcodegen

# 生成 .xcodeproj
xcodegen generate

# 編譯
xcodebuild -project WorkyisWidget.xcodeproj -scheme WorkyisWidget -configuration Release build
```

### 5. 執行

```bash
open ~/Library/Developer/Xcode/DerivedData/WorkyisWidget-*/Build/Products/Release/WorkyisWidget.app
```

或在 Xcode 中直接 `Cmd + R` 執行。

## 專案結構

```
WorkyisWidget/
├── App/
│   ├── WorkyisWidgetApp.swift    # App 入口
│   ├── AppDelegate.swift         # 視窗設定、全螢幕、螢幕偵測
│   └── Info.plist
├── Config/
│   ├── Secrets.swift             # 你的 API Key（不會被 git 追蹤）
│   └── Secrets.example.swift     # API Key 範本
├── Views/
│   ├── DashboardView.swift       # 主畫面佈局
│   ├── Panels/
│   │   ├── ClockPanel.swift      # 時鐘面板
│   │   └── WeatherPanel.swift    # 天氣面板
│   └── Components/
│       ├── CRTBezel.swift        # CRT 外框
│       └── ScanlineOverlay.swift # 掃描線效果
├── Services/
│   ├── WeatherService.swift      # OpenWeatherMap API 服務（天氣 + 降雨機率）
│   └── DisplayManager.swift      # 外接螢幕偵測
├── Utilities/
│   ├── CRTTheme.swift            # 主題色彩與磷光 glow 效果
│   └── MachHelpers.swift         # 系統底層工具
├── Shaders/
│   └── CRTEffect.metal           # Metal shader（掃描線）
└── Models/
    └── WeatherData.swift         # 天氣資料模型
```

## 自訂

### 修改字體

在 `ClockPanel.swift` 中修改字體：

```swift
.font(.custom("Futura-CondensedExtraBold", size: 360))
```

其他推薦字體：
- `DINCondensed-Bold` — 工業風
- `AvenirNextCondensed-Heavy` — 現代幾何風
- `HelveticaNeue-CondensedBold` — 經典風

### 修改 CRT 主題色

在 `CRTTheme.swift` 中調整色彩：

```swift
static let phosphorGreen = Color(red: 0.2, green: 1.0, blue: 0.2)  // 主色
static let phosphorAmber = Color(red: 1.0, green: 0.75, blue: 0.0) // 琥珀色
```

## 授權

MIT License

## 致謝

專為 [Wokyis](https://www.wokyis.com) Retro Docking Station 的 5 吋 1280x720 IPS 顯示器打造。
