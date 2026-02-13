import SwiftUI

struct NowPlayingPanel: View {
    var nowPlaying: NowPlayingInfo

    var body: some View {
        PanelFrame(title: "NOW PLAYING") {
            if nowPlaying.isEmpty {
                // 沒有在播放音樂
                noSignalView
            } else {
                // 顯示音樂資訊
                nowPlayingView
            }
        }
    }

    // MARK: - 正在播放

    private var nowPlayingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 播放狀態 + 歌名
            HStack(spacing: 8) {
                Text(nowPlaying.isPlaying ? "▶" : "⏸")
                    .font(CRTTheme.dataFont)
                    .foregroundColor(CRTTheme.phosphorGreen)

                Text(nowPlaying.title)
                    .font(CRTTheme.dataFont)
                    .foregroundColor(CRTTheme.phosphorGreen)
                    .phosphorGlow(CRTTheme.phosphorGreen, radius: 3)
                    .lineLimit(1)
            }

            // 歌手 - 專輯
            HStack(spacing: 8) {
                Text("  ")  // 對齊
                Text("\(nowPlaying.artist)")
                    .font(CRTTheme.labelFont)
                    .foregroundColor(CRTTheme.dimGreen)
                    .lineLimit(1)

                if !nowPlaying.album.isEmpty {
                    Text("·")
                        .foregroundColor(CRTTheme.dimGreen)
                    Text(nowPlaying.album)
                        .font(CRTTheme.labelFont)
                        .foregroundColor(CRTTheme.dimGreen)
                        .lineLimit(1)
                }
            }

            // 進度條
            if nowPlaying.duration > 0 {
                HStack(spacing: 8) {
                    Text(nowPlaying.elapsedTimeString)
                        .font(CRTTheme.smallFont)
                        .foregroundColor(CRTTheme.dimGreen)
                        .frame(width: 40)

                    // ASCII 進度條
                    progressBar

                    Text(nowPlaying.durationString)
                        .font(CRTTheme.smallFont)
                        .foregroundColor(CRTTheme.dimGreen)
                        .frame(width: 40)
                }
            }
        }
    }

    // MARK: - 進度條

    private var progressBar: some View {
        GeometryReader { geo in
            let totalChars = max(1, Int(geo.size.width / 8))
            let filledChars = Int(nowPlaying.progressRatio * Double(totalChars))
            let emptyChars = totalChars - filledChars

            Text(
                String(repeating: "━", count: filledChars)
                + "●"
                + String(repeating: "─", count: max(0, emptyChars - 1))
            )
            .font(CRTTheme.smallFont)
            .foregroundColor(CRTTheme.phosphorGreen)
            .phosphorGlow(CRTTheme.phosphorGreen, radius: 2)
            .lineLimit(1)
        }
        .frame(height: 14)
    }

    // MARK: - 無訊號

    private var noSignalView: some View {
        VStack(spacing: 4) {
            Text("■ NO SIGNAL ■")
                .font(CRTTheme.dataFont)
                .foregroundColor(CRTTheme.dimGreen)

            Text("Waiting for audio source...")
                .font(CRTTheme.smallFont)
                .foregroundColor(CRTTheme.dimGreen.opacity(0.6))

            // 閃爍的靜態雜訊效果
            staticNoiseText
        }
    }

    private var staticNoiseText: some View {
        TimelineView(.periodic(from: .now, by: 0.3)) { _ in
            let noiseChars = "░▒▓█▄▀▌▐"
            let noise = (0..<40).map { _ in
                String(noiseChars.randomElement()!)
            }.joined()

            Text(noise)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(CRTTheme.dimGreen.opacity(0.3))
                .lineLimit(1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        NowPlayingPanel(nowPlaying: NowPlayingInfo(
            title: "Bohemian Rhapsody",
            artist: "Queen",
            album: "A Night at the Opera",
            duration: 354,
            elapsedTime: 127,
            isPlaying: true
        ))

        NowPlayingPanel(nowPlaying: NowPlayingInfo())
    }
    .frame(width: 700)
    .background(CRTTheme.screenBackground)
}
