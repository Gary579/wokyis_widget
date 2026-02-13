import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let displayManager = DisplayManager()
    private var screenChangeObserver: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 延遲一點執行，確保 SwiftUI window 已經建立
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MainActor.assumeIsolated {
                self.configureWindow()
                self.observeDisplayChanges()
            }
        }
    }

    // MARK: - 視窗設定

    private func configureWindow() {
        guard let window = NSApplication.shared.windows.first else { return }

        // 無邊框、無標題列
        window.styleMask = [.borderless]
        window.isOpaque = true
        window.backgroundColor = .black
        window.hasShadow = false

        // 蓋過 menu bar 等級
        window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))

        // 在所有 Space 上顯示，不出現在 Mission Control
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        // 隱藏 menu bar 和 Dock
        NSApplication.shared.presentationOptions = [.hideMenuBar, .hideDock]

        // 定位到目標螢幕（使用完整 frame，含 menu bar 區域）
        positionWindow(window)
    }

    private func positionWindow(_ window: NSWindow) {
        displayManager.findTargetDisplay()

        if let targetFrame = displayManager.targetFrame {
            // 有找到目標螢幕，全螢幕顯示在上面
            window.setFrame(targetFrame, display: true, animate: false)
        } else if let mainScreen = NSScreen.main {
            // 沒有外接螢幕，全螢幕顯示在主螢幕上
            window.setFrame(mainScreen.frame, display: true, animate: false)
        }
    }

    // MARK: - 螢幕變更監聽

    private func observeDisplayChanges() {
        screenChangeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self,
                      let window = NSApplication.shared.windows.first else { return }
                self.positionWindow(window)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let observer = screenChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // 防止關閉視窗時退出應用程式
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
