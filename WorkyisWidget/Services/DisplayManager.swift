import AppKit
import Combine

@Observable
final class DisplayManager {
    var targetScreen: NSScreen?

    init() {
        findTargetDisplay()
    }

    /// 尋找 Wokyis docking station 的 5 吋螢幕
    func findTargetDisplay() {
        // 優先透過螢幕名稱尋找
        targetScreen = NSScreen.screens.first { screen in
            let name = screen.localizedName.lowercased()
            return name.contains("wokyis") || name.contains("workyis")
        }

        // 備用方案：透過解析度 1280x720 尋找（排除主螢幕）
        if targetScreen == nil {
            targetScreen = NSScreen.screens.first { screen in
                let size = screen.frame.size
                return screen != NSScreen.main
                    && Int(size.width) == 1280
                    && Int(size.height) == 720
            }
        }

        // 如果都找不到，使用第二個螢幕（如果有的話）
        if targetScreen == nil && NSScreen.screens.count > 1 {
            targetScreen = NSScreen.screens[1]
        }
    }

    /// 取得目標螢幕的 frame，如果找不到就回傳 nil
    var targetFrame: NSRect? {
        targetScreen?.frame
    }

    /// 取得目標螢幕的 visible frame
    var targetVisibleFrame: NSRect? {
        targetScreen?.visibleFrame
    }
}
