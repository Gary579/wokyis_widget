import Foundation

struct SystemStats {
    var cpuUsage: Double = 0.0          // 0.0 ~ 1.0
    var memoryUsed: UInt64 = 0          // bytes
    var memoryTotal: UInt64 = 0         // bytes
    var diskUsed: UInt64 = 0            // bytes
    var diskTotal: UInt64 = 0           // bytes
    var networkBytesIn: UInt64 = 0      // bytes/sec
    var networkBytesOut: UInt64 = 0     // bytes/sec

    var memoryUsageRatio: Double {
        guard memoryTotal > 0 else { return 0 }
        return Double(memoryUsed) / Double(memoryTotal)
    }

    var diskUsageRatio: Double {
        guard diskTotal > 0 else { return 0 }
        return Double(diskUsed) / Double(diskTotal)
    }

    // 格式化 bytes 為人類可讀格式
    static func formatBytes(_ bytes: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0
        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }
        if unitIndex == 0 {
            return String(format: "%.0f %@", value, units[unitIndex])
        }
        return String(format: "%.1f %@", value, units[unitIndex])
    }

    // 格式化網路速度
    static func formatSpeed(_ bytesPerSec: UInt64) -> String {
        return formatBytes(bytesPerSec) + "/s"
    }
}
