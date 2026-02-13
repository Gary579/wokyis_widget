import Foundation
import Darwin

// MARK: - CPU 使用率

struct CPUTicks {
    var user: UInt64 = 0
    var system: UInt64 = 0
    var idle: UInt64 = 0
    var nice: UInt64 = 0

    var total: UInt64 { user + system + idle + nice }
}

func getCPUTicks() -> CPUTicks {
    var cpuLoadInfo = host_cpu_load_info_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

    let result = withUnsafeMutablePointer(to: &cpuLoadInfo) { ptr in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, intPtr, &count)
        }
    }

    guard result == KERN_SUCCESS else {
        return CPUTicks()
    }

    return CPUTicks(
        user: UInt64(cpuLoadInfo.cpu_ticks.0),
        system: UInt64(cpuLoadInfo.cpu_ticks.1),
        idle: UInt64(cpuLoadInfo.cpu_ticks.2),
        nice: UInt64(cpuLoadInfo.cpu_ticks.3)
    )
}

func cpuUsageFromDelta(previous: CPUTicks, current: CPUTicks) -> Double {
    let userDelta = current.user - previous.user
    let systemDelta = current.system - previous.system
    let idleDelta = current.idle - previous.idle
    let niceDelta = current.nice - previous.nice
    let totalDelta = userDelta + systemDelta + idleDelta + niceDelta

    guard totalDelta > 0 else { return 0 }
    return Double(userDelta + systemDelta) / Double(totalDelta)
}

// MARK: - 記憶體使用率

struct MemoryUsage {
    var used: UInt64 = 0
    var total: UInt64 = 0
}

func getMemoryUsage() -> MemoryUsage {
    var stats = vm_statistics64_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

    let result = withUnsafeMutablePointer(to: &stats) { ptr in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
            host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
        }
    }

    guard result == KERN_SUCCESS else {
        return MemoryUsage()
    }

    // vm_page_size 在 Swift 6 被標記為非安全的全域變數，用 sysctl 取代
    var pageSize: UInt64 = 16384 // 預設 16KB (Apple Silicon)
    var pageSizeValue: vm_size_t = 0
    let hostPort = mach_host_self()
    if host_page_size(hostPort, &pageSizeValue) == KERN_SUCCESS {
        pageSize = UInt64(pageSizeValue)
    }
    let active = UInt64(stats.active_count) * pageSize
    let wired = UInt64(stats.wire_count) * pageSize
    let compressed = UInt64(stats.compressor_page_count) * pageSize

    let used = active + wired + compressed
    let total = ProcessInfo.processInfo.physicalMemory

    return MemoryUsage(used: used, total: total)
}

// MARK: - 磁碟使用率

struct DiskUsage {
    var used: UInt64 = 0
    var total: UInt64 = 0
}

func getDiskUsage() -> DiskUsage {
    let url = URL(fileURLWithPath: "/")
    guard let values = try? url.resourceValues(forKeys: [
        .volumeTotalCapacityKey,
        .volumeAvailableCapacityForImportantUsageKey
    ]) else {
        return DiskUsage()
    }

    let total = UInt64(values.volumeTotalCapacity ?? 0)
    let available = UInt64(values.volumeAvailableCapacityForImportantUsage ?? 0)
    let used = total > available ? total - available : 0

    return DiskUsage(used: used, total: total)
}

// MARK: - 網路流量

struct NetworkBytes {
    var bytesIn: UInt64 = 0
    var bytesOut: UInt64 = 0
}

func getNetworkBytes() -> NetworkBytes {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
        return NetworkBytes()
    }
    defer { freeifaddrs(ifaddr) }

    var totalIn: UInt64 = 0
    var totalOut: UInt64 = 0

    var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddr
    while let addr = cursor {
        let name = String(cString: addr.pointee.ifa_name)
        // 只計算實際網路介面，排除 loopback
        if addr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK) && name != "lo0" {
            if let data = addr.pointee.ifa_data {
                let networkData = data.assumingMemoryBound(to: if_data.self)
                totalIn += UInt64(networkData.pointee.ifi_ibytes)
                totalOut += UInt64(networkData.pointee.ifi_obytes)
            }
        }
        cursor = addr.pointee.ifa_next
    }

    return NetworkBytes(bytesIn: totalIn, bytesOut: totalOut)
}
