import Foundation
import Combine

@Observable
@MainActor
final class SystemMonitor {
    var stats = SystemStats()

    private var timer: Timer?
    private var previousCPUTicks = CPUTicks()
    private var previousNetworkBytes = NetworkBytes()
    private var previousNetworkTimestamp: Date = .now
    private var diskTimer: Timer?

    init() {
        // 初始化基準值
        previousCPUTicks = getCPUTicks()
        previousNetworkBytes = getNetworkBytes()
        previousNetworkTimestamp = .now

        // 初始讀取一次磁碟（變化慢，不需要頻繁更新）
        updateDiskUsage()
    }

    /// 啟動監控
    func startMonitoring() {
        // 每 2 秒更新 CPU、記憶體、網路
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateFastMetrics()
            }
        }

        // 每 30 秒更新磁碟
        diskTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateDiskUsage()
            }
        }

        // 立即執行一次
        updateFastMetrics()
    }

    /// 停止監控
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        diskTimer?.invalidate()
        diskTimer = nil
    }

    // MARK: - 內部更新方法

    private func updateFastMetrics() {
        updateCPU()
        updateMemory()
        updateNetwork()
    }

    private func updateCPU() {
        let currentTicks = getCPUTicks()
        stats.cpuUsage = cpuUsageFromDelta(previous: previousCPUTicks, current: currentTicks)
        previousCPUTicks = currentTicks
    }

    private func updateMemory() {
        let mem = getMemoryUsage()
        stats.memoryUsed = mem.used
        stats.memoryTotal = mem.total
    }

    private func updateDiskUsage() {
        let disk = getDiskUsage()
        stats.diskUsed = disk.used
        stats.diskTotal = disk.total
    }

    private func updateNetwork() {
        let currentBytes = getNetworkBytes()
        let now = Date.now
        let elapsed = now.timeIntervalSince(previousNetworkTimestamp)

        guard elapsed > 0 else { return }

        // 計算每秒傳輸量（處理 counter overflow）
        let bytesInDelta: UInt64
        let bytesOutDelta: UInt64

        if currentBytes.bytesIn >= previousNetworkBytes.bytesIn {
            bytesInDelta = currentBytes.bytesIn - previousNetworkBytes.bytesIn
        } else {
            bytesInDelta = currentBytes.bytesIn // counter 溢位，使用當前值
        }

        if currentBytes.bytesOut >= previousNetworkBytes.bytesOut {
            bytesOutDelta = currentBytes.bytesOut - previousNetworkBytes.bytesOut
        } else {
            bytesOutDelta = currentBytes.bytesOut
        }

        stats.networkBytesIn = UInt64(Double(bytesInDelta) / elapsed)
        stats.networkBytesOut = UInt64(Double(bytesOutDelta) / elapsed)

        previousNetworkBytes = currentBytes
        previousNetworkTimestamp = now
    }

    nonisolated deinit {
        // Timers 會在被釋放時自動停止
    }
}
