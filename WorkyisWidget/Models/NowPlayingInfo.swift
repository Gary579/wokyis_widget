import Foundation

struct NowPlayingInfo {
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var duration: TimeInterval = 0
    var elapsedTime: TimeInterval = 0
    var isPlaying: Bool = false
    var artworkData: Data? = nil

    var isEmpty: Bool {
        title.isEmpty && artist.isEmpty
    }

    var progressRatio: Double {
        guard duration > 0 else { return 0 }
        return min(elapsedTime / duration, 1.0)
    }

    // 格式化時間 mm:ss
    static func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var elapsedTimeString: String {
        Self.formatTime(elapsedTime)
    }

    var durationString: String {
        Self.formatTime(duration)
    }
}
